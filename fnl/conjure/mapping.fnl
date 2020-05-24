(module conjure.mapping
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            text conjure.text
            config conjure.config
            extract conjure.extract
            client conjure.client
            eval conjure.eval
            bridge conjure.bridge
            fennel conjure.aniseed.fennel}})

(defn desc [buf-res group-name val]
  (let [wk-var (a.get-in config [:which-key :var])]
    (when (and buf-res (not buf-res.raw?) wk-var)
      (let [orig (nvim.get_var wk-var)
            keys (text.chars buf-res.unprefixed)]
        (a.assoc-in orig keys val)
        (when (> (a.count keys) 1)
          (a.assoc-in orig [(a.first keys) :name]
                      (.. "+" group-name)))
        (nvim.set_var wk-var orig)))))

(defn buf [mode keys ...]
  (when keys
    (let [args [...]
          raw? (a.table? keys)
          unprefixed (if raw?
                       (a.first keys)
                       keys)
          prefixed (if raw?
                     unprefixed
                     (.. config.mappings.prefix unprefixed))]
      (nvim.buf_set_keymap
        0 mode
        prefixed
        (if (= 2 (a.count args))
          (.. ":" (bridge.viml->lua (unpack args)) "<cr>")
          (unpack args))
        {:silent true
         :noremap true})

      {:unprefixed unprefixed
       :prefixed prefixed
       :raw? raw?})))

(defn map-fn [mappings]
  (fn [mode group cfg->args]
    (a.run!
      (fn [[cfg args]]
        (desc
          (buf mode (a.get mappings cfg) (unpack args))
          group cfg))
      (a.kv-pairs cfg->args))))

(defn on-filetype []
  (let [map (map-fn config.mappings)]
    (map :n :eval
         {:eval-motion [":set opfunc=ConjureEvalMotion<cr>g@"]
          :eval-current-form [:conjure.eval :current-form]
          :eval-root-form [:conjure.eval :root-form]
          :eval-replace-form [:conjure.eval :replace-form]
          :eval-marked-form [:conjure.eval :marked-form]
          :eval-word [:conjure.eval :word]
          :eval-file [:conjure.eval :file]
          :eval-buf [:conjure.eval :buf]})

    (map :n :util
         {:doc-word [:conjure.eval :doc-word]
          :def-word [:conjure.eval :def-word]})

    (map :v :eval
         {:eval-visual [:conjure.eval :selection]})

    (map :n :log
         {:log-split [:conjure.log :split]
          :log-vsplit [:conjure.log :vsplit]
          :log-tab [:conjure.log :tab]
          :log-close-visible [:conjure.log :close-visible]}))

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

(nvim.ex.command_
  "ConjureSchool"
  (bridge.viml->lua :conjure.school :start {}))
