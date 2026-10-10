(ns pi.ask-user-test
  (:require [pi.ask-user :as ask-user]
            ["node:assert/strict" :as assert]
            ["@earendil-works/pi-coding-agent"
             :refer [ExtensionEditorComponent]]))

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

(defn custom-answer-remains-in-questionnaire-test []
  (set! (.-externalEditorCalls ExtensionEditorComponent) 0)
  (let [component (atom nil)
        completed (atom nil)
        native-editor-calls (atom 0)
        tui #js {:requestRender (fn [])}
        theme #js {:fg (fn [_ text] text)
                   :bg (fn [_ text] text)
                   :bold (fn [text] text)}
        ctx #js {:ui
                 #js {:custom
                      (fn [factory _options]
                        (reset! component
                                (factory tui theme #js {}
                                         (fn [details]
                                           (reset! completed details))))
                        #js {:shown true})
                      :editor
                      (fn [& _args]
                        (swap! native-editor-calls inc)
                        (js/Promise. (fn [_resolve _reject])))}}
        questions
        #js [#js {:id "first"
                  :label "First"
                  :prompt "First question"
                  :mode "single"
                  :allowOther true
                  :options #js [#js {:value "one" :label "One"}]}
             #js {:id "second"
                  :label "Second"
                  :prompt "Second question"
                  :mode "single"
                  :allowOther false
                  :options #js [#js {:value "two" :label "Two"}]}]]
    (ask-user/open-questionnaire ctx questions)

    ;; Select "Type something…" for the first question.
    (.handleInput @component "down")
    (.handleInput @component "enter")
    (.equal assert @native-editor-calls 0
            "inline questionnaire must not open a competing native editor")

    ;; The custom-answer editor retains Pi's configured external-editor action.
    (.handleInput @component "ctrl+g")
    (.equal assert (.-externalEditorCalls ExtensionEditorComponent) 1
            "custom answers support the external editor keybinding")

    ;; Submit the embedded custom answer, answer question two, then submit.
    (.handleInput @component "custom answer")
    (.handleInput @component "enter")
    (.handleInput @component "enter")
    (.handleInput @component "enter")

    (.ok assert @completed "questionnaire completes after a custom first answer")
    (.equal assert (.-custom (aget (.-answers @completed) 0)) "custom answer")
    (.equal assert (.-value (aget (.-selected (aget (.-answers @completed) 1)) 0))
            "two")))

(inline-placement-test)
(custom-answer-remains-in-questionnaire-test)
(println "pi ask_user tests passed")
