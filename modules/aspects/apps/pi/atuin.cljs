(ns pi.extensions.atuin
  (:require ["@earendil-works/pi-coding-agent"
             :refer [createBashTool createLocalBashOperations]]))

(def atuin-author "pi")
(def atuin-timeout-ms 10000)

(defn ^:async start-history [pi cwd command]
  (try
    (let [result (await (.exec pi
                               "atuin"
                               #js ["history" "start" "--author" atuin-author "--" command]
                               #js {:cwd cwd :timeout atuin-timeout-ms}))]
      (when (zero? (.-code result))
        (let [id (.trim (.-stdout result))]
          (when (pos? (.-length id)) id))))
    (catch :default _
      nil)))

(defn ^:async end-history [pi cwd history-id exit-code]
  (try
    (await (.exec pi
                  "atuin"
                  #js ["history" "end" history-id "--exit" (str exit-code)]
                  #js {:cwd cwd :timeout atuin-timeout-ms}))
    (catch :default _
      ;; Atuin failures must never block command execution.
      nil)))

(defn default [pi]
  (let [cwd (js/process.cwd)
        local (createLocalBashOperations)
        tracked-operations
        #js {:exec
             ^:async (fn [command command-cwd options]
               (let [history-id (await (start-history pi command-cwd command))
                     exit-code (atom nil)]
                 (try
                   (let [result (await (.exec local command command-cwd options))]
                     (reset! exit-code (.-exitCode result))
                     result)
                   (finally
                     (when history-id
                       (await
                         (end-history
                           pi
                           command-cwd
                           history-id
                           (or @exit-code
                               (if (and (.-signal options)
                                        (.-aborted (.-signal options)))
                                 130
                                 1)))))))))}]
    (.registerTool pi
                   (createBashTool cwd #js {:operations tracked-operations}))))
