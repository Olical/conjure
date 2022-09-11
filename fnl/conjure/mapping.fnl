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
             school conjure.school
             util conjure.util}
   require-macros [conjure.macros]})

(defn- cfg [k]
  (config.get-in [:mapping k]))

(def- mapping-descriptions
  {:log_split "Open log in new horizontal split window"
   :log_vsplit "Open log in new vertical split window"
   :log_tab "Open log in new tab"
   :log_buf "Open log in new buffer"
   :log_toggle "Toggle log buffer"
   :log_close_visible "Close all visible log windows"
   :log_reset_soft "Soft reset log"
   :log_reset_hard "Hard reset log"
   :log_jump_to_latest "Jump to latest part of log"

   ;; :eval_current_form "ee"
   ;; :eval_comment_current_form "ece"
   ;;
   ;; :eval_root_form "er"
   ;; :eval_comment_root_form "ecr"
   ;;
   ;; :eval_word "ew"
   ;; :eval_comment_word "ecw"
   ;;
   ;; :eval_replace_form "e!"
   ;; :eval_marked_form "em"
   ;; :eval_file "ef"
   ;; :eval_buf "eb"
   ;; :eval_visual "E"
   ;; :eval_motion "E"
   ;; :def_word "gd"
   ;; :doc_word ["K"]
   })

(defn- desc [k]
  (a.get mapping-descriptions k))

(defn- vim-repeat [mapping]
  (.. "repeat#set(\"" (nvim.fn.escape mapping "\"") "\", 1)"))

(defn buf [mode-or-opts cmd-suffix keys ...]
  "Legacy buffer local mapping function, replaced by buf2."

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

(defn buf2 [name-suffix mapping-suffix handler-fn opts]
  "Successor to buf, allows mapping to a Lua function.
  opts: {:desc ""
         :mode :n
         :buf 0
         :command-opts {}
         :mapping-opts {}}"

  (when mapping-suffix
    (let [;; A string is just keys, a table containing a string is an obscure
          ;; way of telling this function that you don't want to prefix the keys
          ;; with the normal Conjure prefix. It's kind of weird and I'd do it
          ;; differently if I designed it from scratch, but here we are.
          mapping (if (a.string? mapping-suffix)
                    (.. (cfg :prefix) mapping-suffix)
                    (a.first mapping-suffix))
          cmd (.. :Conjure name-suffix)]
      (nvim.create_user_command cmd handler-fn (a.get opts :command-opts {}))
      (nvim.buf_set_keymap
        (a.get opts :buf 0)
        (a.get opts :mode :n)
        mapping
        ""
        (a.merge!
          {:silent true
           :noremap true
           :desc (a.get opts :desc)
           :callback (fn []
                       (when (not= false (a.get opts :repeat?))
                         (nvim.fn.repeat#set
                           (util.replace-termcodes mapping)
                           1))
                       (nvim.command cmd))}
          (a.get opts :mapping-opts {}))))))

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
  (buf2
    :LogSplit (cfg :log_split)
    (util.wrap-require-fn-call :conjure.log :split)
    {:desc (desc :log_split)})

  (buf2
    :LogVSplit (cfg :log_vsplit)
    (util.wrap-require-fn-call :conjure.log :vsplit)
    {:desc (desc :log_vsplit)})

  (buf2
    :LogTab (cfg :log_tab)
    (util.wrap-require-fn-call :conjure.log :tab)
    {:desc (desc :log_tab)})

  (buf2
    :LogBuf (cfg :log_buf)
    (util.wrap-require-fn-call :conjure.log :buf)
    {:desc (desc :log_buf)})

  (buf2
    :LogToggle (cfg :log_toggle)
    (util.wrap-require-fn-call :conjure.log :toggle)
    {:desc (desc :log_toggle)})

  (buf2
    :LogCloseVisible (cfg :log_close_visible)
    (util.wrap-require-fn-call :conjure.log :close-visible)
    {:desc (desc :log_close_visible)})

  (buf2
    :LogResetSoft (cfg :log_reset_soft)
    (util.wrap-require-fn-call :conjure.log :reset-soft)
    {:desc (desc :log_reset_soft)})

  (buf2
    :LogResetHard (cfg :log_reset_hard)
    (util.wrap-require-fn-call :conjure.log :reset-hard)
    {:desc (desc :log_reset_hard)})

  (buf2
    :LogJumpToLatest (cfg :log_jump_to_latest)
    (util.wrap-require-fn-call :conjure.log :jump-to-latest)
    {:desc (desc :log_jump_to_latest)})

  (buf2
    :EvalMotion (cfg :eval_motion)
    (fn []
      (set nvim.o.opfunc :ConjureEvalMotionOpFunc)
      (nvim.feedkeys "g@" :n false))
    {:desc (desc :eval_motion)})

  (buf2
    :EvalCurrentForm (cfg :eval_current_form)
    (util.wrap-require-fn-call :conjure.eval :current-form)
    {:desc (desc :eval_current_form)})

  (buf2
    :EvalCommentCurrentForm (cfg :eval_comment_current_form)
    (util.wrap-require-fn-call :conjure.eval :comment-current-form)
    {:desc (desc :eval_comment_current_form)})


  (buf2
    :EvalRootForm (cfg :eval_root_form)
    (util.wrap-require-fn-call :conjure.eval :root-form)
    {:desc (desc :eval_root_form)})

  (buf2
    :EvalCommentRootForm (cfg :eval_comment_root_form)
    (util.wrap-require-fn-call :conjure.eval :comment-root-form)
    {:desc (desc :eval_comment_root_form)})

  (buf2
    :EvalWord (cfg :eval_word)
    (util.wrap-require-fn-call :conjure.eval :word)
    {:desc (desc :eval_word)})

  (buf2
    :EvalCommentWord (cfg :eval_comment_word)
    (util.wrap-require-fn-call :conjure.eval :comment-word)
    {:desc (desc :eval_comment_word)})

  (buf2
    :EvalReplaceForm (cfg :eval_replace_form)
    (util.wrap-require-fn-call :conjure.eval :replace-form)
    {:desc (desc :eval_replace_form)})

  (buf2
    :EvalMarkedForm (cfg :eval_marked_form)
    eval-marked-form
    {:desc (desc :eval_marked_form)
     :repeat? false})

  (buf2
    :EvalFile (cfg :eval_file)
    (util.wrap-require-fn-call :conjure.eval :file)
    {:desc (desc :eval_file)})

  (buf2
    :EvalBuf (cfg :eval_buf)
    (util.wrap-require-fn-call :conjure.eval :buf)
    {:desc (desc :eval_buf)})

  (buf2
    :EvalVisual (cfg :eval_visual)
    (util.wrap-require-fn-call :conjure.eval :selection)
    {:desc (desc :eval_visual)
     :mode :v})

  (buf2
    :DocWord (cfg :doc_word)
    (util.wrap-require-fn-call :conjure.eval :doc-word)
    {:desc (desc :doc_word)})

  (buf2
    :DefWord (cfg :def_word)
    (util.wrap-require-fn-call :conjure.eval :def-word)
    {:desc (desc :def_word)})

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
  (->> ["ConjureEvalMotionOpFunc(kind)"
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
