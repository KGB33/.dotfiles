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
   :state (atom {:turn nil
                 :tools {}
                 :pending-skills {}
                 :active-skills {}
                 :skill-paths {}})})

(defn adapter-call! [lifecycle operation & args]
  (try
    (apply (get (:adapter lifecycle) operation) args)
    (catch :default _
      nil)))

(defn skill-attributes [lifecycle]
  (let [active-skills (:active-skills @(:state lifecycle))
        names (vec (sort (keys active-skills)))
        triggers (set (vals active-skills))]
    (if (seq names)
      {"pi.skill.active" true
       "pi.skill.names" names
       "pi.skill.trigger" (if (> (count triggers) 1)
                            "mixed"
                            (first triggers))}
      {})))

(defn apply-skill-attributes! [lifecycle]
  (let [{:keys [turn tools]} @(:state lifecycle)
        attributes (skill-attributes lifecycle)
        handles (concat [(:root turn)
                         (:prepare turn)
                         (:request turn)
                         (:headers turn)
                         (:stream turn)]
                        (vals tools))]
    (when (seq attributes)
      (doseq [handle handles]
        (when handle
          (adapter-call! lifecycle :set-attributes! handle attributes))))))

(defn activate-skill! [lifecycle skill-name trigger]
  (when skill-name
    (swap! (:state lifecycle)
           update
           :active-skills
           (fn [active-skills]
             (if (contains? active-skills skill-name)
               active-skills
               (assoc active-skills skill-name trigger))))
    (apply-skill-attributes! lifecycle)))

(defn explicit-skill-name [text]
  (when (string? text)
    (when-let [match (re-find #"^/skill:([a-z0-9-]+)(?:\s|$)" text)]
      (nth match 1))))

(defn capture-input-skill! [lifecycle text]
  (let [skill-name (explicit-skill-name text)]
    (swap! (:state lifecycle)
           assoc
           :pending-skills
           (if skill-name {skill-name "explicit"} {}))))

(defn canonical-path [cwd value]
  (when (string? value)
    (let [value (if (.startsWith value "@") (.slice value 1) value)]
      (.normalize path (.resolve path cwd value)))))

(defn begin-agent-run! [lifecycle event ctx commands]
  (let [options (.-systemPromptOptions event)
        skills (if-let [loaded-skills (when options (.-skills options))]
                 (array-seq loaded-skills)
                 [])
        commands (if commands (array-seq commands) [])
        skill-records
        (concat
          (map (fn [skill]
                 (let [source-info (.-sourceInfo skill)]
                   {:name (.-name skill)
                    :path (or (.-filePath skill)
                              (when source-info (.-path source-info)))}))
               skills)
          (keep (fn [command]
                  (let [command-name (.-name command)
                        source-info (.-sourceInfo command)]
                    (when (and (= "skill" (.-source command))
                               (string? command-name)
                               (.startsWith command-name "skill:"))
                      {:name (.slice command-name 6)
                       :path (when source-info (.-path source-info))})))
                commands))
        cwd (.-cwd ctx)
        skill-paths
        (reduce (fn [result skill]
                  (let [canonical (canonical-path cwd (:path skill))
                        skill-name (:name skill)]
                    (if (and canonical skill-name)
                      (assoc result canonical skill-name)
                      result)))
                {}
                skill-records)
        skill-names (set (vals skill-paths))
        pending-skills (:pending-skills @(:state lifecycle))
        active-skills (select-keys pending-skills skill-names)]
    (swap! (:state lifecycle)
           assoc
           :pending-skills {}
           :active-skills active-skills
           :skill-paths skill-paths)
    (apply-skill-attributes! lifecycle)))

(defn activate-read-skill! [lifecycle cwd tool-name args]
  (when (= "read" tool-name)
    (let [read-path (when args (aget args "path"))
          canonical (canonical-path cwd read-path)
          skill-name (get-in @(:state lifecycle) [:skill-paths canonical])]
      (activate-skill! lifecycle skill-name "automatic"))))

(defn clear-agent-skills! [lifecycle]
  (swap! (:state lifecycle)
         assoc
         :pending-skills {}
         :active-skills {}))

(defn start-span! [lifecycle name attributes parent]
  (adapter-call! lifecycle
                 :start-span!
                 name
                 (compact-attributes attributes)
                 parent))

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
  (when-let [root (start-span! lifecycle
                               "pi.turn"
                               (merge attributes (skill-attributes lifecycle))
                               nil)]
    (let [prepare (start-span! lifecycle
                               "pi.prepare"
                               (skill-attributes lifecycle)
                               root)]
      (swap! (:state lifecycle)
             assoc
             :turn
             {:root root
              :prepare prepare
              :request nil
              :headers nil
              :stream nil
              :first-update? false}
             :tools {}))))

(defn provider-request! [lifecycle attributes]
  (when-let [turn (:turn @(:state lifecycle))]
    (when-not (:request turn)
      (finish-span! lifecycle (:prepare turn) nil)
      (let [turn (assoc turn :prepare nil)]
        (swap! (:state lifecycle) assoc :turn turn)
        (when-let [request (start-span! lifecycle
                                        "gen_ai.request"
                                        (merge attributes
                                               (skill-attributes lifecycle))
                                        (:root turn))]
          (let [headers (start-span! lifecycle
                                     "pi.provider.wait_headers"
                                     (skill-attributes lifecycle)
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
                                      (skill-attributes lifecycle)
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
                          (merge
                            {"gen_ai.tool.name" tool-name
                             "gen_ai.tool.call.id" tool-call-id
                             "gen_ai.tool.call.arguments"
                             (serialize-tool-arguments args)}
                            (skill-attributes lifecycle))
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
  (close-active-turn! lifecycle "session_shutdown"))

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
                    (reset! lifecycle active))
                  (catch :default _
                    (when (and (.-hasUI ctx)
                               (compare-and-set! warned? false true))
                      (.notify (.-ui ctx)
                               "OTEL tracing disabled: initialization failed"
                               "warning"))))))))
     (.on pi
          "input"
          (guarded
            (fn [event _ctx]
              (when-let [active @lifecycle]
                (capture-input-skill! active (.-text event))))))
     (.on pi
          "before_agent_start"
          (guarded
            (fn [event ctx]
              (when-let [active @lifecycle]
                (begin-agent-run! active event ctx (.getCommands pi))))))
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
            (fn [event ctx]
              (when-let [active @lifecycle]
                (activate-read-skill! active
                                      (.-cwd ctx)
                                      (.-toolName event)
                                      (.-args event))
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
          "agent_settled"
          (guarded
            (fn [_event _ctx]
              (when-let [active @lifecycle]
                (clear-agent-skills! active)))))
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
