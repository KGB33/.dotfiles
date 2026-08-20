(ns pi.extensions.otel
  (:require ["node:path" :as path]
            ["@opentelemetry/api"
             :refer [ROOT_CONTEXT SpanStatusCode trace]]
            ["@opentelemetry/exporter-trace-otlp-http"
             :refer [OTLPTraceExporter]]
            ["@opentelemetry/resources"
             :refer [detectResources envDetector resourceFromAttributes]]
            ["@opentelemetry/sdk-trace-base"
             :refer [BatchSpanProcessor]]
            ["@opentelemetry/sdk-trace-node"
             :refer [NodeTracerProvider]]
            ["@opentelemetry/semantic-conventions"
             :refer [ATTR_SERVICE_NAME]]))

(defn compact-attributes [attributes]
  (reduce-kv (fn [result key value]
               (if (nil? value)
                 result
                 (assoc result key value)))
             {}
             attributes))

(defn make-lifecycle [adapter]
  {:adapter adapter
   :state (atom {:conversation nil :turn nil :tools {}})})

(defn adapter-call! [lifecycle operation & args]
  (try
    (apply (get (:adapter lifecycle) operation) args)
    (catch :default _
      nil)))

(defn start-span! [lifecycle name attributes parent]
  (adapter-call! lifecycle
                 :start-span!
                 name
                 (compact-attributes attributes)
                 parent))

(defn start-conversation! [lifecycle attributes]
  (when-not (:conversation @(:state lifecycle))
    (when-let [conversation (start-span! lifecycle
                                         "pi.conversation"
                                         attributes
                                         nil)]
      (swap! (:state lifecycle) assoc :conversation conversation))))

(defn finish-span! [lifecycle handle reason]
  (when handle
    (adapter-call! lifecycle
                   :set-attributes!
                   handle
                   (if reason
                     {"pi.completion" "cleanup"
                      "pi.incomplete_reason" reason}
                     {"pi.completion" "normal"}))
    (adapter-call! lifecycle :end-span! handle)))

(defn close-active-turn! [lifecycle reason]
  (let [{:keys [turn tools]} @(:state lifecycle)]
    (doseq [[_ handle] tools]
      (finish-span! lifecycle handle reason))
    (when turn
      (finish-span! lifecycle (:headers turn) reason)
      (finish-span! lifecycle (:stream turn) reason)
      (finish-span! lifecycle (:request turn) reason)
      (finish-span! lifecycle (:prepare turn) reason)
      (finish-span! lifecycle (:root turn) reason))
    (swap! (:state lifecycle) assoc :turn nil :tools {})))

(defn start-turn! [lifecycle attributes]
  (when (:turn @(:state lifecycle))
    (close-active-turn! lifecycle "superseded"))
  (when-let [conversation (:conversation @(:state lifecycle))]
    (when-let [root (start-span! lifecycle
                                 "pi.turn"
                                 attributes
                                 conversation)]
      (let [prepare (start-span! lifecycle "pi.prepare" {} root)]
        (swap! (:state lifecycle)
               assoc
               :turn
               {:root root
                :prepare prepare
                :request nil
                :headers nil
                :stream nil
                :first-update? false}
               :tools {})))))

(defn provider-request! [lifecycle attributes]
  (when-let [turn (:turn @(:state lifecycle))]
    (when-not (:request turn)
      (finish-span! lifecycle (:prepare turn) nil)
      (let [turn (assoc turn :prepare nil)]
        (swap! (:state lifecycle) assoc :turn turn)
        (when-let [request (start-span! lifecycle
                                        "gen_ai.request"
                                        attributes
                                        (:root turn))]
          (let [headers (start-span! lifecycle
                                     "pi.provider.wait_headers"
                                     {}
                                     request)]
            (swap! (:state lifecycle)
                   assoc
                   :turn
                   (assoc turn
                          :request request
                          :headers headers))))))))

(defn provider-response! [lifecycle status]
  (when-let [turn (:turn @(:state lifecycle))]
    (when-let [request (:request turn)]
      (let [attributes {"http.response.status_code" status}
            headers (:headers turn)]
        (adapter-call! lifecycle :set-attributes! request attributes)
        (when headers
          (adapter-call! lifecycle :set-attributes! headers attributes))
        (when (>= status 400)
          (adapter-call! lifecycle
                         :set-error!
                         request
                         "provider request failed")
          (when headers
            (adapter-call! lifecycle
                           :set-error!
                           headers
                           "provider request failed")))
        (finish-span! lifecycle headers nil)
        (let [stream (or (:stream turn)
                         (start-span! lifecycle
                                      "pi.provider.stream"
                                      {}
                                      request))]
          (swap! (:state lifecycle)
                 assoc
                 :turn
                 (assoc turn :headers nil :stream stream)))))))

(defn response-update! [lifecycle]
  (when-let [turn (:turn @(:state lifecycle))]
    (when (and (:request turn) (not (:first-update? turn)))
      (adapter-call! lifecycle
                     :add-event!
                     (:request turn)
                     "pi.response.first_update")
      (when (:stream turn)
        (adapter-call! lifecycle
                       :add-event!
                       (:stream turn)
                       "pi.response.first_update"))
      (swap! (:state lifecycle)
             assoc
             :turn
             (assoc turn :first-update? true)))))

(defn message-attributes [message]
  (let [usage (.-usage message)]
    (compact-attributes
      {"gen_ai.response.model" (or (.-responseModel message)
                                    (.-model message))
       "gen_ai.response.finish_reasons" [(.-stopReason message)]
       "gen_ai.usage.input_tokens" (when usage (.-input usage))
       "gen_ai.usage.output_tokens" (when usage (.-output usage))
       "gen_ai.usage.cache_read.input_tokens" (when usage (.-cacheRead usage))
       "gen_ai.usage.cache_creation.input_tokens" (when usage (.-cacheWrite usage))
       "gen_ai.usage.reasoning.output_tokens" (when usage (.-reasoning usage))})))

(defn assistant-end! [lifecycle message]
  (when-let [turn (:turn @(:state lifecycle))]
    (let [attributes (message-attributes message)
          request (:request turn)
          stop-reason (.-stopReason message)]
      (adapter-call! lifecycle :set-attributes! (:root turn) attributes)
      (when request
        (adapter-call! lifecycle :set-attributes! request attributes)
        (when (#{"error" "aborted"} stop-reason)
          (adapter-call! lifecycle
                         :set-error!
                         request
                         "model request failed")))
      (finish-span! lifecycle
                    (:headers turn)
                    "missing_provider_response")
      (finish-span! lifecycle (:stream turn) nil)
      (finish-span! lifecycle request nil)
      (swap! (:state lifecycle)
             assoc
             :turn
             (assoc turn :headers nil :stream nil :request nil)))))

(defn serialize-tool-arguments [args]
  (try
    (let [serialized (js/JSON.stringify args)]
      (when (string? serialized)
        serialized))
    (catch :default _
      nil)))

(defn tool-start! [lifecycle tool-call-id tool-name args]
  (let [{:keys [turn tools]} @(:state lifecycle)]
    (when (and turn (not (contains? tools tool-call-id)))
      (when-let [handle (start-span!
                          lifecycle
                          (str "pi.tool " tool-name)
                          {"gen_ai.tool.name" tool-name
                           "gen_ai.tool.call.id" tool-call-id
                           "gen_ai.tool.call.arguments"
                           (serialize-tool-arguments args)}
                          (:root turn))]
        (swap! (:state lifecycle)
               assoc-in
               [:tools tool-call-id]
               handle)))))

(defn tool-end! [lifecycle tool-call-id is-error]
  (when-let [handle (get-in @(:state lifecycle) [:tools tool-call-id])]
    (when is-error
      (adapter-call! lifecycle
                     :set-error!
                     handle
                     "tool execution failed"))
    (finish-span! lifecycle handle nil)
    (swap! (:state lifecycle) update :tools dissoc tool-call-id)))

(defn turn-end! [lifecycle message]
  (when (and message
             (= "assistant" (.-role message))
             (get-in @(:state lifecycle) [:turn :request]))
    (assistant-end! lifecycle message))
  (let [{:keys [turn tools]} @(:state lifecycle)]
    (doseq [[_ handle] tools]
      (finish-span! lifecycle handle "turn_end"))
    (when turn
      (finish-span! lifecycle (:headers turn) "turn_end")
      (finish-span! lifecycle (:stream turn) "turn_end")
      (finish-span! lifecycle (:request turn) "turn_end")
      (finish-span! lifecycle (:prepare turn) "missing_provider_request")
      (finish-span! lifecycle (:root turn) nil))
    (swap! (:state lifecycle) assoc :turn nil :tools {})))

(defn shutdown-lifecycle! [lifecycle]
  (close-active-turn! lifecycle "session_shutdown")
  (when-let [conversation (:conversation @(:state lifecycle))]
    (finish-span! lifecycle conversation nil)
    (swap! (:state lifecycle) assoc :conversation nil)))

(def instrumentation-name "pi.otel")
(def instrumentation-version "1.0.0")

(defn create-otel-runtime []
  (let [service-name (or (not-empty
                           (aget (.-env js/process) "OTEL_SERVICE_NAME"))
                         "pi-coding-agent")
        env-resource (detectResources #js {:detectors #js [envDetector]})
        resource (.merge env-resource
                         (resourceFromAttributes
                           (clj->js
                             {ATTR_SERVICE_NAME service-name
                              "pi.otel.instrumentation.version"
                              instrumentation-version})))
        exporter (OTLPTraceExporter.)
        processor (BatchSpanProcessor. exporter)
        provider (NodeTracerProvider.
                   #js {:resource resource
                        :spanProcessors #js [processor]})
        tracer (.getTracer provider
                           instrumentation-name
                           instrumentation-version)
        adapter
        {:start-span!
         (fn [name attributes parent]
           (let [parent-context (if parent (:context parent) ROOT_CONTEXT)
                 span (.startSpan tracer
                                  name
                                  #js {:attributes (clj->js attributes)}
                                  parent-context)]
             {:span span
              :context (.setSpan trace parent-context span)}))
         :set-attributes!
         (fn [handle attributes]
           (.setAttributes (:span handle) (clj->js attributes)))
         :add-event!
         (fn [handle event-name]
           (.addEvent (:span handle) event-name))
         :set-error!
         (fn [handle fixed-message]
           (.setStatus (:span handle)
                       #js {:code (.-ERROR SpanStatusCode)
                            :message fixed-message}))
         :end-span!
         (fn [handle]
           (.end (:span handle)))}]
    {:adapter adapter
     :shutdown!
     ^:async (fn []
       (try
         (await (.forceFlush provider))
         (catch :default _
           nil))
       (try
         (await (.shutdown provider))
         (catch :default _
           nil)))}))

(defn model-attributes [ctx]
  (let [model (.-model ctx)]
    {"gen_ai.operation.name" "chat"
     "gen_ai.provider.name" (when model (.-provider model))
     "gen_ai.request.model" (when model (.-id model))
     "pi.thinking_level" (.-thinkingLevel ctx)}))

(defn conversation-attributes [ctx]
  {"pi.project.name" (.basename path (.-cwd ctx))
   "pi.session.id" (.getSessionId (.-sessionManager ctx))})

(defn turn-attributes [event ctx]
  (let [context-usage (.getContextUsage ctx)]
    (merge
      (model-attributes ctx)
      (conversation-attributes ctx)
      {"pi.turn.index" (.-turnIndex event)
       "pi.context.tokens" (when context-usage (.-tokens context-usage))})))

(defn guarded [handler]
  (fn [& args]
    (try
      (apply handler args)
      js/undefined
      (catch :default _
        js/undefined))))

(defn tracing-enabled? [getenv]
  (boolean
    (or (not-empty
          (getenv "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"))
        (not-empty
          (getenv "OTEL_EXPORTER_OTLP_ENDPOINT")))))

(defn register-extension!
  ([pi]
   (register-extension!
     pi
     {:getenv (fn [name]
                (aget (.-env js/process) name))
      :runtime-factory create-otel-runtime}))
  ([pi {:keys [getenv runtime-factory]}]
   (let [runtime (atom nil)
         lifecycle (atom nil)
         warned? (atom false)]
     (.on pi
          "session_start"
          (guarded
            (fn [_event ctx]
              (when (and (nil? @runtime)
                         (tracing-enabled? getenv))
                (try
                  (let [created (runtime-factory)
                        active (make-lifecycle (:adapter created))]
                    (reset! runtime created)
                    (reset! lifecycle active)
                    (start-conversation! active
                                         (conversation-attributes ctx)))
                  (catch :default _
                    (when (and (.-hasUI ctx)
                               (compare-and-set! warned? false true))
                      (.notify (.-ui ctx)
                               "OTEL tracing disabled: initialization failed"
                               "warning"))))))))
     (.on pi
          "turn_start"
          (guarded
            (fn [event ctx]
              (when-let [active @lifecycle]
                (start-turn! active (turn-attributes event ctx))))))
     (.on pi
          "before_provider_request"
          (guarded
            (fn [_event ctx]
              (when-let [active @lifecycle]
                (provider-request! active (model-attributes ctx))))))
     (.on pi
          "after_provider_response"
          (guarded
            (fn [event _ctx]
              (when-let [active @lifecycle]
                (provider-response! active (.-status event))))))
     (.on pi
          "message_update"
          (guarded
            (fn [_event _ctx]
              (when-let [active @lifecycle]
                (response-update! active)))))
     (.on pi
          "message_end"
          (guarded
            (fn [event _ctx]
              (let [message (.-message event)]
                (when (and @lifecycle
                           (= "assistant" (.-role message)))
                  (assistant-end! @lifecycle message))))))
     (.on pi
          "tool_execution_start"
          (guarded
            (fn [event _ctx]
              (when-let [active @lifecycle]
                (tool-start! active
                             (.-toolCallId event)
                             (.-toolName event)
                             (.-args event))))))
     (.on pi
          "tool_execution_end"
          (guarded
            (fn [event _ctx]
              (when-let [active @lifecycle]
                (tool-end! active
                           (.-toolCallId event)
                           (.-isError event))))))
     (.on pi
          "turn_end"
          (guarded
            (fn [event _ctx]
              (when-let [active @lifecycle]
                (turn-end! active (.-message event))))))
     (.on pi
          "session_shutdown"
          ^:async (fn [_event _ctx]
            (try
              (when-let [active @lifecycle]
                (shutdown-lifecycle! active))
              (catch :default _
                nil))
            (try
              (when-let [shutdown! (:shutdown! @runtime)]
                (await (shutdown!)))
              (catch :default _
                nil))
            (reset! lifecycle nil)
            (reset! runtime nil))))))

(defn default [pi]
  (register-extension! pi))
