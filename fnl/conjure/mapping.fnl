(module conjure.mapping
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             str conjure.aniseed.string
             config conjure.config
             extract conjure.extract
             log conjure.log
             client conjure.client
             eval conjure.eval
             bridge conjure.bridge
             school conjure.school}
   require-macros [conjure.macros]})

(defn- cfg [k]
  (config.get-in [:mapping k]))

(defn- desc [k]
  (config.get-in [:desc k]))

(defn- vim-repeat [mapping]
  (.. "repeat#set(\"" (nvim.fn.escape mapping "\"") "\", 1)"))

(defn buf [mode-or-opts cmd-suffix keys desc ...]
  (when keys
    (let [[mode opts] (if (= :table (type mode-or-opts))
                        [(a.get mode-or-opts :mode) mode-or-opts]
                        [mode-or-opts {}])
          args [...]
          mapping (if (a.string? keys)
                    (.. (cfg :prefix) keys)
                    (a.first keys))
          cmd (and cmd-suffix (.. :Conjure cmd-suffix))]
      (when cmd
        (nvim.ex.command_
          (.. "-range " cmd)
          (bridge.viml->lua (unpack args))))
      (nvim.buf_set_keymap
        0 mode
        mapping
        (if cmd
          (.. ":" cmd "<cr>"
              (if (not= false (a.get opts :repeat?))
                (.. ":silent! call " (vim-repeat mapping) "<cr>")
                ""))
          (unpack args))
        {:silent true
         :noremap true
         :desc desc}))))

(defn eval-marked-form []
  (let [mark (eval.marked-form)
        mapping (a.some
                  (fn [m]
                    (and (= ":ConjureEvalMarkedForm<CR>" (a.get m :rhs))
                         m.lhs))
                  (nvim.buf_get_keymap 0 :n))]
    (when (and mark mapping)
      (nvim.ex.silent_ :call (vim-repeat (.. mapping mark))))))

(defn on-filetype []
  (buf :n :LogSplit (cfg :log_split) (desc :log_split) :conjure.log :split)
  (buf :n :LogVSplit (cfg :log_vsplit) (desc :log_vsplit) :conjure.log :vsplit)
  (buf :n :LogTab (cfg :log_tab) (desc :log_tab) :conjure.log :tab)
  (buf :n :LogBuf (cfg :log_buf) (desc :log_buf) :conjure.log :buf)
  (buf :n :LogToggle (cfg :log_toggle) (desc :log_toggle) :conjure.log :toggle)
  (buf :n :LogCloseVisible (cfg :log_close_visible) (desc :log_close_visible) :conjure.log :close-visible)
  (buf :n :LogResetSoft (cfg :log_reset_soft) (desc :log_reset_soft) :conjure.log :reset-soft)
  (buf :n :LogResetHard (cfg :log_reset_hard) (desc :log_reset_hard) :conjure.log :reset-hard)
  (buf :n :LogJumpToLatest (cfg :log_jump_to_latest) (desc :log_jump_to_latest) :conjure.log :jump-to-latest)

  (buf :n nil (cfg :eval_motion) (desc :eval_motion) ":set opfunc=ConjureEvalMotion<cr>g@")

  (buf :n :EvalCurrentForm (cfg :eval_current_form) (desc :eval_current_form) :conjure.eval :current-form)
  (buf :n :EvalCommentCurrentForm (cfg :eval_comment_current_form) (desc :eval_comment_current_form) :conjure.eval :comment-current-form)

  (buf :n :EvalRootForm (cfg :eval_root_form) (desc :eval_root_form) :conjure.eval :root-form)
  (buf :n :EvalCommentRootForm (cfg :eval_comment_root_form) (desc :eval_comment_root_form) :conjure.eval :comment-root-form)

  (buf :n :EvalWord (cfg :eval_word) (desc :eval_word) :conjure.eval :word)
  (buf :n :EvalCommentWord (cfg :eval_comment_word) (desc :eval_comment_word) :conjure.eval :comment-word)

  (buf :n :EvalReplaceForm (cfg :eval_replace_form) (desc :eval_replace_form) :conjure.eval :replace-form)
  (buf {:mode :n :repeat? false} :EvalMarkedForm (cfg :eval_marked_form) (desc :eval_marked_form) :conjure.mapping :eval-marked-form)
  (buf :n :EvalFile (cfg :eval_file) (desc :eval_file) :conjure.eval :file)
  (buf :n :EvalBuf (cfg :eval_buf) (desc :eval_buf) :conjure.eval :buf)
  (buf :v :EvalVisual (cfg :eval_visual) (desc :eval_visual) :conjure.eval :selection)

  (buf :n :DocWord (cfg :doc_word) (desc :doc_word) :conjure.eval :doc-word)
  (buf :n :DefWord (cfg :def_word) (desc :def_word) :conjure.eval :def-word)

  (let [fn-name (config.get-in [:completion :omnifunc])]
    (when fn-name
      (nvim.ex.setlocal (.. "omnifunc=" fn-name))))

  (client.optional-call :on-filetype))

(defn on-exit []
  (client.each-loaded-client #(client.optional-call :on-exit)))

(defn on-quit []
  (log.close-hud))

(defn init [filetypes]
  (nvim.ex.augroup :conjure_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," filetypes)
    (bridge.viml->lua :conjure.mapping :on-filetype {}))

  (nvim.ex.autocmd
    :CursorMoved :*
    (bridge.viml->lua :conjure.log :close-hud-passive {}))
  (nvim.ex.autocmd
    :CursorMovedI :*
    (bridge.viml->lua :conjure.log :close-hud-passive {}))

  (nvim.ex.autocmd
    :CursorMoved :*
    (bridge.viml->lua :conjure.inline :clear {}))
  (nvim.ex.autocmd
    :CursorMovedI :*
    (bridge.viml->lua :conjure.inline :clear {}))

  (nvim.ex.autocmd
    :VimLeavePre :*
    (bridge.viml->lua :conjure.log :clear-close-hud-passive-timer {}))
  (nvim.ex.autocmd :ExitPre :* (viml->fn on-exit))
  (nvim.ex.autocmd :QuitPre :* (viml->fn on-quit))
  (nvim.ex.augroup :END))

(defn eval-ranged-command [start end code]
  (if (= "" code)
    (eval.range (a.dec start) end)
    (eval.command code)))

(defn connect-command [...]
  (let [args [...]]
    (client.call
      :connect
      (if (= 1 (a.count args))
        (let [(host port) (string.match (a.first args) "([a-zA-Z%d\\.-]+):(%d+)$")]
          (if (and host port)
            {:host host :port port}
            {:port (a.first args)}))
        {:host (a.first args)
         :port (a.second args)}))))

(defn client-state-command [state-key]
  (if (a.empty? state-key)
    (a.println (client.state-key))
    (client.set-state-key! state-key)))

(defn omnifunc [find-start? base]
  (if find-start?
    (let [[row col] (nvim.win_get_cursor 0)
          [line] (nvim.buf_get_lines 0 (a.dec row) row false)]
      (- col
         (a.count (nvim.fn.matchstr
                    (string.sub line 1 col)
                    "\\k\\+$"))))
    (eval.completions-sync base)))

(nvim.ex.function_
  (->> ["ConjureEvalMotion(kind)"
        "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)"
        "endfunction"]
       (str.join "\n")))

(nvim.ex.function_
  (->> ["ConjureOmnifunc(findstart, base)"
        "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])"
        "endfunction"]
       (str.join "\n")))

(nvim.create_user_command
  "ConjureEval"
  #(eval-ranged-command (. $ :line1) (. $ :line2) (. $ :args))
  {:nargs "?"
   :range true })

(nvim.create_user_command
  "ConjureConnect"
  #(connect-command (unpack (. $ :fargs)))
  {:nargs "*"
   :range true
   :complete :file})

(nvim.create_user_command
  "ConjureClientState"
  #(client-state-command (. $ :args))
  {:nargs "?"})

(nvim.create_user_command
  "ConjureSchool"
  #(school.start)
  {})
