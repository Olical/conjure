(module conjure.eval
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             nu conjure.aniseed.nvim.util
             extract conjure.extract
             client conjure.client
             text conjure.text
             fs conjure.fs
             timer conjure.timer
             config conjure.config
             promise conjure.promise
             editor conjure.editor
             buffer conjure.buffer
             inline conjure.inline
             uuid conjure.uuid
             log conjure.log
             event conjure.event}})

(defn- preview [opts]
  (let [sample-limit (editor.percent-width
                       (config.get-in [:preview :sample_limit]))]
    (str.join
      [(client.get :comment-prefix)
       opts.action " (" opts.origin "): "
       (if (or (= :file opts.origin) (= :buf opts.origin))
         (text.right-sample opts.file-path sample-limit)
         (text.left-sample opts.code sample-limit))])))

(defn- display-request [opts]
  (log.append
    [opts.preview]
    (a.merge opts {:break? true})))

(defn- highlight-range [range]
  (when (and (config.get-in [:highlight :enabled])
             vim.highlight
             range)
    (let [bufnr (or (. range :bufnr) (nvim.buf.nr))
          namespace (vim.api.nvim_create_namespace "conjure_highlight")
          hl_start {1 (- (. range.start 1) 1)
                    2 (. range.start 2)}
          hl_end {1 (- (. range.end 1) 1)
                  2 (. range.end 2)}]

      (vim.highlight.range
        bufnr namespace (config.get-in [:highlight :group]) hl_start hl_end
        (unpack
          ;; https://github.com/neovim/neovim/issues/14090#issuecomment-1047205812
          [{:regtype :v
            :inclusive true}]))

      (timer.defer
        (fn []
          (pcall #(vim.api.nvim_buf_clear_namespace
                    bufnr namespace 0 -1)))
        (config.get-in [:highlight :timeout])))))

(defn- with-last-result-hook [opts]
  (let [buf (nvim.win_get_buf 0)
        line (a.dec (a.first (nvim.win_get_cursor 0)))]
    (a.update
      opts :on-result
      (fn [f]
        (fn [result]
          (nvim.fn.setreg
            (config.get-in [:eval :result_register])

            ;; Workaround for https://github.com/Olical/conjure/issues/212
            ;; The Lua -> VimL boundary does not like null bytes. The strings
            ;; end up being tables as they cross the boundary!
            (string.gsub result "%z" ""))

          (when (config.get-in [:eval :inline_results])
            (inline.display
              {:buf buf
               :text (str.join
                       [(config.get-in [:eval :inline :prefix])
                        result])
               :line line}))
          (when f (f result)))))))

(defn file []
  (event.emit :eval :file)
  (let [opts {:file-path (fs.localise-path (extract.file-path))
              :origin :file
              :action :eval}]
    (set opts.preview (preview opts))
    (display-request opts)
    (client.call
      :eval-file
      (with-last-result-hook opts))))

(defn- assoc-context [opts]
  (set opts.context
       (or nvim.b.conjure#context
           (extract.context)))
  opts)

(defn- client-exec-fn [action f-name base-opts]
  (fn [opts]
    (let [opts (a.merge opts base-opts
                        {:action action
                         :file-path (extract.file-path)})]
      (assoc-context opts)
      (set opts.preview (preview opts))

      (when (not opts.passive?)
        (display-request opts))

      (when opts.jumping?
        ;; Ensure the tag stack and jumplist are up to date before any jump
        ;; related code executes.
        (pcall
          (fn []
            (let [win (nvim.get_current_win)
                  buf (nvim.get_current_buf)]
              (nvim.fn.settagstack
                win
                {:items [{:tagname opts.code
                          :bufnr buf
                          :from (a.concat [buf] (nvim.win_get_cursor win) [0])
                          :matchnr 0}]}
                :a))
            (nu.normal "m'"))))

      (client.call f-name opts))))

(defn- apply-gsubs [code]
  (when code
    (a.reduce
      (fn [code [name [pat rep]]]
        (let [(ok? val-or-err) (pcall string.gsub code pat rep)]
          (if ok?
            val-or-err
            (do
              (nvim.err_writeln
                (str.join ["Error from g:conjure#eval#gsubs: " name " - " val-or-err]))
              code))))
      code
      (a.kv-pairs (or nvim.b.conjure#eval#gsubs
                      nvim.g.conjure#eval#gsubs)))))

(defn eval-str [opts]
  (highlight-range opts.range)
  (event.emit :eval :str)
  (a.update opts :code apply-gsubs)
  ((client-exec-fn :eval :eval-str)
   (if opts.passive?
     opts
     (with-last-result-hook opts)))
  nil)

(defn wrap-emit [name f]
  (fn [...]
    (event.emit name)
    (f ...)))

(def- doc-str (wrap-emit
                :doc
                (client-exec-fn :doc :doc-str)))

(def- def-str (wrap-emit
                :def
                (client-exec-fn
                  :def :def-str
                  {:suppress-hud? true
                   :jumping? true})))

(defn current-form [extra-opts]
  (let [form (extract.form {})]
    (when form
      (let [{: content : range} form]
        (eval-str
          (a.merge
            {:code content
             :range range
             :origin :current-form}
            extra-opts))
        form))))

(defn replace-form []
  (let [buf (nvim.win_get_buf 0)
        win (nvim.tabpage_get_win 0)
        form (extract.form {})]
    (when form
      (let [{: content : range} form]
        (eval-str
          {:code content
           :range range
           :origin :replace-form
           :suppress-hud? true
           :on-result
           (fn [result]
             (buffer.replace-range
               buf
               range result)
             (editor.go-to
               win
               (a.get-in range [:start 1])
               (a.inc (a.get-in range [:start 2]))))})
        form))))

(defn root-form []
  (let [form (extract.form {:root? true})]
    (when form
      (let [{: content : range} form]
        (eval-str
          {:code content
           :range range
           :origin :root-form})))))

(defn marked-form [mark]
  (let [comment-prefix (client.get :comment-prefix)
        mark (or mark (extract.prompt-char))
        (ok? err) (pcall #(editor.go-to-mark mark))]
    (if ok?
      (do
        (current-form {:origin (str.join ["marked-form [" mark "]"])})
        (editor.go-back))
      (log.append [(str.join [comment-prefix "Couldn't eval form at mark: " mark])
                   (str.join [comment-prefix err])]
                  {:break? true}))
    mark))

(defn- insert-result-comment [tag input]
  (let [buf (nvim.win_get_buf 0)
        comment-prefix (or
                         (config.get-in [:eval :comment_prefix])
                         (client.get :comment-prefix))]
    (when input
      (let [{: content : range} input]
        (eval-str
          {:code content
           :range range
           :origin (str.join [:comment- tag])
           :suppress-hud? true
           :on-result
           (fn [result]
             (buffer.append-prefixed-line
               buf
               (. range :end)
               comment-prefix
               result))})
        input))))

(defn comment-current-form []
  (insert-result-comment :current-form (extract.form {})))

(defn comment-root-form []
  (insert-result-comment :root-form (extract.form {:root? true})))

(defn comment-word []
  (insert-result-comment :word (extract.word)))

(defn word []
  (let [{: content : range} (extract.word)]
    (when (not (a.empty? content))
      (eval-str
        {:code content
         :range range
         :origin :word}))))

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

(defn- wrap-completion-result [result]
  (if (a.string? result)
    {:word result}
    result))

(defn completions [prefix cb]
  (fn cb-wrap [results]
    (cb (a.map
          wrap-completion-result
          (or results
              (-?> (config.get-in [:completion :fallback])
                   (nvim.call_function [0 prefix]))))))
  (if (= :function (type (client.get :completions)))
    (client.call
      :completions
      (-> {:file-path (extract.file-path)
           :prefix prefix
           :cb cb-wrap}
          (assoc-context)))
    (cb-wrap)))

(defn completions-promise [prefix]
  (let [p (promise.new)]
    (completions prefix (promise.deliver-fn p))
    p))

(defn completions-sync [prefix]
  (let [p (completions-promise prefix)]
    (promise.await p)
    (promise.close p)))
