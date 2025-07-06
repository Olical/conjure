(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
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
(local log (autoload :conjure.log))
(local event (autoload :conjure.event))

(local M (define :conjure.eval))

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
    (core.merge opts {:break? true})))

(fn highlight-range [range]
  (when (and (config.get-in [:highlight :enabled])
             vim.highlight
             range)
    (let [bufnr (or (. range :bufnr) (vim.api.nvim_get_current_buf))
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

;; TODO Turn this into a sliding buffer, it grows infinitely right now.
(set M.results (or M.results []))

(fn with-on-result-hook [opts]
  (let [buf (vim.api.nvim_win_get_buf 0)
        line (core.dec (core.first (vim.api.nvim_win_get_cursor 0)))]
    (core.update
      opts :on-result
      (fn [f]
        (fn [result]
          (vim.fn.setreg
            (config.get-in [:eval :result_register])

            ;; Workaround for https://github.com/Olical/conjure/issues/212
            ;; The Lua -> VimL boundary does not like null bytes. The strings
            ;; end up being tables as they cross the boundary!
            (string.gsub result "%z" ""))

          (table.insert
            M.results
            {:client (core.get (client.current-client-module-name) :module-name :unknown)
             :buf buf
             :request opts
             :result result})

          (when (config.get-in [:eval :inline_results])
            (inline.display
              {:buf buf
               :text (str.join
                       [(config.get-in [:eval :inline :prefix])
                        result])
               :line line}))
          (when f
            (f result)))))))

(fn M.file []
  (event.emit :eval :file)
  (let [opts {:file-path (fs.localise-path (extract.file-path))
              :origin :file
              :action :eval}]
    (set opts.preview (preview opts))
    (display-request opts)
    (client.call
      :eval-file
      (with-on-result-hook opts))))

(fn assoc-context [opts]
  (when (not opts.context)
    (set opts.context
        (or vim.b.conjure#context
            (extract.context))))
  opts)

(fn client-exec-fn [action f-name base-opts]
  (fn [opts]
    (let [opts (core.merge
                 opts base-opts
                 {:action action
                  :file-path (extract.file-path)})]
      (assoc-context opts)
      (set opts.preview (preview opts))

      (client.optional-call :modify-client-exec-fn-opts action f-name opts)

      (when (not opts.passive?)
        (display-request opts))

      (when opts.jumping?
        ;; Ensure the tag stack and jumplist are up to date before any jump
        ;; related code executes.
        (pcall
          (fn []
            (let [win (vim.api.nvim_get_current_win)
                  buf (vim.api.nvim_get_current_buf)]
              (vim.fn.settagstack
                win
                {:items [{:tagname opts.code
                          :bufnr buf
                          :from (core.concat [buf] (vim.api.nvim_win_get_cursor win) [0])
                          :matchnr 0}]}
                :a))
            (vim.api.nvim_feedkeys "m'" "n" false))))

      (client.call f-name opts))))

(fn apply-gsubs [code]
  (when code
    (core.reduce
      (fn [code [name [pat rep]]]
        (let [(ok? val-or-err) (pcall string.gsub code pat rep)]
          (if ok?
            val-or-err
            (do
              (vim.notify
                (str.join ["Error from g:conjure#eval#gsubs: " name " - " val-or-err])
                vim.log.levels.ERROR)
              code))))
      code
      (core.kv-pairs
        (or vim.b.conjure#eval#gsubs
            vim.g.conjure#eval#gsubs)))))

(set M.previous-evaluations {})

(fn M.eval-str [opts]
  (core.assoc
    M.previous-evaluations
    (core.get (client.current-client-module-name) :module-name :unknown)
    opts)

  (highlight-range opts.range)
  (event.emit :eval :str)
  (core.update opts :code apply-gsubs)
  ((client-exec-fn :eval :eval-str)
   (if opts.passive?
     opts
     (with-on-result-hook opts)))
  nil)

(fn M.previous []
  (let [client-name (core.get (client.current-client-module-name) :module-name :unknown)
        opts (core.get M.previous-evaluations client-name)]
    (when opts
      (M.eval-str opts))))

(fn M.wrap-emit [name f]
  (fn [...]
    (event.emit name)
    (f ...)))

(local doc-str (M.wrap-emit
                :doc
                (client-exec-fn :doc :doc-str)))

(local def-str (M.wrap-emit
                :def
                (client-exec-fn
                  :def :def-str
                  {:suppress-hud? true
                   :jumping? true})))

(fn M.current-form [extra-opts]
  (let [form (extract.form {})]
    (when form
      (let [{: content : range : node} form]
        (M.eval-str
          (core.merge
            {:code content
             :range range
             :node node
             :origin :current-form}
            extra-opts))
        form))))

(fn M.replace-form []
  (let [buf (vim.api.nvim_win_get_buf 0)
        win (vim.api.nvim_tabpage_get_win 0)
        form (extract.form {})]
    (when form
      (let [{: content : range : node} form]
        (M.eval-str
          {:code content
           :range range
           :node node
           :origin :replace-form
           :suppress-hud? true
           :on-result
           (fn [result]
             (buffer.replace-range
               buf
               range result)
             (editor.go-to
               win
               (core.get-in range [:start 1])
               (core.inc (core.get-in range [:start 2]))))})
        form))))

(fn M.root-form []
  (let [form (extract.form {:root? true})]
    (when form
      (let [{: content : range : node} form]
        (M.eval-str
          {:code content
           :range range
           :node node
           :origin :root-form})))))

(fn M.marked-form [mark]
  (let [comment-prefix (client.get :comment-prefix)
        mark (or mark (extract.prompt-char))
        (ok? err) (pcall #(editor.go-to-mark mark))]
    (if ok?
      (do
        (M.current-form {:origin (str.join ["marked-form [" mark "]"])})
        (editor.go-back))
      (log.append [(str.join [comment-prefix "Couldn't eval form at mark: " mark])
                   (str.join [comment-prefix err])]
                  {:break? true}))
    mark))

(fn insert-result-comment [tag input]
  (let [buf (vim.api.nvim_win_get_buf 0)
        comment-prefix (or
                         (config.get-in [:eval :comment_prefix])
                         (client.get :comment-prefix))]
    (when input
      (let [{: content : range : node} input]
        (M.eval-str
          {:code content
           :range range
           :node node
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

(fn M.comment-current-form []
  (insert-result-comment :current-form (extract.form {})))

(fn M.comment-root-form []
  (insert-result-comment :root-form (extract.form {:root? true})))

(fn M.comment-word []
  (insert-result-comment :word (extract.word)))

(fn M.word []
  (let [{: content : range : node} (extract.word)]
    (when (not (core.empty? content))
      (M.eval-str
        {:code content
         :range range
         :node node
         :origin :word}))))

(fn M.doc-word []
  (let [{: content : range : node} (extract.word)]
    (when (not (core.empty? content))
      (doc-str
        {:code content
         :range range
         :node node
         :origin :word}))))

(fn M.def-word []
  (let [{: content : range : node} (extract.word)]
    (when (not (core.empty? content))
      (def-str
        {:code content
         :range range
         :node node
         :origin :word}))))

(fn M.buf []
  (let [{: content : range} (extract.buf)]
    (M.eval-str
      {:code content
       :range range
       :origin :buf})))

(fn M.command [code]
  (M.eval-str
    {:code code
     :origin :command}))

(fn M.range [start end]
  (let [{: content : range} (extract.range start end)]
    (M.eval-str
      {:code content
       :range range
       :origin :range})))

(fn M.selection [kind]
  (let [{: content : range}
        (extract.selection
          {:kind (or kind (vim.fn.visualmode))
           :visual? (not kind)})]
    (M.eval-str
      {:code content
       :range range
       :origin :selection})))

(fn wrap-completion-result [result]
  (if (core.string? result)
    {:word result}
    result))

(fn M.completions [prefix cb]
  (fn cb-wrap [results]
    (cb (core.map
          wrap-completion-result
          (or results
              (-?> (config.get-in [:completion :fallback])
                   (vim.api.nvim_call_function [0 prefix]))))))
  (if (= :function (type (client.get :completions)))
    (client.call
      :completions
      (-> {:file-path (extract.file-path)
           :prefix prefix
           :cb cb-wrap}
          (assoc-context)))
    (cb-wrap)))

(fn M.completions-promise [prefix]
  (let [p (promise.new)]
    (M.completions prefix (promise.deliver-fn p))
    p))

(fn M.completions-sync [prefix]
  (let [p (M.completions-promise prefix)]
    (promise.await p)
    (promise.close p)))

M
