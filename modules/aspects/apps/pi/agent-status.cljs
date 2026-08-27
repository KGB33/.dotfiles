(ns pi.extensions.agent-status
  (:require ["node:crypto" :as crypto]
            ["node:fs" :as fs]
            ["node:os" :as os]
            ["node:path" :as path]))

(def status-dir-name "pi-agent-status")
(def rpc-ready-event "subagents:rpc:v1:ready")
(def rpc-request-event "subagents:rpc:v1:request")
(def poll-ms 1000)
(def request-timeout-ms 1000)

(defn status-dir []
  (if-let [xdg-runtime-dir (not-empty (aget (.-env js/process) "XDG_RUNTIME_DIR"))]
    (.join path xdg-runtime-dir status-dir-name)
    (.join path (.tmpdir os) (str status-dir-name "-" (.getuid js/process)))))

(defn model-name [model]
  (if model
    (str (.-provider model) "/" (.-id model))
    ""))

(defn make-lifecycle []
  (atom {:session-id nil
         :model ""
         :thinking-level ""
         :working false
         :tools {}
         :tool-order []
         :activity ""
         :subagents-available false
         :subagents []}))

(defn status-path [session-id]
  (.join path (status-dir) (str session-id ".json")))

(defn current-activity [{:keys [tools tool-order activity]}]
  (let [active-tools (keep tools tool-order)]
    (if (seq active-tools)
      (.join (clj->js active-tools) ", ")
      activity)))

(defn write-status! [lifecycle ctx]
  (let [tmp-path (atom nil)]
    (try
      (let [{:keys [session-id model thinking-level working subagents-available subagents]
             :as current} @lifecycle
            dir (status-dir)
            file (status-path session-id)
            tmp (.join path dir (str "." session-id "." (.-pid js/process) ".tmp"))
            snapshot {:version 1
                      :session_id session-id
                      :pid (.-pid js/process)
                      :pane (aget (.-env js/process) "TMUX_PANE")
                      :cwd (.-cwd ctx)
                      :state (if working "working" "idle")
                      :activity (current-activity current)
                      :updated_at (js/Math.floor (/ (.now js/Date) 1000))
                      :model model
                      :thinking_level thinking-level
                      :subagents_available subagents-available
                      :subagents subagents}]
        (reset! tmp-path tmp)
        (.mkdirSync fs dir #js {:recursive true})
        (.writeFileSync fs tmp (str (js/JSON.stringify (clj->js snapshot)) "\n") "utf8")
        (.renameSync fs tmp file)
        (reset! tmp-path nil))
      (catch :default _
        (when @tmp-path
          (try
            (.rmSync fs @tmp-path #js {:force true})
            (catch :default _ nil)))
        nil))))

(defn remove-status! [lifecycle]
  (try
    (when-let [session-id (:session-id @lifecycle)]
      (.rmSync fs (status-path session-id) #js {:force true}))
    (catch :default _
      nil)))

(defn publish! [lifecycle ctx changes]
  (swap! lifecycle merge changes)
  (write-status! lifecycle ctx))

(defn nonnegative-integer? [value]
  (and (integer? value) (<= 0 value)))

(defn optional-string? [entry field]
  (or (not (contains? entry field))
      (string? (get entry field))))

(defn valid-tokens? [tokens]
  (and (map? tokens)
       (nonnegative-integer? (:input tokens))
       (nonnegative-integer? (:output tokens))
       (nonnegative-integer? (:total tokens))))

(defn valid-fleet-entry? [entry]
  (and (map? entry)
       (string? (:key entry))
       (not-empty (:key entry))
       (string? (:agent entry))
       (not-empty (:agent entry))
       (every? #(optional-string? entry %) [:role :model :effort :goal])
       (or (not (contains? entry :startedAt))
           (nonnegative-integer? (:startedAt entry)))
       (or (not (contains? entry :tokens))
           (valid-tokens? (:tokens entry)))))

(defn project-fleet-entry [entry]
  (cond-> (select-keys entry [:key :agent :role :model :effort :goal :startedAt])
    (contains? entry :tokens)
    (assoc :tokens (select-keys (:tokens entry) [:input :output :total]))))

(defn fleet-entries [reply]
  (let [fleet (get-in reply [:data :fleet])
        entries (:entries fleet)]
    (when (and (= 1 (:version fleet))
               (vector? entries)
               (nonnegative-integer? (:totalActive fleet))
               (nonnegative-integer? (:omitted fleet))
               (every? valid-fleet-entry? entries))
      (mapv project-fleet-entry entries))))

(defn successful-reply? [reply request-id]
  (and (= 1 (:version reply))
       (= request-id (:requestId reply))
       (= true (:success reply))))

(defn supported-ping? [reply request-id]
  (and (successful-reply? reply request-id)
       (= 1 (get-in reply [:data :capabilities :fleetStatus :version]))))

(defn runtime-options [options]
  (merge {:set-interval (fn [callback delay] (js/setInterval callback delay))
          :clear-interval (fn [timer] (js/clearInterval timer))
          :set-timeout (fn [callback delay] (js/setTimeout callback delay))
          :clear-timeout (fn [timer] (js/clearTimeout timer))
          :request-id (fn [] (.randomUUID crypto))}
         options))

(defn call-disposer! [dispose]
  (when (fn? dispose)
    (try
      (dispose)
      (catch :default _ nil))))

(defn clear-request! [rpc options]
  (when-let [{:keys [unsubscribe timeout]} (:request @rpc)]
    (call-disposer! unsubscribe)
    (when timeout
      ((:clear-timeout options) timeout)))
  (swap! rpc assoc :request nil))

(defn mark-subagents-unavailable! [rpc lifecycle]
  (swap! lifecycle assoc :subagents-available false :subagents [])
  (when-let [ctx (:ctx @rpc)]
    (write-status! lifecycle ctx)))

(defn complete-request! [rpc lifecycle options request-id response callback]
  (when (= request-id (get-in @rpc [:request :id]))
    (let [ignore-response (get-in @rpc [:request :ignore-response])]
      (clear-request! rpc options)
      (when (and (:active @rpc) (not ignore-response))
        (try
          (callback response request-id)
          (catch :default _
            (mark-subagents-unavailable! rpc lifecycle)))))))

(defn request! [pi rpc lifecycle options method callback]
  (when (and (:active @rpc) (nil? (:request @rpc)))
    (let [request-id ((:request-id options))
          reply-event (str "subagents:rpc:v1:reply:" request-id)]
      (try
        (let [unsubscribe (.on (.-events pi) reply-event
                               (fn [raw-reply]
                                 (let [reply (js->clj raw-reply :keywordize-keys true)]
                                   ;; A payload on the right channel still has to correlate.
                                   ;; Ignore mismatches so the actual reply can still arrive.
                                   (when (= request-id (:requestId reply))
                                     (complete-request! rpc lifecycle options request-id
                                                        reply callback)))))
              timeout ((:set-timeout options)
                       (fn []
                         (complete-request! rpc lifecycle options request-id nil callback))
                       request-timeout-ms)]
          (swap! rpc assoc :request {:id request-id
                                     :unsubscribe unsubscribe
                                     :timeout timeout})
          (.emit (.-events pi) rpc-request-event
                 (clj->js {:version 1
                           :requestId request-id
                           :method method
                           :params {}})))
        (catch :default _
          (clear-request! rpc options)
          (mark-subagents-unavailable! rpc lifecycle))))))

(declare request-ping!)

(defn request-status! [pi rpc lifecycle options]
  (when (:fleet-supported @rpc)
    (request! pi rpc lifecycle options "status"
              (fn [reply request-id]
                (if (and reply (successful-reply? reply request-id))
                  (if-let [entries (fleet-entries reply)]
                    (do
                      (swap! lifecycle assoc
                             :subagents-available true
                             :subagents entries)
                      (when-let [ctx (:ctx @rpc)]
                        (write-status! lifecycle ctx)))
                    (mark-subagents-unavailable! rpc lifecycle))
                  (mark-subagents-unavailable! rpc lifecycle))))))

(defn request-ping! [pi rpc lifecycle options]
  (when (nil? (:request @rpc))
    (swap! rpc assoc :rediscover false)
    (request! pi rpc lifecycle options "ping"
            (fn [reply request-id]
              (let [supported (and reply (supported-ping? reply request-id))]
                (swap! rpc assoc :fleet-supported supported)
                (when-not supported
                  (mark-subagents-unavailable! rpc lifecycle)))))))

(defn dispose-rpc! [rpc options]
  (clear-request! rpc options)
  (when-let [timer (:interval @rpc)]
    ((:clear-interval options) timer))
  (call-disposer! (:ready-unsubscribe @rpc))
  (swap! rpc assoc
         :active false
         :ctx nil
         :fleet-supported false
         :rediscover false
         :interval nil
         :ready-unsubscribe nil))

(defn start-rpc! [pi rpc lifecycle options ctx]
  (dispose-rpc! rpc options)
  (swap! rpc assoc :active true :ctx ctx)
  (try
    (let [ready-unsubscribe
          (.on (.-events pi) rpc-ready-event
               (fn [_]
                 (when (:active @rpc)
                   ;; A ready event can race an older request. Keep its resources
                   ;; until reply/timeout so a rediscovery ping never overlaps it.
                   (swap! rpc
                          (fn [current]
                            (cond-> (assoc current
                                           :fleet-supported false
                                           :rediscover true)
                              (:request current)
                              (assoc-in [:request :ignore-response] true))))
                   (mark-subagents-unavailable! rpc lifecycle)
                   (when (nil? (:request @rpc))
                     (request-ping! pi rpc lifecycle options)))))
          interval ((:set-interval options)
                    (fn []
                      (if (:rediscover @rpc)
                        (request-ping! pi rpc lifecycle options)
                        (request-status! pi rpc lifecycle options)))
                    poll-ms)]
      (swap! rpc assoc
             :ready-unsubscribe ready-unsubscribe
             :interval interval)
      (request-ping! pi rpc lifecycle options))
    (catch :default _
      (mark-subagents-unavailable! rpc lifecycle))))

(defn register!
  ([pi] (register! pi {}))
  ([pi option-overrides]
   (when (not-empty (aget (.-env js/process) "TMUX_PANE"))
     (let [lifecycle (make-lifecycle)
           options (runtime-options option-overrides)
           rpc (atom {:active false
                      :ctx nil
                      :fleet-supported false
                      :rediscover false
                      :interval nil
                      :ready-unsubscribe nil
                      :request nil})]
       (.on pi "session_start"
            (fn [_event ctx]
              (reset! lifecycle
                      {:session-id (.getSessionId (.-sessionManager ctx))
                       :model (model-name (.-model ctx))
                       :thinking-level (or (.-thinkingLevel ctx) "")
                       :working false
                       :tools {}
                       :tool-order []
                       :activity "session started"
                       :subagents-available false
                       :subagents []})
              (write-status! lifecycle ctx)
              (start-rpc! pi rpc lifecycle options ctx)))

       (.on pi "agent_start"
            (fn [_event ctx]
              (publish! lifecycle ctx {:working true
                                       :tools {}
                                       :tool-order []
                                       :activity "thinking"})))

       (.on pi "tool_execution_start"
            (fn [event ctx]
              (let [tool-call-id (.-toolCallId event)
                    tool-name (.-toolName event)]
                (swap! lifecycle
                       (fn [current]
                         (-> current
                             (assoc :working true :activity "thinking")
                             (assoc-in [:tools tool-call-id] tool-name)
                             (update :tool-order
                                     (fn [order]
                                       (if (some #(= tool-call-id %) order)
                                         order
                                         (conj order tool-call-id)))))))
                (write-status! lifecycle ctx))))

       (.on pi "tool_execution_end"
            (fn [event ctx]
              (let [tool-call-id (.-toolCallId event)]
                (swap! lifecycle
                       (fn [current]
                         (-> current
                             (update :tools dissoc tool-call-id)
                             (update :tool-order
                                     (fn [order] (vec (remove #(= tool-call-id %) order))))
                             (assoc :working true :activity "thinking"))))
                (write-status! lifecycle ctx))))

       (.on pi "agent_settled"
            (fn [_event ctx]
              (publish! lifecycle ctx {:working false
                                       :tools {}
                                       :tool-order []
                                       :activity "turn complete"})))

       (.on pi "model_select"
            (fn [event ctx]
              (publish! lifecycle ctx {:model (model-name (.-model event))})))

       (.on pi "thinking_level_select"
            (fn [event ctx]
              (publish! lifecycle ctx {:thinking-level (.-level event)})))

       (.on pi "session_shutdown"
            (fn [_event _ctx]
              (dispose-rpc! rpc options)
              (remove-status! lifecycle)
              (reset! lifecycle (deref (make-lifecycle)))))))))

(defn default [pi]
  (register! pi))
