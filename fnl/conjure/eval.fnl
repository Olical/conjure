(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local nvim (autoload :conjure.aniseed.nvim))
(local str (autoload :conjure.aniseed.string))
(local nu (autoload :conjure.aniseed.nvim.util))
(local extract (autoload :conjure.extract))
(local client (autoload :conjure.client))
(local text (autoload :conjure.text))
(local fs (autoload :conjure.fs))
(local timer (autoload :conjure.timer))
(local config (autoload :conjure.config))
(local promise (autoload :conjure.promise))
(local editor (autoload :conjure.editor))
(local buffer (autoload :conjure.buffer))
(local inline (autoload :conjure.inline))
(local uuid (autoload :conjure.uuid))
(local log (autoload :conjure.log))
(local event (autoload :conjure.event))

(fn preview [opts]
  (let [sample-limit (editor.percent-width
                       (config.get-in [:preview :sample_limit]))]
    (str.join
      [(client.get :comment-prefix)
       opts.action " (" opts.origin "): "
       (if (or (= :file opts.origin) (= :buf opts.origin))
         (text.right-sample opts.file-path sample-limit)
         (text.left-sample opts.code sample-limit))])))

(fn display-request [opts]
  (log.append
    [opts.preview]
    (a.merge opts {:break? true})))

(fn highlight-range [range]
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

(fn with-last-result-hook [opts]
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

(fn file []
  (event.emit :eval :file)
  (let [opts {:file-path (fs.localise-path (extract.file-path))
              :origin :file
              :action :eval}]
    (set opts.preview (preview opts))
    (display-request opts)
    (client.call
      :eval-file
      (with-last-result-hook opts))))

(fn assoc-context [opts]
  (when (not opts.context)
    (set opts.context
        (or nvim.b.conjure#context
            (extract.context))))
  opts)

(fn client-exec-fn [action f-name base-opts]
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

(fn apply-gsubs [code]
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

(local previous-evaluations
  {})

(fn eval-str [opts]
  (a.assoc
    previous-evaluations
    (a.get (client.current-client-module-name) :module-name :unknown)
    opts)

  (highlight-range opts.range)
  (event.emit :eval :str)
  (a.update opts :code apply-gsubs)
  ((client-exec-fn :eval :eval-str)
   (if opts.passive?
     opts
     (with-last-result-hook opts)))
  nil)

(fn previous []
  (let [client-name (a.get (client.current-client-module-name) :module-name :unknown)
        opts (a.get previous-evaluations client-name)]
    (when opts
      (eval-str opts))))

(fn wrap-emit [name f]
  (fn [...]
    (event.emit name)
    (f ...)))

(local doc-str (wrap-emit
                :doc
                (client-exec-fn :doc :doc-str)))

(local def-str (wrap-emit
                :def
                (client-exec-fn
                  :def :def-str
                  {:suppress-hud? true
                   :jumping? true})))

(fn current-form [extra-opts]
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

(fn replace-form []
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

(fn root-form []
  (let [form (extract.form {:root? true})]
    (when form
      (let [{: content : range} form]
        (eval-str
          {:code content
           :range range
           :origin :root-form})))))

(fn marked-form [mark]
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

(fn insert-result-comment [tag input]
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

(fn comment-current-form []
  (insert-result-comment :current-form (extract.form {})))

(fn comment-root-form []
  (insert-result-comment :root-form (extract.form {:root? true})))

(fn comment-word []
  (insert-result-comment :word (extract.word)))

(fn word []
  (let [{: content : range} (extract.word)]
    (when (not (a.empty? content))
      (eval-str
        {:code content
         :range range
         :origin :word}))))

(fn doc-word []
  (let [{: content : range} (extract.word)]
    (when (not (a.empty? content))
      (doc-str
        {:code content
         :range range
         :origin :word}))))

(fn def-word []
  (let [{: content : range} (extract.word)]
    (when (not (a.empty? content))
      (def-str
        {:code content
         :range range
         :origin :word}))))

(fn buf []
  (let [{: content : range} (extract.buf)]
    (eval-str
      {:code content
       :range range
       :origin :buf})))

(fn command [code]
  (eval-str
    {:code code
     :origin :command}))

(fn range [start end]
  (let [{: content : range} (extract.range start end)]
    (eval-str
      {:code content
       :range range
       :origin :range})))

(fn selection [kind]
  (let [{: content : range}
        (extract.selection
          {:kind (or kind (nvim.fn.visualmode))
           :visual? (not kind)})]
    (eval-str
      {:code content
       :range range
       :origin :selection})))

(fn wrap-completion-result [result]
  (if (a.string? result)
    {:word result}
    result))

(fn completions [prefix cb]
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

(fn completions-promise [prefix]
  (let [p (promise.new)]
    (completions prefix (promise.deliver-fn p))
    p))

(fn completions-sync [prefix]
  (let [p (completions-promise prefix)]
    (promise.await p)
    (promise.close p)))

{
 : file
 : previous-evaluation
 : eval-str
 : previous
 : wrap-emit
 : current-form
 : replace-form
 : root-form
 : marked-form
 : comment-current-form
 : comment-root-form
 : comment-word
 : word
 : doc-word
 : def-word
 : buf
 : command
 : range
 : selection
 : completions
 : completions-promise
 : completions-sync
 }
