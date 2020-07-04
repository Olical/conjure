(module conjure.mapping
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            config conjure.config
            extract conjure.extract
            client conjure.client
            eval conjure.eval
            bridge conjure.bridge
            fennel conjure.aniseed.fennel}})

(defn- cfg [k]
  (config.get-in [:mapping k]))

(defn buf [mode keys ...]
  (when keys
    (let [args [...]]
      (nvim.buf_set_keymap
        0 mode
        (if (a.string? keys)
          (.. (cfg :prefix) keys)
          (a.first keys))
        (if (= 2 (a.count args))
          (.. ":" (bridge.viml->lua (unpack args)) "<cr>")
          (unpack args))
        {:silent true
         :noremap true}))))

(defn on-filetype []
  (buf :n (cfg :eval_motion) ":set opfunc=ConjureEvalMotion<cr>g@")
  (buf :n (cfg :log_split) :conjure.log :split)
  (buf :n (cfg :log_vsplit) :conjure.log :vsplit)
  (buf :n (cfg :log_tab) :conjure.log :tab)
  (buf :n (cfg :log_close_visible) :conjure.log :close-visible)
  (buf :n (cfg :eval_current_form) :conjure.eval :current-form)
  (buf :n (cfg :eval_root_form) :conjure.eval :root-form)
  (buf :n (cfg :eval_replace_form) :conjure.eval :replace-form)
  (buf :n (cfg :eval_marked_form) :conjure.eval :marked-form)
  (buf :n (cfg :eval_word) :conjure.eval :word)
  (buf :n (cfg :eval_file) :conjure.eval :file)
  (buf :n (cfg :eval_buf) :conjure.eval :buf)
  (buf :v (cfg :eval_visual) :conjure.eval :selection)
  (buf :n (cfg :doc_word) :conjure.eval :doc-word)
  (buf :n (cfg :def_word) :conjure.eval :def-word)

  (nvim.ex.setlocal "omnifunc=ConjureOmnifunc")

  (client.optional-call :on-filetype))

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
    :VimLeavePre :*
    (bridge.viml->lua :conjure.log :clear-close-hud-passive-timer {}))
  (nvim.ex.augroup :END))

(defn eval-ranged-command [start end code]
  (if (= "" code)
    (eval.range (a.dec start) end)
    (eval.command code)))

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
  "ConjureSchool"
  (bridge.viml->lua :conjure.school :start {}))
