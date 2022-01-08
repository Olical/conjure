(module conjure.mapping
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             str conjure.aniseed.string
             config conjure.config
             extract conjure.extract
             log conjure.log
             client conjure.client
             eval conjure.eval
             bridge conjure.bridge}
   require-macros [conjure.macros]})

(defn- cfg [k]
  (config.get-in [:mapping k]))

(defn- vim-repeat [mapping]
  (.. "repeat#set(\"" (nvim.fn.escape mapping "\"") "\", 1)"))

(defn buf [mode-or-opts cmd-suffix keys ...]
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
         :noremap true}))))

(defn eval-marked-form []
  (let [mark (eval.marked-form)
        mapping (a.some
                  (fn [m]
                    (and (= ":ConjureEvalMarkedForm<CR>" m.rhs)
                         m.lhs))
                  (nvim.buf_get_keymap 0 :n))]
    (when (and mark mapping)
      (nvim.ex.silent_ :call (vim-repeat (.. mapping mark))))))

(defn on-filetype []
  (buf :n :LogSplit (cfg :log_split) :conjure.log :split)
  (buf :n :LogVSplit (cfg :log_vsplit) :conjure.log :vsplit)
  (buf :n :LogTab (cfg :log_tab) :conjure.log :tab)
  (buf :n :LogBuf (cfg :log_buf) :conjure.log :buf)
  (buf :n :LogCloseVisible (cfg :log_close_visible) :conjure.log :close-visible)
  (buf :n :LogResetSoft (cfg :log_reset_soft) :conjure.log :reset-soft)
  (buf :n :LogResetHard (cfg :log_reset_hard) :conjure.log :reset-hard)
  (buf :n :LogJumpToLatest (cfg :log_jump_to_latest) :conjure.log :jump-to-latest)

  (buf :n nil (cfg :eval_motion) ":set opfunc=ConjureEvalMotion<cr>g@")

  (buf :n :EvalCurrentForm (cfg :eval_current_form) :conjure.eval :current-form)
  (buf :n :EvalCommentCurrentForm (cfg :eval_comment_current_form) :conjure.eval :comment-current-form)

  (buf :n :EvalRootForm (cfg :eval_root_form) :conjure.eval :root-form)
  (buf :n :EvalCommentRootForm (cfg :eval_comment_root_form) :conjure.eval :comment-root-form)

  (buf :n :EvalWord (cfg :eval_word) :conjure.eval :word)
  (buf :n :EvalCommentWord (cfg :eval_comment_word) :conjure.eval :comment-word)

  (buf :n :EvalReplaceForm (cfg :eval_replace_form) :conjure.eval :replace-form)
  (buf {:mode :n :repeat? false} :EvalMarkedForm (cfg :eval_marked_form) :conjure.mapping :eval-marked-form)
  (buf :n :EvalFile (cfg :eval_file) :conjure.eval :file)
  (buf :n :EvalBuf (cfg :eval_buf) :conjure.eval :buf)
  (buf :v :EvalVisual (cfg :eval_visual) :conjure.eval :selection)

  (buf :n :DocWord (cfg :doc_word) :conjure.eval :doc-word)
  (buf :n :DefWord (cfg :def_word) :conjure.eval :def-word)

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
  (if state-key
    (client.set-state-key! state-key)
    (a.println (client.state-key))))

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

(nvim.ex.command_
  "-nargs=? -range ConjureEval"
  (bridge.viml->lua
    :conjure.mapping :eval-ranged-command
    {:args "<line1>, <line2>, <q-args>"}))

(nvim.ex.command_
  "-nargs=* -range -complete=file ConjureConnect"
  (bridge.viml->lua
    :conjure.mapping :connect-command
    {:args "<f-args>"}))

(nvim.ex.command_
  "-nargs=* ConjureClientState"
  (bridge.viml->lua
    :conjure.mapping :client-state-command
    {:args "<f-args>"}))

(nvim.ex.command_
  "ConjureSchool"
  (bridge.viml->lua :conjure.school :start {}))
