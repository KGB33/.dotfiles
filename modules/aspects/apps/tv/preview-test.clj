(ns preview-test
  (:require [clojure.java.io :as io]
            [clojure.string :as str]
            [clojure.test :refer [deftest is run-tests testing]]
            [cheshire.core :as json]
            [preview :as preview]))

(def session-id "01234567-89ab-cdef-0123-456789abcdef")

(defn temp-dir []
  (.toFile (java.nio.file.Files/createTempDirectory "tss-preview-test-" (make-array java.nio.file.attribute.FileAttribute 0))))

(defn write-snapshot! [dir filename values]
  (spit (io/file dir filename)
        (json/generate-string
          (merge {:version 1
                  :session_id session-id
                  :pid 4242
                  :pane "%7"
                  :cwd "/work/example-project"
                  :state "working"
                  :activity "read, bash"
                  :updated_at 9995
                  :model "openai/gpt-5.6"
                  :thinking_level "high"
                  :subagents_available true
                  :subagents []}
                 values))))

(defn fake-tmux [pane-sessions]
  (fn [& args]
    (cond
      (= (take-last 2 args) ["#S" nil]) {:exit 1 :out ""}
      (= (last args) "#S") (if-let [session (get pane-sessions (nth args 2))]
                               {:exit 0 :out (str session "\n")}
                               {:exit 1 :out ""})
      (= (last args) "#I.#P") {:exit 0 :out "2.3\n"}
      (= (first args) "list-windows") {:exit 0 :out "* 2: editor (2 panes)\n  3: logs (1 panes)\n"}
      :else {:exit 1 :out ""})))

(deftest rendering-and-filtering
  (let [dir (temp-dir)]
    (try
      (write-snapshot! dir "matching.json" {})
      (write-snapshot! dir "other.json" {:session_id "other-full-id" :pane "%8"})
      (let [output (preview/preview-text
                     "selected"
                     {:dir (.getPath dir)
                      :now 10000
                      :pid-alive? (constantly true)
                      :tmux (fake-tmux {"%7" "selected" "%8" "other"})})]
        (testing "agent heading and selected session fields"
          (is (str/includes? output "Agents"))
          (is (not (str/includes? output "Parents")))
          (is (str/includes? output "WORKING"))
          (is (str/includes? output "example-project"))
          (is (str/includes? output "2.3"))
          (is (str/includes? output "openai/gpt-5.6 · high"))
          (is (str/includes? output "read, bash · 5s ago")))
        (testing "full session id appears exactly once and another session is filtered"
          (is (= 1 (count (re-seq (re-pattern session-id) output))))
          (is (not (str/includes? output "other-full-id"))))
        (testing "available parents with no active children emit no history row"
          (is (not (str/includes? output "subagents")))
          (is (not (str/includes? output "↳"))))
        (testing "tmux windows summary is preserved"
          (is (str/includes? output "Windows"))
          (is (str/includes? output "* 2: editor (2 panes)"))))
      (finally
        (doseq [file (reverse (file-seq dir))] (io/delete-file file true))))))

(deftest active-children-render-in-fleet-order-under-idle-parent
  (let [dir (temp-dir)]
    (try
      (write-snapshot!
        dir "idle-with-children.json"
        {:state "idle"
         :activity "turn complete"
         :subagents [{:key "fleet-2"
                      :agent "worker"
                      :role "implementation"
                      :model "openai/gpt-5.6"
                      :effort "high"
                      :goal "Implement active child status"
                      :startedAt 9990000
                      :tokens {:input 10 :output 20 :total 30}}
                     {:key "fleet-1" :agent "scout"}]})
      (let [output (preview/preview-text
                     "selected"
                     {:dir (.getPath dir)
                      :now 10000
                      :pid-alive? (constantly true)
                      :tmux (fake-tmux {"%7" "selected"})})
            worker-index (.indexOf output "↳ worker")
            scout-index (.indexOf output "↳ scout")]
        (testing "children remain visible while their parent is idle and preserve Fleet order"
          (is (str/includes? output "IDLE"))
          (is (<= 0 worker-index))
          (is (< worker-index scout-index)))
        (testing "all supplied public display metadata is compactly rendered"
          (is (str/includes? output "worker (implementation)"))
          (is (str/includes? output "openai/gpt-5.6"))
          (is (str/includes? output "high"))
          (is (str/includes? output "Implement active child status"))
          (is (str/includes? output "10s"))
          (is (str/includes? output "30 tok (10 in, 20 out)")))
        (testing "omitted optional fields emit no placeholders or private reconciliation keys"
          (is (= "    ↳ scout" (first (filter #(str/includes? % "↳ scout")
                                               (str/split-lines output)))))
          (is (not (str/includes? output "fleet-1")))
          (is (not (str/includes? output "fleet-2")))
          (is (not (str/includes? output "nil")))))
      (finally
        (doseq [file (reverse (file-seq dir))] (io/delete-file file true))))))

(deftest unavailable-subagent-status-is-explicit-and-has-no-history
  (let [dir (temp-dir)]
    (try
      (write-snapshot! dir "unavailable.json"
                       {:subagents_available false
                        :subagents []})
      (let [output (preview/preview-text
                     "selected"
                     {:dir (.getPath dir)
                      :now 10000
                      :pid-alive? (constantly true)
                      :tmux (fake-tmux {"%7" "selected"})})]
        (is (str/includes? output "subagents unavailable"))
        (is (not (str/includes? output "↳"))))
      (finally
        (doseq [file (reverse (file-seq dir))] (io/delete-file file true))))))

(deftest malformed-and-stale-cleanup
  (let [dir (temp-dir)]
    (try
      (spit (io/file dir "malformed.json") "not json")
      (write-snapshot! dir "dead-pid.json" {:pid 1 :pane "%1"})
      (write-snapshot! dir "dead-pane.json" {:pid 2 :pane "%2"})
      (let [output (preview/preview-text
                     "selected"
                     {:dir (.getPath dir)
                      :now 10000
                      :pid-alive? #(not= % 1)
                      :tmux (fake-tmux {})})]
        (is (str/includes? output "no agents"))
        (is (not (str/includes? output "no parents")))
        (is (.exists (io/file dir "malformed.json")) "malformed snapshots are ignored")
        (is (not (.exists (io/file dir "dead-pid.json"))) "dead Pi snapshots are removed")
        (is (not (.exists (io/file dir "dead-pane.json"))) "dead pane snapshots are removed"))
      (finally
        (doseq [file (reverse (file-seq dir))] (io/delete-file file true))))))

(deftest age-formatting
  (is (= "0s" (preview/format-age 10 11)))
  (is (= "59s" (preview/format-age 59 0)))
  (is (= "2m" (preview/format-age 120 0)))
  (is (= "2h" (preview/format-age 7200 0))))

(let [{:keys [fail error]} (run-tests)]
  (when (pos? (+ fail error))
    (System/exit 1)))
