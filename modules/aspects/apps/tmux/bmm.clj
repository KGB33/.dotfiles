(ns bmm
  (:require
   [clojure.string :as str]
   [clojure.core.match :refer [match]]
   [babashka.process :refer [process shell]]))

(defn normalize-session-name [n]
  (str/replace n "." "_"))

; There are two possible options:
;   * The user is in a worktree:
;        `/home/kgb33/Code/nasty/worktrees/main`
;   * The user is in a standard repo:
;        `/home/kgb33/Code/hmm/.git`
; Because there is only zero or one element to the right of our anchor element,
; Its easiest to revese the list before massing it to the fucntion and match 'backward'
; anchor \/ , repo \/
; i.e. [".git", "hmm", "Code", ...]
(defn parse-repo [parts]
  (match (vec parts)
    [_ "worktrees" r & _] r
    [".git" r & _] r
    :else "unk"))

(defn get-repo []
  (let [{:keys [out]} (shell {:out :string}
                             "git" "rev-parse" "--path-format=absolute" "--git-dir")]
    (-> out
        (str/trim)
        (str/split #"/")
        (reverse)
        (parse-repo))))

(defn get-branch []
  (let [{:keys [out]} (shell {:out :string} "git" "rev-parse" "--abbrev-ref" "HEAD")]
    (str/trim out)))

(defn main []
  (when (System/getenv "TMUX")
    (binding [*out* *err*]
      (println "bmm: already inside tmux"))
    (System/exit 1))
  (let [session-name (normalize-session-name (str (get-repo) "/" (get-branch)))
        current-sessions (:out @(process {:out :string} "tmux" "ls"))]
    (apply shell "tmux" (conj (if (str/includes? current-sessions session-name)
                                ["attach-session" "-t"]
                                ["new-session" "-s"]) session-name))))

(main)
