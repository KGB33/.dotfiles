(ns pi.ask-user-test
  (:require [pi.ask-user :as ask-user]
            ["node:assert/strict" :as assert]))

(defn inline-placement-test []
  (let [arguments (atom nil)
        expected-result #js {:shown true}
        ctx #js {:ui #js {:custom (fn [& args]
                                   (reset! arguments args)
                                   expected-result)}}
        result (ask-user/open-questionnaire ctx #js [])
        options (nth @arguments 1 nil)]
    (.equal assert result expected-result)
    (.equal assert (count @arguments) 2
            "ask_user passes explicit custom UI placement options")
    (.equal assert (.-overlay options) false
            "ask_user renders inline where the prompt normally appears")
    (.equal assert (js/Object.hasOwn options "onHandle") false
            "inline ask_user does not request an overlay handle")))

(inline-placement-test)
(println "pi ask_user tests passed")
