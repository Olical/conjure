(module conjure.mapping
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            config conjure.config
            extract conjure.extract
            lang conjure.lang
            eval conjure.eval
            bridge conjure.bridge}})

(defn buf [mode keys ...]
  (let [args [...]]
    (nvim.buf_set_keymap
      0 mode
      (if (a.string? keys)
        (.. config.mappings.prefix keys)
        (a.first keys))
      (if (= 2 (a.count args))
        (.. ":" (bridge.viml->lua (unpack args)) "<cr>")
        (unpack args))
      {:silent true
       :noremap true})))

(defn on-filetype []
  (buf :n config.mappings.eval-motion ":set opfunc=ConjureEvalMotion<cr>g@")
  (buf :n config.mappings.log-split :conjure.log :split)
  (buf :n config.mappings.log-vsplit :conjure.log :vsplit)
  (buf :n config.mappings.log-tab :conjure.log :tab)
  (buf :n config.mappings.eval-current-form :conjure.eval :current-form)
  (buf :n config.mappings.eval-root-form :conjure.eval :root-form)
  (buf :n config.mappings.eval-marked-form :conjure.eval :marked-form)
  (buf :n config.mappings.eval-word :conjure.eval :word)
  (buf :n config.mappings.eval-file :conjure.eval :file)
  (buf :n config.mappings.eval-buf :conjure.eval :buf)
  (buf :v config.mappings.eval-visual :conjure.eval :selection)
  (buf :n config.mappings.close-hud :conjure.log :close-hud)
  (buf :n config.mappings.doc-word :conjure.eval :doc-word)
  (buf :n config.mappings.def-word :conjure.eval :def-word)

  (nvim.ex.autocmd
    :CursorMoved :<buffer>
    (bridge.viml->lua :conjure.log :close-hud {}))

  (nvim.ex.autocmd
    :CursorMovedI :<buffer>
    (bridge.viml->lua :conjure.log :close-hud {}))

  (lang.call :on-filetype))

(defn setup-filetypes [filetypes]
  (nvim.ex.augroup :conjure_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," filetypes)
    (bridge.viml->lua :conjure.mapping :on-filetype {}))
  (nvim.ex.augroup :END))

(defn eval-ranged-command [start end code]
  (if (= "" code)
    (eval.range (a.dec start) end)
    (eval.command code)))

(nvim.ex.function_
  (->> ["ConjureEvalMotion(kind)"
        "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)"
        "endfunction"]
       (str.join "\n")))

;; TODO Add completion via -complete=custom,{func}
(nvim.ex.command_
  "-nargs=? -range ConjureEval"
  (bridge.viml->lua
    :conjure.mapping :eval-ranged-command
    {:args "<line1>, <line2>, <q-args>"}))
