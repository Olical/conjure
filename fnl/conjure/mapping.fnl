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
  (buf :n config.mappings.log-close-visible :conjure.log :close-visible)
  (buf :n config.mappings.eval-current-form :conjure.eval :current-form)
  (buf :n config.mappings.eval-root-form :conjure.eval :root-form)
  (buf :n config.mappings.eval-replace-form :conjure.eval :replace-form)
  (buf :n config.mappings.eval-marked-form :conjure.eval :marked-form)
  (buf :n config.mappings.eval-word :conjure.eval :word)
  (buf :n config.mappings.eval-file :conjure.eval :file)
  (buf :n config.mappings.eval-buf :conjure.eval :buf)
  (buf :v config.mappings.eval-visual :conjure.eval :selection)
  (buf :n config.mappings.append-prefix :conjure.eval :append-register)
  (buf :n config.mappings.insert-prefix :conjure.eval :insert-register)
  (buf :v config.mappings.append-prefix :conjure.eval :replace-register)
  (buf :v config.mappings.insert-prefix :conjure.eval :replace-register)
  (buf :n config.mappings.doc-word :conjure.eval :doc-word)
  (buf :n config.mappings.def-word :conjure.eval :def-word)

  (nvim.ex.setlocal "omnifunc=ConjureOmnifunc")

  (client.optional-call :on-filetype))

(defn- parse-config-target [target]
  (let [client-path (str.split target "/")]
    {:client (when (= 2 (a.count client-path))
               (a.first client-path))
     :path (str.split (a.last client-path) "%.")}))

(defn config-command [target ...]
  (let [opts (parse-config-target target)
        current (config.get opts)
        val (str.join [...])]

    (if (a.empty? val)
      (a.println target "=" (a.pr-str current))
      (config.assoc
        (a.assoc
          opts :val
          (fennel.eval val))))))

(defn- assoc-initial-config []
  (when nvim.g.conjure_config
    (-?>> nvim.g.conjure_config
          (a.map-indexed
            (fn [[target val]]
              (a.merge
                (parse-config-target target)
                {:val val})))
          (a.run! config.assoc))))

(defn init [filetypes]
  (nvim.ex.augroup :conjure_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," filetypes)
    (bridge.viml->lua :conjure.mapping :on-filetype {}))
  (nvim.ex.autocmd
    :CursorMoved :*
    (bridge.viml->lua :conjure.log :close-hud {}))
  (nvim.ex.autocmd
    :CursorMovedI :*
    (bridge.viml->lua :conjure.log :close-hud {}))
  (nvim.ex.augroup :END)
  (assoc-initial-config))

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
  "-nargs=+ ConjureConfig"
  (bridge.viml->lua
    :conjure.mapping :config-command
    {:args "<f-args>"}))
