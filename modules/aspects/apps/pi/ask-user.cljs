(ns pi.ask-user
  (:require ["@earendil-works/pi-ai" :refer [StringEnum]]
            ["@earendil-works/pi-coding-agent" :refer [CustomEditor keyHint]]
            ["@earendil-works/pi-tui"
             :refer [Text matchesKey visibleWidth wrapTextWithAnsi]]
            ["typebox" :refer [Type]]))

(def option-schema
  (.Object Type
           #js {:value (.String Type
                               #js {:description "Stable value returned when selected"
                                    :minLength 1})
                :label (.String Type
                               #js {:description "Display label"
                                    :minLength 1})
                :description (.Optional Type
                                        (.String Type
                                                 #js {:description "Optional supporting text"}))}))

(def question-schema
  (.Object Type
           #js {:id (.String Type
                            #js {:description "Unique stable question identifier"
                                 :minLength 1})
                :label (.String Type
                               #js {:description "Short tab and summary label"
                                    :minLength 1})
                :prompt (.String Type
                                #js {:description "Full question shown to the user"
                                     :minLength 1})
                :mode (StringEnum #js ["single" "multiple"])
                :options (.Array Type option-schema
                                 #js {:description "Non-empty predefined choices"
                                      :minItems 1})
                :allowOther (.Optional Type
                                      (.Boolean Type
                                                #js {:description
                                                     "Allow one custom answer; defaults to true"}))}))

(def ask-user-schema
  (.Object Type
           #js {:questions (.Array Type question-schema
                                   #js {:description "Required questions to ask"
                                        :minItems 1})}))

(defn duplicate-value [values]
  (loop [remaining (seq values)
         seen #{}]
    (when-let [value (first remaining)]
      (if (contains? seen value)
        value
        (recur (next remaining) (conj seen value))))))

(defn normalize-questions [questions]
  (.map questions
        (fn [question]
          (js/Object.assign
            #js {}
            question
            #js {:allowOther (not= false (.-allowOther question))}))))

(defn validate-questions [questions]
  (cond
    (zero? (.-length questions))
    "At least one question is required"

    :else
    (or
      (when-let [duplicate-id
                 (duplicate-value (map #(.-id %) (array-seq questions)))]
        (str "Question IDs must be unique: " duplicate-id))
      (some
        (fn [question]
          (cond
            (zero? (.-length (.-options question)))
            (str "Question " (.-id question) " must provide at least one option")

            :else
            (when-let [duplicate-option
                       (duplicate-value
                         (map #(.-value %) (array-seq (.-options question))))]
              (str "Option values for question " (.-id question)
                   " must be unique: " duplicate-option))))
        (array-seq questions)))))

(defn empty-answer []
  {:selected [] :custom nil})

(defn toggle-option [answer option]
  (let [value (.-value option)
        selected (:selected answer)
        exists? (some #(= value (:value %)) selected)]
    (assoc answer
           :selected
           (if exists?
             (vec (remove #(= value (:value %)) selected))
             (conj selected {:value value :label (.-label option)})))))

(defn set-custom-answer [answer text]
  (assoc answer :custom (not-empty (.trim (or text "")))))

(defn answered? [answer]
  (boolean (or (seq (:selected answer)) (:custom answer))))

(defn selected? [answer value]
  (boolean (some #(= value (:value %)) (:selected answer))))

(defn answer->js [question answer]
  #js {:id (.-id question)
       :label (.-label question)
       :mode (.-mode question)
       :selected (clj->js (:selected answer))
       :custom (:custom answer)})

(defn result-details [questions answers cancelled]
  #js {:questions questions
       :answers (.map questions
                      (fn [question]
                        (answer->js
                          question
                          (get answers (.-id question) (empty-answer)))))
       :cancelled cancelled})

(defn error-result [message questions]
  #js {:content #js [#js {:type "text" :text message}]
       :details #js {:questions questions
                     :answers #js []
                     :cancelled false
                     :error message}})

(defn add-wrapped! [lines width prefix text]
  (let [prefix-width (visibleWidth prefix)]
    (if (>= prefix-width width)
      (doseq [line (array-seq (wrapTextWithAnsi (str prefix text) width))]
        (.push lines line))
      (let [wrapped (wrapTextWithAnsi text (- width prefix-width))
            continuation (.repeat " " prefix-width)]
        (doseq [[index line] (map-indexed vector (array-seq wrapped))]
          (.push lines (str (if (zero? index) prefix continuation) line)))))))

(defn open-questionnaire [ctx questions]
  (let [overlay-handle (atom nil)]
    (.custom
      (.-ui ctx)
    (fn [tui theme keybindings done]
      (let [question-count (.-length questions)
            multi-question? (> question-count 1)
            total-tabs (inc question-count)
            current-tab (atom 0)
            option-index (atom 0)
            input-mode (atom false)
            input-question-id (atom nil)
            cached-width (atom nil)
            cached-lines (atom nil)
            answers
            (atom
              (into {}
                    (map (fn [question] [(.-id question) (empty-answer)])
                         (array-seq questions))))
            editor-theme
            #js {:borderColor (fn [text] (.fg theme "accent" text))
                 :selectList
                 #js {:selectedPrefix (fn [text] (.fg theme "accent" text))
                      :selectedText (fn [text] (.fg theme "accent" text))
                      :description (fn [text] (.fg theme "muted" text))
                      :scrollInfo (fn [text] (.fg theme "dim" text))
                      :noMatch (fn [text] (.fg theme "warning" text))}}
            editor (CustomEditor. tui editor-theme keybindings)]
        (letfn [(current-question []
                  (when (< @current-tab question-count)
                    (aget questions @current-tab)))
                (answer-for [question]
                  (get @answers (.-id question) (empty-answer)))
                (update-answer! [question update-fn]
                  (swap! answers update (.-id question) update-fn))
                (all-answered? []
                  (every? #(answered? (answer-for %)) (array-seq questions)))
                (refresh! []
                  (reset! cached-width nil)
                  (reset! cached-lines nil)
                  (.requestRender tui))
                (finish! [cancelled]
                  (done (result-details questions @answers cancelled)))
                (advance! []
                  (if (= question-count 1)
                    (finish! false)
                    (do
                      (swap! current-tab #(min question-count (inc %)))
                      (reset! option-index 0)
                      (refresh!))))
                (open-custom! [question]
                  (reset! input-mode true)
                  (reset! input-question-id (.-id question))
                  (when-let [handle @overlay-handle]
                    (.setHidden handle true))
                  (let [prefill (or (:custom (answer-for question)) "")]
                    (.then
                      (.editor (.-ui ctx) "Your answer:" prefill)
                      (fn [text]
                        (when-let [handle @overlay-handle]
                          (.setHidden handle false)
                          (.focus handle))
                        (if (nil? text)
                          (do
                            (reset! input-mode false)
                            (reset! input-question-id nil)
                            (.setText editor "")
                            (refresh!))
                          (submit-custom! text))))))
                (submit-custom! [text]
                  (when-let [question-id @input-question-id]
                    (let [question
                          (some #(when (= question-id (.-id %)) %)
                                (array-seq questions))
                          trimmed (not-empty (.trim (or text "")))]
                      (when question
                        (update-answer!
                          question
                          (fn [answer]
                            (cond-> (set-custom-answer answer text)
                              (and trimmed (= "single" (.-mode question)))
                              (assoc :selected [])))))
                      (reset! input-mode false)
                      (reset! input-question-id nil)
                      (.setText editor "")
                      (cond
                        (and question trimmed (= "single" (.-mode question)))
                        (advance!)

                        question
                        (do
                          (reset! option-index 0)
                          (refresh!))

                        :else
                        (refresh!)))))
                (options-length [question]
                  (+ (.-length (.-options question))
                     (if (.-allowOther question) 1 0)))
                (other-index? [question index]
                  (and (.-allowOther question)
                       (= index (.-length (.-options question)))))
                (select-single! [question option]
                  (swap! answers
                         assoc
                         (.-id question)
                         {:selected [{:value (.-value option)
                                      :label (.-label option)}]
                          :custom nil})
                  (advance!))
                (handle-input! [data]
                  (if @input-mode
                    (if (matchesKey data "escape")
                      (do
                        (reset! input-mode false)
                        (reset! input-question-id nil)
                        (.setText editor "")
                        (refresh!))
                      (do
                        (.handleInput editor data)
                        (refresh!)))
                    (let [question (current-question)]
                      (cond
                        (and multi-question?
                             (or (matchesKey data "tab")
                                 (matchesKey data "right")))
                        (do
                          (swap! current-tab #(mod (inc %) total-tabs))
                          (reset! option-index 0)
                          (refresh!))

                        (and multi-question?
                             (or (matchesKey data "shift+tab")
                                 (matchesKey data "left")))
                        (do
                          (swap! current-tab #(mod (dec %) total-tabs))
                          (reset! option-index 0)
                          (refresh!))

                        (= @current-tab question-count)
                        (cond
                          (and (matchesKey data "enter") (all-answered?))
                          (finish! false)

                          (matchesKey data "escape")
                          (finish! true))

                        (and question (matchesKey data "up"))
                        (do
                          (swap! option-index #(max 0 (dec %)))
                          (refresh!))

                        (and question (matchesKey data "down"))
                        (do
                          (swap! option-index
                                 #(min (dec (options-length question)) (inc %)))
                          (refresh!))

                        (and question
                             (= "single" (.-mode question))
                             (matchesKey data "enter"))
                        (if (other-index? question @option-index)
                          (open-custom! question)
                          (select-single!
                            question
                            (aget (.-options question) @option-index)))

                        (and question
                             (= "multiple" (.-mode question))
                             (matchesKey data "space"))
                        (if (other-index? question @option-index)
                          (open-custom! question)
                          (do
                            (update-answer!
                              question
                              #(toggle-option
                                 %
                                 (aget (.-options question) @option-index)))
                            (refresh!)))

                        (and question
                             (= "multiple" (.-mode question))
                             (matchesKey data "enter"))
                        (if (other-index? question @option-index)
                          (open-custom! question)
                          (when (answered? (answer-for question))
                            (advance!)))

                        (matchesKey data "escape")
                        (finish! true)))))
                (render-tabs! [lines width]
                  (when multi-question?
                    (let [tabs
                          (concat
                            (map-indexed
                              (fn [index question]
                                (let [active? (= index @current-tab)
                                      complete? (answered? (answer-for question))
                                      marker (if complete? "■" "□")
                                      text (str " " marker " " (.-label question) " ")]
                                  (if active?
                                    (.bg theme "selectedBg" (.fg theme "text" text))
                                    (.fg theme (if complete? "success" "muted") text))))
                              (array-seq questions))
                            [(let [text " ✓ Submit "]
                               (if (= question-count @current-tab)
                                 (.bg theme "selectedBg" (.fg theme "text" text))
                                 (.fg theme (if (all-answered?) "success" "dim") text)))])]
                      (add-wrapped! lines width " " (apply str (interpose " " tabs)))
                      (.push lines ""))))
                (render-options! [lines width question]
                  (let [answer (answer-for question)
                        single? (= "single" (.-mode question))]
                    (doseq [[index option]
                            (map-indexed vector (array-seq (.-options question)))]
                      (let [highlighted? (= index @option-index)
                            checked? (selected? answer (.-value option))
                            marker (if single?
                                     (if checked? "◉" "○")
                                     (if checked? "☑" "☐"))
                            cursor (if highlighted? "> " "  ")
                            label (str marker " " (.-label option))]
                        (add-wrapped!
                          lines width
                          cursor
                          (.fg theme (if highlighted? "accent" "text") label))
                        (when-let [description (.-description option)]
                          (add-wrapped! lines width "     " (.fg theme "muted" description)))))
                    (when (.-allowOther question)
                      (let [index (.-length (.-options question))
                            highlighted? (= index @option-index)
                            custom (:custom answer)
                            marker (if single?
                                     (if custom "◉" "○")
                                     (if custom "☑" "☐"))
                            label (if custom
                                    (str marker " Type something…: " custom)
                                    (str marker " Type something…"))]
                        (add-wrapped!
                          lines width
                          (if highlighted? "> " "  ")
                          (.fg theme (if highlighted? "accent" "text") label))))))
                (render-submit! [lines width]
                  (add-wrapped!
                    lines width " "
                    (.fg theme "accent" (.bold theme "Ready to submit")))
                  (.push lines "")
                  (doseq [question (array-seq questions)]
                    (let [answer (answer-for question)
                          selected-labels (map :label (:selected answer))
                          pieces (cond-> (vec selected-labels)
                                   (:custom answer) (conj (str "(wrote) " (:custom answer))))]
                      (if (answered? answer)
                        (add-wrapped!
                          lines width " "
                          (str (.fg theme "muted" (str (.-label question) ": "))
                               (.fg theme "text" (.join (clj->js pieces) ", "))))
                        (add-wrapped!
                          lines width " "
                          (.fg theme "warning" (str (.-label question) ": unanswered"))))))
                  (.push lines "")
                  (add-wrapped!
                    lines width " "
                    (.fg theme
                         (if (all-answered?) "success" "warning")
                         (if (all-answered?)
                           "Press Enter to submit"
                           "Answer every question before submitting"))))
                (render! [width]
                  (if (and @cached-lines (= @cached-width width))
                    @cached-lines
                    (let [render-width (max 1 width)
                          lines #js []
                          question (current-question)]
                      (.push lines (.fg theme "accent" (.repeat "─" render-width)))
                      (render-tabs! lines render-width)
                      (if (= @current-tab question-count)
                        (render-submit! lines render-width)
                        (when question
                          (add-wrapped! lines render-width " " (.fg theme "text" (.-prompt question)))
                          (.push lines "")
                          (render-options! lines render-width question)
                          (when @input-mode
                            (.push lines "")
                            (add-wrapped! lines render-width " " (.fg theme "muted" "Your answer:"))
                            (doseq [line (array-seq (.render editor (max 1 (- render-width 2))))]
                              (add-wrapped! lines render-width " " line)))))
                      (.push lines "")
                      (let [help
                            (cond
                              @input-mode
                              (str "Enter to save • Esc to go back • "
                                   (keyHint "app.editor.external" "external editor"))

                              multi-question?
                              "Tab/←→ navigate • ↑↓ select • Space toggle • Enter confirm • Esc cancel"

                              :else
                              "↑↓ navigate • Space toggle • Enter confirm • Esc cancel")]
                        (add-wrapped! lines render-width " " (.fg theme "dim" help)))
                      (.push lines (.fg theme "accent" (.repeat "─" render-width)))
                      (reset! cached-width width)
                      (reset! cached-lines lines)
                      lines)))
                (invalidate! []
                  (reset! cached-width nil)
                  (reset! cached-lines nil)
                  (.invalidate editor))]
          (set! (.-onSubmit editor) submit-custom!)
          (let [component #js {:render render!
                               :handleInput handle-input!
                               :invalidate invalidate!}]
            (.defineProperty
              js/Object
              component
              "focused"
              #js {:configurable true
                   :get (fn [] (.-focused editor))
                   :set (fn [value] (set! (.-focused editor) value))})
            component))))
      #js {:overlay true
           :onHandle (fn [handle] (reset! overlay-handle handle))})))

(defn result-text [details]
  (.join
    (.map
      (.-answers details)
      (fn [answer]
        (let [selected (map #(.-label %) (array-seq (.-selected answer)))
              custom (.-custom answer)
              values (cond-> (vec selected)
                       custom (conj (str "user wrote: " custom)))]
          (str (.-label answer) ": " (.join (clj->js values) ", ")))))
    "\n"))

(defn render-call [args theme]
  (let [questions (or (.-questions args) #js [])
        count (.-length questions)
        labels (.join (.map questions (fn [question] (.-label question))) ", ")]
    (Text.
      (str (.fg theme "toolTitle" (.bold theme "ask_user "))
           (.fg theme "muted" (str count " question" (when (not= 1 count) "s")))
           (when (pos? count) (.fg theme "dim" (str " (" labels ")"))))
      0 0)))

(defn render-result [result theme]
  (let [details (.-details result)]
    (cond
      (nil? details)
      (Text. (or (some-> result .-content (aget 0) .-text) "") 0 0)

      (.-error details)
      (Text. (.fg theme "error" (.-error details)) 0 0)

      (.-cancelled details)
      (Text. (.fg theme "warning" "Cancelled") 0 0)

      :else
      (Text.
        (.join
          (.map
            (.-answers details)
            (fn [answer]
              (let [selected (map #(.-label %) (array-seq (.-selected answer)))
                    custom (.-custom answer)
                    pieces (cond-> (vec selected)
                             custom (conj (str "(wrote) " custom)))]
                (str (.fg theme "success" "✓ ")
                     (.fg theme "accent" (.-label answer))
                     ": "
                     (.join (clj->js pieces) ", ")))))
          "\n")
        0 0))))

(defn default [pi]
  (.registerTool
    pi
    #js {:name "ask_user"
         :label "Ask User"
         :description
         (str "Ask the user one or more required interactive choice questions. "
              "Questions may be single-select or multi-select and may allow custom text.")
         :promptSnippet "Ask the user one or more interactive choice questions"
         :promptGuidelines
         #js ["Use ask_user when user input is required to clarify requirements, choose between meaningful alternatives, or confirm a decision."
              "Group independent questions into one ask_user call instead of opening several questionnaires."]
         :parameters ask-user-schema
         :executionMode "sequential"
         :execute
         (fn [_tool-call-id params _signal _on-update ctx]
           (let [questions (normalize-questions (.-questions params))
                 validation-error (validate-questions questions)]
             (cond
               validation-error
               (js/Promise.resolve (error-result validation-error questions))

               (not= "tui" (.-mode ctx))
               (js/Promise.resolve
                 (error-result "ask_user requires Pi interactive mode" questions))

               :else
               (.then
                 (open-questionnaire ctx questions)
                 (fn [details]
                   (if (.-cancelled details)
                     #js {:content
                          #js [#js {:type "text"
                                   :text "User cancelled the questionnaire"}]
                          :details details}
                     #js {:content #js [#js {:type "text"
                                            :text (result-text details)}]
                          :details details}))))))
         :renderCall (fn [args theme _context] (render-call args theme))
         :renderResult
         (fn [result _options theme _context]
           (render-result result theme))}))
