(ns preview
  (:require [babashka.process :as process]
            [cheshire.core :as json]
            [clojure.java.io :as io]
            [clojure.string :as str]))

(def status-dir-name "pi-agent-status")

(defn user-id []
  (try
    (str/trim (:out (process/shell {:out :string :err :string} "id" "-u")))
    (catch Exception _
      (System/getProperty "user.name"))))

(defn status-dir []
  (if-let [runtime-dir (not-empty (System/getenv "XDG_RUNTIME_DIR"))]
    (str (io/file runtime-dir status-dir-name))
    (let [tmp-dir (or (some #(not-empty (System/getenv %)) ["TMPDIR" "TMP" "TEMP"])
                      "/tmp")]
      (str (io/file tmp-dir (str status-dir-name "-" (user-id)))))))

(defn default-tmux [& args]
  (let [result (apply process/shell {:out :string :err :string :continue true}
                      "tmux" args)]
    {:exit (:exit result) :out (:out result)}))

(defn process-alive? [pid]
  (try
    (if-let [handle (.orElse (java.lang.ProcessHandle/of (long pid)) nil)]
      (.isAlive handle)
      false)
    (catch Exception _
      false)))

(defn format-age [now updated-at]
  (let [age (max 0 (- now updated-at))]
    (cond
      (>= age 3600) (str (quot age 3600) "h")
      (>= age 60) (str (quot age 60) "m")
      :else (str age "s"))))

(defn nonnegative-integer? [value]
  (and (integer? value) (<= 0 value)))

(defn optional-string? [value field]
  (or (not (contains? value field))
      (string? (get value field))))

(defn valid-tokens? [tokens]
  (and (map? tokens)
       (nonnegative-integer? (:input tokens))
       (nonnegative-integer? (:output tokens))
       (nonnegative-integer? (:total tokens))))

(defn valid-subagent? [subagent]
  (and (map? subagent)
       (string? (:key subagent))
       (not-empty (:key subagent))
       (string? (:agent subagent))
       (not-empty (:agent subagent))
       (every? #(optional-string? subagent %) [:role :model :effort :goal])
       (or (not (contains? subagent :startedAt))
           (nonnegative-integer? (:startedAt subagent)))
       (or (not (contains? subagent :tokens))
           (valid-tokens? (:tokens subagent)))))

(defn valid-snapshot? [snapshot]
  (and (= 1 (:version snapshot))
       (string? (:session_id snapshot))
       (integer? (:pid snapshot))
       (string? (:pane snapshot))
       (string? (:cwd snapshot))
       (contains? #{"idle" "working"} (:state snapshot))
       (string? (:activity snapshot))
       (integer? (:updated_at snapshot))
       (string? (:model snapshot))
       (string? (:thinking_level snapshot))
       (boolean? (:subagents_available snapshot))
       (vector? (:subagents snapshot))
       (every? valid-subagent? (:subagents snapshot))))

(defn read-snapshot [file]
  (try
    (let [snapshot (json/parse-string (slurp file) true)]
      (when (valid-snapshot? snapshot) snapshot))
    (catch Exception _
      nil)))

(defn remove-file! [file]
  (try
    (io/delete-file file true)
    (catch Exception _
      nil)))

(defn command-output [result]
  (when (zero? (:exit result))
    (str/trim (:out result))))

(defn snapshot-files [dir]
  (let [directory (io/file dir)]
    (if (.isDirectory directory)
      (filter #(and (.isFile %) (str/ends-with? (.getName %) ".json"))
              (or (.listFiles directory) []))
      [])))

(defn matching-parents! [session {:keys [dir pid-alive? tmux]}]
  (keep
    (fn [file]
      (when-let [snapshot (read-snapshot file)]
        (cond
          (not (pid-alive? (:pid snapshot)))
          (do (remove-file! file) nil)

          :else
          (if-let [pane-session
                   (command-output (tmux "display-message" "-pt" (:pane snapshot) "#S"))]
            (when (= session pane-session)
              (assoc snapshot
                     :location
                     (or (command-output
                           (tmux "display-message" "-pt" (:pane snapshot) "#I.#P"))
                         "?")))
            (do (remove-file! file) nil)))))
    (snapshot-files dir)))

(def bold "\u001b[1m")
(def dim "\u001b[2m")
(def green "\u001b[32m")
(def yellow "\u001b[33m")
(def reset "\u001b[0m")

(defn child-token-text [{:keys [input output total]}]
  (format "%d tok (%d in, %d out)" total input output))

(defn child-line [child now]
  (let [name (str (:agent child)
                  (when-let [role (:role child)] (str " (" role ")")))
        details (cond-> []
                  (:model child) (conj (:model child))
                  (:effort child) (conj (:effort child))
                  (:goal child) (conj (:goal child))
                  (contains? child :startedAt) (conj (format-age now (quot (:startedAt child) 1000)))
                  (contains? child :tokens) (conj (child-token-text (:tokens child))))]
    (str "    ↳ " name
         (when (seq details)
           (str "  " dim (str/join " · " details) reset)))))

(defn parent-lines [parent now]
  (let [badge (if (= "idle" (:state parent))
                (str yellow "○ IDLE" reset "   ")
                (str green "● WORKING" reset))
        project (.getName (io/file (:cwd parent)))
        age (format-age now (:updated_at parent))
        parent-header [(format "%s  %s:%s" badge project (:location parent))
                       (str "  " (:model parent) " · " (:thinking_level parent)
                            "  " dim (:activity parent) " · " age " ago" reset)
                       (str "  session " (:session_id parent))]
        subagent-lines (if (:subagents_available parent)
                         (mapv #(child-line % now) (:subagents parent))
                         [(str "    " yellow "subagents unavailable" reset)])]
    (into parent-header subagent-lines)))

(defn preview-text
  ([session] (preview-text session {}))
  ([session options]
   (let [now (or (:now options) (quot (System/currentTimeMillis) 1000))
         options (merge {:dir (status-dir)
                         :pid-alive? process-alive?
                         :tmux default-tmux}
                        options)
         parents (matching-parents! session options)
         agent-lines (if (seq parents)
                       (mapcat #(parent-lines % now) parents)
                       [(str dim "no agents" reset)])
         windows (command-output ((:tmux options)
                                  "list-windows" "-t" session "-F"
                                  "#{?window_active,*, } #I: #W (#{window_panes} panes)"))]
     (str/join "\n"
               (concat [(str bold "Agents" reset)]
                       agent-lines
                       ["" (str bold "Windows" reset) (or windows "") ""])))))

(defn -main [& args]
  (if-let [session (first args)]
    (print (preview-text session))
    (do
      (binding [*out* *err*]
        (println "usage: tss-preview <session>"))
      (System/exit 2))))

(when (= *file* (System/getProperty "babashka.file"))
  (apply -main *command-line-args*))
