(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local client (autoload :conjure.client))
(local eval (autoload :conjure.eval))
(local inline (autoload :conjure.inline))
(local school (autoload :conjure.school))
(local util (autoload :conjure.util))

(local M (define :conjure.mapping {}))

(fn cfg [k]
  (config.get-in [:mapping k]))

(fn M.buf [name-suffix mapping-suffix handler-fn opts]
  "Successor to buf, allows mapping to a Lua function.
  opts: {:desc \"\"
         :mode :n
         :buf 0
         :command-opts {}
         :mapping-opts {}}"

  (when mapping-suffix
    (let [;; A string is just keys, a table containing a string is an obscure
          ;; way of telling this function that you don't want to prefix the keys
          ;; with the normal Conjure prefix. It's kind of weird and I'd do it
          ;; differently if I designed it from scratch, but here we are.
          mapping (if (core.string? mapping-suffix)
                    (.. (cfg :prefix) mapping-suffix)
                    (core.first mapping-suffix))
          cmd (.. :Conjure name-suffix)
          desc (or (core.get opts :desc) (.. "Executes the " cmd " command"))
          mode (core.get opts :mode :n)]
      (vim.api.nvim_buf_create_user_command
        (core.get opts :buf 0) cmd handler-fn
        (core.merge!
          {:force true
           :desc desc}
          (core.get opts :command-opts {})))
      (vim.api.nvim_buf_set_keymap
        (core.get opts :buf 0)
        mode
        mapping
        "" ;; nop because we're using a :callback function.
        (core.merge!
          {:silent true
           :noremap true
           :desc desc
           :callback (fn []
                       (when (not= false (core.get opts :repeat?))
                         (pcall
                           vim.fn.repeat#set
                           (util.replace-termcodes mapping)
                           1))

                       ;; Have to call like this to pass visual selections through.
                       (vim.api.nvim_command
                         (str.join
                           ["normal! "
                            (if (= :n mode)
                              (util.replace-termcodes "<cmd>")
                              ":")
                            cmd
                            (util.replace-termcodes "<cr>")])))}
          (core.get opts :mapping-opts {}))))))

(fn M.on-filetype []
  (M.buf
    :LogSplit (cfg :log_split)
    (util.wrap-require-fn-call :conjure.log :split)
    {:desc "Open log in new horizontal split window"})

  (M.buf
    :LogVSplit (cfg :log_vsplit)
    (util.wrap-require-fn-call :conjure.log :vsplit)
    {:desc "Open log in new vertical split window"})

  (M.buf
    :LogTab (cfg :log_tab)
    (util.wrap-require-fn-call :conjure.log :tab)
    {:desc "Open log in new tab"})

  (M.buf
    :LogBuf (cfg :log_buf)
    (util.wrap-require-fn-call :conjure.log :buf)
    {:desc "Open log in new buffer"})

  (M.buf
    :LogToggle (cfg :log_toggle)
    (util.wrap-require-fn-call :conjure.log :toggle)
    {:desc "Toggle log buffer"})

  (M.buf
    :LogCloseVisible (cfg :log_close_visible)
    (util.wrap-require-fn-call :conjure.log :close-visible)
    {:desc "Close all visible log windows"})

  (M.buf
    :LogResetSoft (cfg :log_reset_soft)
    (util.wrap-require-fn-call :conjure.log :reset-soft)
    {:desc "Soft reset log"})

  (M.buf
    :LogResetHard (cfg :log_reset_hard)
    (util.wrap-require-fn-call :conjure.log :reset-hard)
    {:desc "Hard reset log"})

  (M.buf
    :LogJumpToLatest (cfg :log_jump_to_latest)
    (util.wrap-require-fn-call :conjure.log :jump-to-latest)
    {:desc "Jump to latest part of log"})

  (M.buf
    :EvalMotion (cfg :eval_motion)
    (fn []
      (set _G._conjure_opfunc (fn [...] (eval.selection ...)))
      (set vim.o.opfunc "v:lua._conjure_opfunc")

      ;; Doesn't work unless we schedule it :( this might break some things.
      (client.schedule #(vim.api.nvim_feedkeys "g@" :m false)))
    {:desc "Evaluate motion"})

  (M.buf
    :EvalCurrentForm (cfg :eval_current_form)
    (util.wrap-require-fn-call :conjure.eval :current-form)
    {:desc "Evaluate current form"})

  (M.buf
    :EvalCommentCurrentForm (cfg :eval_comment_current_form)
    (util.wrap-require-fn-call :conjure.eval :comment-current-form)
    {:desc "Evaluate current form and comment result"})

  (M.buf
    :EvalRootForm (cfg :eval_root_form)
    (util.wrap-require-fn-call :conjure.eval :root-form)
    {:desc "Evaluate root form"})

  (M.buf
    :EvalCommentRootForm (cfg :eval_comment_root_form)
    (util.wrap-require-fn-call :conjure.eval :comment-root-form)
    {:desc "Evaluate root form and comment result"})

  (M.buf
    :EvalWord (cfg :eval_word)
    (util.wrap-require-fn-call :conjure.eval :word)
    {:desc "Evaluate word"})

  (M.buf
    :EvalCommentWord (cfg :eval_comment_word)
    (util.wrap-require-fn-call :conjure.eval :comment-word)
    {:desc "Evaluate word and comment result"})

  (M.buf
    :EvalReplaceForm (cfg :eval_replace_form)
    (util.wrap-require-fn-call :conjure.eval :replace-form)
    {:desc "Evaluate form and replace with result"})

  (M.buf
    :EvalMarkedForm (cfg :eval_marked_form)
    #(client.schedule eval.marked-form)
    {:desc "Evaluate marked form"
     :repeat? false})

  (M.buf
    :EvalFile (cfg :eval_file)
    (util.wrap-require-fn-call :conjure.eval :file)
    {:desc "Evaluate file"})

  (M.buf
    :EvalBuf (cfg :eval_buf)
    (util.wrap-require-fn-call :conjure.eval :buf)
    {:desc "Evaluate buffer"})

  (M.buf
    :EvalPrevious (cfg :eval_previous)
    (util.wrap-require-fn-call :conjure.eval :previous)
    {:desc "Evaluate previous evaluation"})

  (M.buf
    :EvalVisual (cfg :eval_visual)
    (util.wrap-require-fn-call :conjure.eval :selection)
    {:desc "Evaluate visual select"
     :mode :v
     :command-opts {:range true}})

  (M.buf
    :DocWord (cfg :doc_word)
    (util.wrap-require-fn-call :conjure.eval :doc-word)
    {:desc "Get documentation under cursor"})

  (M.buf
    :DefWord (cfg :def_word)
    (util.wrap-require-fn-call :conjure.eval :def-word)
    {:desc "Get definition under cursor"})

  (when (= :function (type (client.get :completions)))
    (let [fn-name (config.get-in [:completion :omnifunc])]
      (when fn-name
        (vim.api.nvim_command (.. "setlocal omnifunc=" fn-name)))))

  (client.optional-call :on-filetype))

(fn M.on-exit []
  (client.each-loaded-client #(client.optional-call :on-exit)))

(fn M.on-quit []
  (log.close-hud))

(fn autocmd-callback [f]
  ;; Wraps an autocmd callback to ensure it returns nil because if we return anything truthy Neovim now deletes the autocmd.
  (fn [ev]
    (f ev)
    nil))

(fn M.init [filetypes]
  (local group (vim.api.nvim_create_augroup "conjure_init_filetypes" {}))
  (when (= true (config.get-in [:mapping :enable_ft_mappings]))
    (vim.api.nvim_create_autocmd
      :FileType
      {: group
       :pattern filetypes
       :callback (autocmd-callback M.on-filetype)})

    ;; If we're in a target filetype right now, immediately invoke on-filetype.
    ;; It means we've lazy loaded Conjure and it's loaded after the Filetype autocmd executed.
    (when (core.some #(= $ vim.bo.filetype) filetypes)
      (vim.schedule M.on-filetype)))

  (vim.api.nvim_create_autocmd
    :CursorMoved
    {: group
     :pattern "*"
     :callback (autocmd-callback log.close-hud-passive)})

  (vim.api.nvim_create_autocmd
    :CursorMovedI
    {: group
     :pattern "*"
     :callback (autocmd-callback log.close-hud-passive)})

  (vim.api.nvim_create_autocmd
    :CursorMoved
    {: group
     :pattern "*"
     :callback (autocmd-callback inline.clear)})

  (vim.api.nvim_create_autocmd
    :CursorMovedI
    {: group
     :pattern "*"
     :callback (autocmd-callback inline.clear)})

  (vim.api.nvim_create_autocmd
    :VimLeavePre
    {: group
     :pattern "*"
     :callback (autocmd-callback log.clear-close-hud-passive-timer)})

  (vim.api.nvim_create_autocmd
    :VimLeavePre
    {: group
     :pattern "*"
     :callback (autocmd-callback M.on-exit)})

  (vim.api.nvim_create_autocmd
    :QuitPre
    {: group
     :pattern "*"
     :callback (autocmd-callback M.on-quit)}))

(fn M.eval-ranged-command [start end code]
  (if (= "" code)
    (eval.range (core.dec start) end)
    (eval.command code)))

(fn M.connect-command [...]
  (let [args [...]]
    (client.call
      :connect
      (if (= 1 (core.count args))
        (let [(host port) (string.match (core.first args) "([a-zA-Z%d\\.-]+):(%d+)$")]
          (if (and host port)
            {:host host :port port}
            {:port (core.first args)}))
        {:host (core.first args)
         :port (core.second args)}))))

(fn M.client-state-command [state-key]
  (if (core.empty? state-key)
    (core.println (client.state-key))
    (client.set-state-key! state-key)))

(fn M.omnifunc [find-start? base]
  (if find-start?
    (let [[row col] (vim.api.nvim_win_get_cursor 0)
          [line] (vim.api.nvim_buf_get_lines 0 (core.dec row) row false)]
      (- col
         (core.count (vim.fn.matchstr
                    (string.sub line 1 col)
                    "\\k\\+$"))))
    (eval.completions-sync base)))

(vim.api.nvim_command
  (->> ["function! ConjureOmnifunc(findstart, base)"
        "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])"
        "endfunction"]
       (str.join "\n")))

(vim.api.nvim_create_user_command
  "ConjureEval"
  #(M.eval-ranged-command (. $ :line1) (. $ :line2) (. $ :args))
  {:nargs "?"
   :range true })

(vim.api.nvim_create_user_command
  "ConjureConnect"
  #(M.connect-command (unpack (. $ :fargs)))
  {:nargs "*"
   :range true
   :complete :file})

(vim.api.nvim_create_user_command
  "ConjureClientState"
  #(M.client-state-command (. $ :args))
  {:nargs "?"})

(vim.api.nvim_create_user_command
  "ConjureSchool"
  #(school.start)
  {})

M
