(module conjure.usage
  {require {nvim conjure.aniseed.nvim
            fennel conjure.aniseed.fennel
            a conjure.aniseed.core
            str conjure.aniseed.string
            config conjure.config
            conjure-client conjure.client
            eval conjure.eval
            extract conjure.extract
            fs conjure.fs}})

(def clojure
  {:url
   (.. "https://gist.githubusercontent.com" "/tami5/"
       "14c0098691ce57b1c380c9c91dbdd322" "/raw/"
       "b859bd867115960bc72a49903e2b8de0ce249c31" "/"
       "clojure.docs.fnl")
   :path (.. (fs.cache-dir) "/" "clj-docs.fnl")
   :ft "fennel"})

(defn- get-msg [client mtype]
  "Error msg pased on error type."
  (let [f string.format]
    (match mtype
      :not-supported (f "'%s' client is not supported" client)
      :fetch-err (f "CONJURE-ERROR: %s usage doc could not downloaded.
                  Try again, or open an issue." client)
      :fetching (f "CONJURE: fetching usage defs for %s ......." client)
      :caching (f "CONJURE: caching usage defs for %s ......." client))))

(defn- get-in-client [client key]
  "Retrun a client key value."
  (. (match client
       :clojure clojure
       (error (get-msg client :not-supported))) key))

(defn- dl-defs [client cb]
  "Download doc usage file."
  (let [path (get-in-client client :path)]
    (if (fs.exists? path) (cb)
      (let [args ["curl" "-L" (get-in-client client :url) "-o" path]
            on_exit #(if (fs.exists? path) (cb)
                       (error (get-msg client :fetch-err)))]
        (print (get-msg client :fetching))
        (vim.fn.jobstart args {:on_exit on_exit})))))

(defn- up-defs [client cb]
  "Redownload client usage defs/file."
  (vim.fn.jobstart
    ["rm" (get-in-client client :path)]
    {:on_exit #(dl-defs :clojure cb)}))

(defn- cached-defs? [client]
  "Returns true if client.cache is nil."
  (not (a.nil? (. (. *module* client) :defs))))

(defn- cache-defs [client cb]
  "Fill client runtime cache with usage defs."
  (let [path (get-in-client client :path)
        parse (match (get-in-client client :ft)
                "fennel" #(fennel.dofile path)
                "json" #(vim.fn.json_decode (vim.fn.readfile path)))]
    (dl-defs client
              (vim.schedule_wrap
                #(do (print (get-msg client :caching))
                   (tset (. *module* client) :defs (parse))
                   (cb))))))

(defn- ensure-defs [client cb]
  "Ensure that cache is filled."
    (if (cached-defs? client) (cb)
      (cache-defs client cb)))

(defn- get-in-defs [client sym]
  "Get namespace/symbol from client defs."
  (a.get (get-in-client client :defs) sym))

(defn- parse-sym-usage [client kv]
  "Parses a symbol's dict to markdown section and content."
  (let [sec (match client
              :clojure {:notes kv.notes
                        :examples kv.examples
                        :info kv.doc
                        :also kv.see-alsos
                        :signture [kv.name kv.arglists]
                        :header [kv.ns kv.name]})
        formatlist (fn [xs title template] ;; TODO: Refactor
                     (var res [])
                     (var count 1)
                     (when (not (a.empty? xs))
                       (table.insert res title)
                       (table.insert res "--------------")
                       (a.run! (fn [item]
                                 (->> (-> template
                                          (string.format count (str.trim item))
                                          (vim.split "\n"))
                                      (table.insert res))
                                 (set count (+ count 1))) xs)
                       (vim.tbl_flatten res)))
        header [(string.format "%s/%s" (unpack sec.header))
                "=============="]
        signture [(->> (a.get-in sec [:signture 2])
                       (a.map #(string.format
                                 "`(%s %s)`"
                                 (a.get-in sec [:signture 1]) $1))
                       (str.join " ")) " "]
        info [(a.map str.trim (vim.split sec.info "\n")) " "]
        examples (formatlist
                   sec.examples "Usage"
                   "### Example %d:\n\n```clojure\n%s\n```\n--------------\n")
        notes (formatlist
                sec.notes "Notes"
                "### Note %d:\n%s\n\n--------------\n")
        see-also (when (not (a.empty? sec.also))
                   ["See Also" "--------------"
                    (a.map #(string.format "* `%s`" $1) sec.also) " "])]
    (vim.tbl_flatten [header signture info see-also examples notes])))

(defn- get-ns-sym [client sym cb]
  (match client
    :clojure (conjure-client.with-filetype
               client eval.eval-str
               {:origin client
                :code (match client
                        :clojure (string.format "(resolve '%s)" sym))
                :passive? true
                :on-result #(cb (string.gsub $1 "#'" ""))})))

(defn- draw-border [opts style]
  (let [style (or style ["─" "│" "╭" "╮" "╰" "╯"])
        top (.. (a.get style 3)
                (string.rep (a.get style 1) (+ opts.width 2))
                (a.get style 4))
        mid (.. (a.get style 2)
                (string.rep " " (+ opts.width 2))
                (a.get style 2))
        bot (.. (a.get style 5)
                (string.rep (a.get style 1) (+ opts.width 2))
                (a.get style 6))
        lines (let [lines [top]] ;; there must be a better way
                (for [_ 2 (+ opts.height 1) 1]
                  (table.insert lines mid))
                (table.insert lines bot) lines)
        winops (a.merge opts {:row (- opts.row 1)
                              :height (+ opts.height 2)
                              :col (- opts.col 2)
                              :width (+ opts.width 4)})
        bufnr (vim.fn.nvim_create_buf false true)
        winid (vim.api.nvim_open_win bufnr true winops)]
    (vim.api.nvim_buf_set_lines bufnr 0 -1 false lines)
    (vim.api.nvim_buf_add_highlight bufnr 0 "ConjureBorder" 1 0 -1)
    winid))

(defn- setup-buffer [bufnr content opts]
  (let [opts (a.merge
               {:filetype :markdown
                :buflisted false
                :buftype :nofile
                :bufhidden :wipe
                :swapfile false} opts)]
    (each [k v (pairs opts)]
      (vim.api.nvim_buf_set_option bufnr k v))
    (vim.api.nvim_buf_set_lines bufnr 0 0 true content)
    (vim.api.nvim_win_set_cursor 0 [1 0])))

(defn- setup-win [opts]
  (let [winops (a.merge {:winblend 5 ;; FIXME: doesn't work
                         :conceallevel 3
                         :winhl "NormalFloat:Normal"}
                        opts.win)
        [primary border] [opts.primary-winid opts.border-winid]]
    (each [_ win (ipairs [primary border])]
      (each [k v (pairs winops)]
        (vim.api.nvim_win_set_option win k v)))
    (->> ["au" "WinClosed,WinLeave"
          (string.format "<buffer=%d>" opts.bufnr) ":bd!" "|" "call"
          (string.format "nvim_win_close(%d," border) "v:true)"]
        (str.join " ")
        vim.cmd)))

(defn- open-float [opts]
  (let [bufnr  (vim.fn.nvim_create_buf false true)
        winops (let [relative (or opts.relative "editor")
                     style (or opts.style "minimal")
                     fill (or opts.fill 0.8)
                     width (math.floor (* vim.o.columns fill))
                     height (math.floor (* vim.o.lines fill))
                     row (math.floor (- (/ (- vim.o.lines height) 2) 1))
                     col (math.floor (/ (- vim.o.columns width) 2))]
                 {: relative : style : width : height : row : col})
        border-winid (draw-border winops opts.border)
        primary-winid (vim.fn.nvim_open_win bufnr true winops)]

    (print " ") ;; clear prompt
    (setup-win {: opts.win : primary-winid : border-winid : bufnr})
    (setup-buffer bufnr opts.content opts.buf)))

(defn- open-split [opts]
  (print " ") ;; clear prompt
  (vim.cmd "new")
  (setup-buffer 0 opts.content opts.buf))

(defn- open-vsplit [opts]
  (print " ") ;; clear prompt
  (vim.cmd "vnew")
  (setup-buffer 0 opts.content opts.buf))

(defn get-usage [opts]
  "Main function of this namespace.
   Accepts a map defining a set configuration options.
    opts.clinet    :str:     The Client to use.
    opts.symbol    :str:     The symbol to search for.
    opts.display*  :str:     Display type: split, vsplit or float.
    opts.win       :dict:    Float window options.
    opts.fill      :num:     Float window size.
    opts.border    :list:    Float window Border.
    opts.buf       :dict:    Buffer specfic options."
  (let [client (or opts.client vim.bo.filetype)
        symbol (or opts.symbol (vim.fn.expand "<cword>"))
        cb (match opts.display :float open-float :split open-split :vsplit open-vsplit)]
    ;; add condition, if supported client, do this other wise error.
    ;; parse function should be decide here.
    (get-ns-sym client symbol
                (fn [ns-sym]
                  (ensure-defs ;; Doesn't make sense
                    client
                    #(cb (->> (->> (get-in-defs client ns-sym)
                                   (parse-sym-usage client))
                             (a.assoc opts :content))))))))

(defn get-usage-float [opts]
  (get-usage
    {:display :float :fill 0.8 :win {:winblend 0}}))

(defn get-usage-vsplit [opts]
  (get-usage
    {:display :vsplit}))

(defn get-usage-split [opts]
  (get-usage
    {:display :split}))
