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
; Returns {:repo r} for a standard repo, {:repo r :worktree? true} for a worktree.
; Note: the git-dir only carries the *basename* of the worktree
; (`worktrees/feat/foobar` has git-dir `worktrees/foobar`), so the full
; name must come from `git rev-parse --show-toplevel` instead.
(defn parse-repo [parts]
  (match (vec parts)
    [_ "worktrees" r & _] {:repo r :worktree? true}
    [".git" r & _] {:repo r}
    :else {:repo "unk"}))

(defn get-repo []
  (let [{:keys [out]} (shell {:out :string}
                             "git" "rev-parse" "--path-format=absolute" "--git-dir")]
    (-> out
        (str/trim)
        (str/split #"/")
        (reverse)
        (parse-repo))))

; The worktree's name is its directory path below `worktrees/`,
; which may be nested: `.../nasty/worktrees/feat/foobar` -> "feat/foobar".
; Falls back to the directory basename if there is no `worktrees` component.
(defn get-worktree-name []
  (let [{:keys [out]} (shell {:out :string} "git" "rev-parse" "--show-toplevel")
        parts (-> out (str/trim) (str/split #"/") (reverse))
        [below above] (split-with #(not= "worktrees" %) parts)]
    (if (seq above)
      (str/join "/" (reverse below))
      (first parts))))

(defn get-branch []
  (let [{:keys [out]} (shell {:out :string} "git" "rev-parse" "--abbrev-ref" "HEAD")]
    (str/trim out)))

(defn main []
  (when (System/getenv "TMUX")
    (binding [*out* *err*]
      (println "bmm: already inside tmux"))
    (System/exit 1))
  (let [{:keys [repo worktree?]} (get-repo)
        session-name (normalize-session-name
                      (str repo "/" (if worktree? (get-worktree-name) (get-branch))))
        current-sessions (:out @(process {:out :string} "tmux" "ls"))]
    (apply shell "tmux" (conj (if (str/includes? current-sessions session-name)
                                ["attach-session" "-t"]
                                ["new-session" "-s"]) session-name))))

(main)
