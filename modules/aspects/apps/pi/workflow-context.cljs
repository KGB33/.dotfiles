(ns pi.workflow-context
  (:require ["node:fs" :refer [constants]]
            ["node:fs/promises" :refer [access realpath stat]]
            ["node:os" :refer [homedir]]
            ["node:path" :refer [join]]))

(def workspace-error
  "Set NEORG_WORKSPACE_PATH to a readable Neorg workspace directory.")

(def context-label "Host-resolved workflow context:")
(def workflow-invocation-pattern #"^/skill:(cartographer|scout)(?=$|\s)")

(defn workflow-invocation? [text]
  (.test workflow-invocation-pattern text))

(defn expand-home [path]
  (cond
    (= path "~") (homedir)
    (.startsWith path "~/") (join (homedir) (.slice path 2))
    :else path))

(defn ^:async resolve-workspace []
  (let [configured (.-NEORG_WORKSPACE_PATH (.-env js/process))]
    (when (and configured (pos? (.-length configured)))
      (try
        (let [canonical (await (realpath (expand-home configured)))
              metadata (await (stat canonical))]
          (when (.isDirectory metadata)
            (await (access canonical
                           (bit-or (.-R_OK constants) (.-W_OK constants))))
            canonical))
        (catch :default _
          nil)))))

(defn failure-result [ctx]
  (if (.-hasUI ctx)
    (.notify (.-ui ctx) workspace-error "error")
    (.error js/console workspace-error))
  #js {:action "handled"})

(defn context-block [workspace]
  (str context-label
       "\n- Neorg workspace: " workspace
       "\n- Maps directory: " (join workspace "maps")))

(defn default [pi]
  (.on pi
       "input"
       ^:async
       (fn [event ctx]
         (let [text (.-text event)]
           (if-not (workflow-invocation? text)
             #js {:action "continue"}
             (if-let [workspace (await (resolve-workspace))]
               (if (.includes text context-label)
                 #js {:action "continue"}
                 #js {:action "transform"
                      :text (str text "\n\n" (context-block workspace))})
               (failure-result ctx)))))))
