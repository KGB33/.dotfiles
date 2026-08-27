(ns pi.extensions.agent-status-test
  (:require [pi.extensions.agent-status :as status]
            ["node:assert/strict" :as assert]
            ["node:fs" :as fs]
            ["node:os" :as os]
            ["node:path" :as path]
            ["node:module" :refer [syncBuiltinESMExports]]))

(defn snapshot [dir session-id]
  (js->clj
    (js/JSON.parse
      (.readFileSync fs (.join path dir "pi-agent-status" (str session-id ".json")) "utf8"))
    :keywordize-keys true))

(defn fake-event-bus []
  (let [listeners (atom {})
        emitted (atom [])
        bus #js {:on (fn [event handler]
                       (swap! listeners update event (fnil conj []) handler)
                       (fn []
                         (swap! listeners update event
                                (fn [handlers]
                                  (vec (remove #(identical? handler %) handlers))))))
                 :emit (fn [event data]
                         (swap! emitted conj [event data])
                         (doseq [handler (get @listeners event [])]
                           (handler data)))}]
    {:bus bus :listeners listeners :emitted emitted}))

(defn fake-scheduler []
  (let [next-id (atom 0)
        intervals (atom {})
        timeouts (atom {})
        interval-delays (atom [])
        timeout-delays (atom [])
        allocate! (fn [] (swap! next-id inc))]
    {:intervals intervals
     :timeouts timeouts
     :interval-delays interval-delays
     :timeout-delays timeout-delays
     :options {:set-interval (fn [callback delay]
                              (let [id (allocate!)]
                                (swap! intervals assoc id callback)
                                (swap! interval-delays conj delay)
                                id))
               :clear-interval (fn [id] (swap! intervals dissoc id))
               :set-timeout (fn [callback delay]
                              (let [id (allocate!)]
                                (swap! timeouts assoc id callback)
                                (swap! timeout-delays conj delay)
                                id))
               :clear-timeout (fn [id] (swap! timeouts dissoc id))
               :request-id (let [request-number (atom 0)]
                             (fn [] (str "request-" (swap! request-number inc))))}}))

(defn run-interval! [scheduler]
  (doseq [callback (vals @(:intervals scheduler))]
    (callback)))

(defn run-timeout! [scheduler]
  (when-let [[id callback] (first @(:timeouts scheduler))]
    (swap! (:timeouts scheduler) dissoc id)
    (callback)))

(defn fixture
  ([] (fixture (fake-scheduler)))
  ([scheduler]
   (let [root (.mkdtempSync fs (.join path (.tmpdir os) "pi-agent-status-test-"))
         handlers (atom {})
         events (fake-event-bus)
         pi #js {:on (fn [event handler] (swap! handlers assoc event handler))
                 :events (:bus events)}
         manager #js {:getSessionId (fn [] "session-1234-full")}
         ctx #js {:cwd "/work/example-project"
                  :model #js {:provider "openai" :id "gpt-5.6"}
                  :thinkingLevel "high"
                  :sessionManager manager}]
     (aset (.-env js/process) "XDG_RUNTIME_DIR" root)
     (aset (.-env js/process) "TMUX_PANE" "%7")
     (if scheduler
       (status/register! pi (:options scheduler))
       (status/register! pi))
     {:root root
      :handlers handlers
      :ctx ctx
      :session-id "session-1234-full"
      :events events
      :scheduler scheduler})))

(defn emit! [{:keys [handlers ctx]} event data]
  ((get @handlers event) (clj->js data) ctx))

(defn requests [{:keys [events]}]
  (->> @(:emitted events)
       (filter #(= "subagents:rpc:v1:request" (first %)))
       (map (fn [[_ data]] (js->clj data :keywordize-keys true)))
       vec))

(defn reply! [{:keys [events]} request values]
  (.emit (:bus events)
         (str "subagents:rpc:v1:reply:" (:requestId request))
         (clj->js (merge {:version 1
                          :requestId (:requestId request)
                          :success true}
                         values))))

(def supported-ping
  {:data {:capabilities {:fleetStatus {:version 1 :futureField "ignored"}}}})

(defn fleet-data [entries]
  {:data {:fleet {:version 1
                  :entries entries
                  :totalActive (count entries)
                  :omitted 0}}})

(defn lifecycle-test []
  (let [{:keys [root session-id] :as f} (fixture)]
    (try
      (emit! f "session_start" {})
      (let [initial (snapshot root session-id)]
        (.equal assert
                (= (select-keys initial [:version :session_id :pid :pane :cwd :state
                                         :activity :model :thinking_level
                                         :subagents_available :subagents])
                   {:version 1
                    :session_id session-id
                    :pid (.-pid js/process)
                    :pane "%7"
                    :cwd "/work/example-project"
                    :state "idle"
                    :activity "session started"
                    :model "openai/gpt-5.6"
                    :thinking_level "high"
                    :subagents_available false
                    :subagents []})
                true)
        (.equal assert (number? (:updated_at initial)) true))

      (emit! f "agent_start" {})
      (.equal assert (:state (snapshot root session-id)) "working")
      (.equal assert (:activity (snapshot root session-id)) "thinking")

      (emit! f "tool_execution_start" {:toolCallId "a" :toolName "read"})
      (emit! f "tool_execution_start" {:toolCallId "b" :toolName "bash"})
      (.equal assert (:activity (snapshot root session-id)) "read, bash")
      (emit! f "tool_execution_end" {:toolCallId "a" :toolName "read"})
      (let [during-sibling (snapshot root session-id)]
        (.equal assert (:state during-sibling) "working")
        (.equal assert (:activity during-sibling) "bash"))
      (emit! f "tool_execution_end" {:toolCallId "b" :toolName "bash"})
      (.equal assert (:state (snapshot root session-id)) "working")
      (.equal assert (:activity (snapshot root session-id)) "thinking")

      (emit! f "agent_settled" {})
      (.equal assert (:state (snapshot root session-id)) "idle")
      (.equal assert (:activity (snapshot root session-id)) "turn complete")
      (finally
        (.rmSync fs root #js {:recursive true :force true})))))

(defn model-and-thinking-test []
  (let [{:keys [root session-id] :as f} (fixture)]
    (try
      (emit! f "session_start" {})
      (emit! f "model_select" {:model {:provider "anthropic" :id "claude-opus"}})
      (let [after-model (snapshot root session-id)]
        (.equal assert (:model after-model) "anthropic/claude-opus")
        (.equal assert (:thinking_level after-model) "high"))
      (emit! f "thinking_level_select" {:level "xhigh"})
      (let [after-thinking (snapshot root session-id)]
        (.equal assert (:model after-thinking) "anthropic/claude-opus")
        (.equal assert (:thinking_level after-thinking) "xhigh"))
      (finally
        (.rmSync fs root #js {:recursive true :force true})))))

(defn atomic-cleanup-and-failure-test []
  (let [{:keys [root session-id] :as f} (fixture)]
    (try
      (emit! f "session_start" {})
      (let [dir (.join path root "pi-agent-status")
            file (.join path dir (str session-id ".json"))
            old-snapshot (.readFileSync fs file "utf8")
            original-rename (.-renameSync (.-default fs))]
        (.equal assert (= (js->clj (.readdirSync fs dir)) [(str session-id ".json")]) true)
        ;; Fault-inject the Node filesystem boundary after the temporary write.
        ;; The destination must remain the previous complete snapshot, and the
        ;; failed temporary file must be cleaned up.
        (set! (.-renameSync (.-default fs))
              (fn [_source _destination]
                (throw (js/Error. "forced rename failure"))))
        (syncBuiltinESMExports)
        (try
          (emit! f "agent_start" {})
          (finally
            (set! (.-renameSync (.-default fs)) original-rename)
            (syncBuiltinESMExports)))
        (.equal assert (.readFileSync fs file "utf8") old-snapshot)
        (.equal assert (= (js->clj (.readdirSync fs dir)) [(str session-id ".json")]) true))
      (emit! f "session_shutdown" {})
      (.equal assert (.existsSync fs (.join path root "pi-agent-status" (str session-id ".json"))) false)

      ;; A non-directory runtime path makes mkdir/write fail. The extension must fail open.
      (.writeFileSync fs (.join path root "not-a-directory") "x")
      (aset (.-env js/process) "XDG_RUNTIME_DIR" (.join path root "not-a-directory"))
      (.doesNotThrow assert (fn [] (emit! f "session_start" {})))
      (.doesNotThrow assert (fn [] (emit! f "session_shutdown" {})))
      (finally
        (.rmSync fs root #js {:recursive true :force true})))))

(defn rpc-projection-and-non-overlap-test []
  (let [scheduler (fake-scheduler)
        {:keys [root session-id events] :as f} (fixture scheduler)]
    (try
      (emit! f "session_start" {})
      (let [ping (first (requests f))]
        (do
          (.equal assert
                  (= (select-keys ping [:version :requestId :method :params])
                     {:version 1 :requestId "request-1" :method "ping" :params {}})
                  true)
          (.equal assert (= @(:interval-delays scheduler) [1000]) true)
          (.equal assert (= @(:timeout-delays scheduler) [1000]) true)
          (reply! f ping {:requestId "another-request" :data (:data supported-ping)})
          (.equal assert (count (requests f)) 1)
          (.equal assert (:subagents_available (snapshot root session-id)) false))

        (reply! f ping supported-ping)
        (run-interval! scheduler)
        (let [status-request (last (requests f))
              child {:key "fleet-1"
                     :agent "worker"
                     :role "implementation"
                     :model "openai/gpt-5.6"
                     :effort "high"
                     :goal "Implement the status slice"
                     :startedAt 9990000
                     :tokens {:input 10 :output 20 :total 30}
                     :privateId "must-not-leak"}]
          (.equal assert (:method status-request) "status")
          (run-interval! scheduler)
          (run-interval! scheduler)
          (.equal assert (count (requests f)) 2 "a delayed status reply prevents overlap")
          (reply! f status-request (fleet-data [child]))
          (let [current (snapshot root session-id)]
            (.equal assert (:subagents_available current) true)
            (.equal assert
                    (= (:subagents current) [(dissoc child :privateId)])
                    true
                    "only public Fleet display fields are projected")))

        (do
          (run-interval! scheduler)
          (let [empty-request (last (requests f))]
            (reply! f empty-request (fleet-data []))
            (.equal assert (:subagents_available (snapshot root session-id)) true)
            (.equal assert (= (:subagents (snapshot root session-id)) []) true)))

        (do
          (run-interval! scheduler)
          (let [failed-request (last (requests f))]
            (reply! f failed-request {:success false :error {:code "failed" :message "no status"}})
            (.equal assert (:subagents_available (snapshot root session-id)) false)
            (.equal assert (= (:subagents (snapshot root session-id)) []) true))
          (run-interval! scheduler)
          (let [malformed-request (last (requests f))]
            (reply! f malformed-request {:data {:fleet {:version 1 :entries "not-an-array"
                                                        :totalActive 0 :omitted 0}}})
            (.equal assert (:subagents_available (snapshot root session-id)) false))
          (run-interval! scheduler)
          (let [unsupported-fleet-request (last (requests f))]
            (reply! f unsupported-fleet-request {:data {:fleet {:version 2 :entries []
                                                                :totalActive 0 :omitted 0}}})
            (.equal assert (:subagents_available (snapshot root session-id)) false))
          (run-interval! scheduler)
          (run-timeout! scheduler)
          (.equal assert (:subagents_available (snapshot root session-id)) false)
          (.equal assert (= (:subagents (snapshot root session-id)) []) true))

        (do
          (.emit (:bus events) "subagents:rpc:v1:ready" #js {})
          (.equal assert (:method (last (requests f))) "ping")))
      (finally
        (.rmSync fs root #js {:recursive true :force true})))))

(defn unsupported-capability-test []
  (doseq [ping-data [{:data {:capabilities {}}}
                     {:data {:capabilities {:fleetStatus {:version 2}}}}]]
    (let [scheduler (fake-scheduler)
          {:keys [root session-id] :as f} (fixture scheduler)]
      (try
        (emit! f "session_start" {})
        (reply! f (first (requests f)) ping-data)
        (run-interval! scheduler)
        (.equal assert (count (requests f)) 1 "unsupported Fleet capability is not polled")
        (.equal assert (:subagents_available (snapshot root session-id)) false)
        (.equal assert (= (:subagents (snapshot root session-id)) []) true)
        (finally
          (.rmSync fs root #js {:recursive true :force true}))))))

(defn rpc-disposal-test []
  (let [scheduler (fake-scheduler)
        {:keys [root session-id events] :as f} (fixture scheduler)]
    (try
      (emit! f "session_start" {})
      (reply! f (first (requests f)) supported-ping)
      (run-interval! scheduler)
      (.equal assert (count @(:intervals scheduler)) 1)
      (.equal assert (count @(:timeouts scheduler)) 1)
      (.equal assert (pos? (reduce + (map count (vals @(:listeners events))))) true)

      ;; Owner reload discovery must not overlap the delayed status request.
      (let [request-count (count (requests f))]
        (.emit (:bus events) "subagents:rpc:v1:ready" #js {})
        (.equal assert (count (requests f)) request-count)
        (.equal assert (:subagents_available (snapshot root session-id)) false)
        (run-timeout! scheduler)
        (run-interval! scheduler)
        (.equal assert (:method (last (requests f))) "ping"))

      (emit! f "session_shutdown" {})
      (.equal assert (= @(:intervals scheduler) {}) true)
      (.equal assert (= @(:timeouts scheduler) {}) true)
      (.equal assert (reduce + (map count (vals @(:listeners events)))) 0)
      (.equal assert (.existsSync fs (.join path root "pi-agent-status" (str session-id ".json"))) false)
      (.doesNotThrow assert (fn [] (emit! f "session_shutdown" {})) "shutdown cleanup is idempotent")
      (let [request-count (count (requests f))]
        (.emit (:bus events) "subagents:rpc:v1:ready" #js {})
        (.equal assert (count (requests f)) request-count "disposed ready listener stays inactive"))
      (finally
        (.rmSync fs root #js {:recursive true :force true})))))

(defn no-tmux-test []
  (let [handlers (atom {})
        pi #js {:on (fn [event handler] (swap! handlers assoc event handler))}]
    (js-delete (.-env js/process) "TMUX_PANE")
    (status/register! pi)
    (.equal assert (= @handlers {}) true)))

(lifecycle-test)
(model-and-thinking-test)
(atomic-cleanup-and-failure-test)
(rpc-projection-and-non-overlap-test)
(unsupported-capability-test)
(rpc-disposal-test)
(no-tmux-test)
(println "pi agent status tests passed")
