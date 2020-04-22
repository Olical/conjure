(module conjure.eval
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            extract conjure.extract
            client conjure.client
            text conjure.text
            config conjure.config
            editor conjure.editor
            uuid conjure.uuid
            log conjure.log}})

(defn- preview [opts]
  (let [sample-limit (editor.percent-width
                       config.preview.sample-limit)]
    (.. (client.get :comment-prefix)
        opts.action " (" opts.origin "): "
        (if (or (= :file opts.origin) (= :buf opts.origin))
          (text.right-sample opts.file-path sample-limit)
          (text.left-sample opts.code sample-limit)))))

(defn- display-request [opts]
  (log.append [opts.preview] {:break? true}))

(defn file []
  (let [opts {:file-path (extract.file-path)
              :origin :file
              :action :eval}]
    (set opts.preview (preview opts))
    (display-request opts)
    (client.call :eval-file opts)))

(defn- assoc-context [opts]
  (set opts.context
       (or nvim.b.conjure_context
           (extract.context)))
  opts)

(defn- client-exec-fn [action f-name]
  (fn [opts]
    (set opts.action action)
    (assoc-context opts)
    (set opts.file-path (extract.file-path))
    (set opts.preview (preview opts))
    (display-request opts)
    (client.call f-name opts)))

(def- eval-str (client-exec-fn :eval :eval-str))
(def- doc-str (client-exec-fn :doc :doc-str))
(def- def-str (client-exec-fn :def :def-str))

(defn current-form [extra-opts]
  (let [form (extract.form {})]
    (when form
      (let [{: content : range} form]
        (eval-str
          (a.merge
            {:code content
             :range range
             :origin :current-form}
            extra-opts))))))

(defn root-form []
  (let [form (extract.form {:root? true})]
    (when form
      (let [{: content : range} form]
        (eval-str
          {:code content
           :range range
           :origin :root-form})))))

(defn marked-form []
  (let [mark (extract.prompt-char)
        comment-prefix (client.get :comment-prefix)
        (ok? err) (pcall #(editor.go-to-mark mark))]
    (if ok?
      (do 
        (current-form {:origin (..  "marked-form [" mark "]")})
        (editor.go-back))
      (log.append [(.. comment-prefix "Couldn't eval form at mark: " mark)
                   (.. comment-prefix err)]
                  {:break? true}))))

(defn word []
  (let [{: content : range} (extract.word)]
    (when (not (a.empty? content))
      (eval-str
        {:code content
         :range range
         :origin :word}))))

(+ 10 20 30)

(defn doc-word []
  (let [{: content : range} (extract.word)]
    (when (not (a.empty? content))
      (doc-str
        {:code content
         :range range
         :origin :word}))))

(defn def-word []
  (let [{: content : range} (extract.word)]
    (when (not (a.empty? content))
      (def-str
        {:code content
         :range range
         :origin :word}))))

(defn buf []
  (let [{: content : range} (extract.buf)]
    (eval-str
      {:code content
       :range range
       :origin :buf})))

(defn command [code]
  (eval-str
    {:code code
     :origin :command}))

(defn range [start end]
  (let [{: content : range} (extract.range start end)]
    (eval-str
      {:code content
       :range range
       :origin :range})))

(defn selection [kind]
  (let [{: content : range}
        (extract.selection
          {:kind (or kind (nvim.fn.visualmode))
           :visual? (not kind)})]
    (eval-str
      {:code content
       :range range
       :origin :selection})))

(defn completions [prefix cb]
  (if (= :function (type (client.get :completions)))
    (client.call
      :completions
      (-> {:prefix prefix
           :cb cb}
          (assoc-context)))
    (cb [])))

(defonce completion-tickets {})

(defn completions-ticket [prefix]
  (let [ticket (uuid.v4)]
    (a.assoc completion-tickets
             ticket
             {:ticket ticket
              :value nil
              :done? false
              :close
              (fn []
                (let [value (a.get-in completion-tickets
                                      [ticket :value])]
                  (a.assoc completion-tickets ticket nil)
                  value))})
    (completions
      prefix
      (fn [cmpls]
        (a.assoc-in completion-tickets [ticket :value] cmpls)
        (a.assoc-in completion-tickets [ticket :done?] true)))
    ticket))
