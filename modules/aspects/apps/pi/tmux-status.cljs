(ns pi.extensions.tmux-status
  (:require ["node:fs" :as fs]
            ["node:os" :as os]
            ["node:path" :as path]))

;; Keep using the existing directory so Television can show Claude Code and Pi
;; sessions together.
(def status-dir-name "claude-tmux")

(defn status-dir []
  (if-let [xdg-runtime-dir (not-empty (aget (.-env js/process) "XDG_RUNTIME_DIR"))]
    (.join path xdg-runtime-dir status-dir-name)
    (.join path
           (.tmpdir os)
           (str status-dir-name "-" (.getuid js/process)))))

(defn status-path [ctx]
  (let [session-id (.getSessionId (.-sessionManager ctx))]
    (.join path (status-dir) (str "pi-" session-id ".json"))))

(defn write-status! [ctx state msg]
  (try
    (let [dir (status-dir)
          file (status-path ctx)
          tmp (.join path
                     dir
                     (str ".tmp."
                          (.-pid js/process)
                          "."
                          (.now js/Date)
                          "."
                          (rand-int 1000000)))
          status #js {:agent "Pi"
                      :pane (aget (.-env js/process) "TMUX_PANE")
                      :cwd (.-cwd ctx)
                      :state state
                      :msg msg
                      :ts (js/Math.floor (/ (.now js/Date) 1000))}]
      (.mkdirSync fs dir #js {:recursive true})
      (.writeFileSync fs tmp (str (js/JSON.stringify status) "\n") "utf8")
      (.renameSync fs tmp file))
    (catch :default _
      ;; Status integration must never interfere with the agent.
      nil)))

(defn remove-status! [ctx]
  (try
    (.rmSync fs (status-path ctx) #js {:force true})
    (catch :default _
      nil)))

(defn default [pi]
  ;; As with the Claude Code hook, only publish sessions running in tmux.
  (when (not-empty (aget (.-env js/process) "TMUX_PANE"))
    (.on pi "session_start"
         (fn [_event ctx]
           (write-status! ctx "waiting" "session started")))

    (.on pi "agent_start"
         (fn [_event ctx]
           (write-status! ctx "busy" "")))

    (.on pi "tool_execution_end"
         (fn [_event ctx]
           (write-status! ctx "busy" "")))

    (.on pi "agent_settled"
         (fn [_event ctx]
           (write-status! ctx "waiting" "turn complete")))

    (.on pi "session_shutdown"
         (fn [_event ctx]
           (remove-status! ctx)))))
