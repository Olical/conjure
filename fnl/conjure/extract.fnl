(module conjure.extract
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             nu conjure.aniseed.nvim.util
             str conjure.aniseed.string
             config conjure.config
             client conjure.client
             ts conjure.tree-sitter
             searchpair conjure.extract.searchpair}})

(defn form [opts]
  (if (ts.enabled?)
    (ts.node->table
      (if opts.root?
        (ts.get-root)
        (ts.get-form)))
    (searchpair.form opts)))

; https://stackoverflow.com/questions/15020143/vim-script-check-if-the-cursor-is-on-the-current-word/15058922
(defn legacy-word []
  (let [cword (nvim.fn.expand "<cword>")
        line (nvim.fn.getline ".")
        cword-index
        (nvim.fn.strridx
         line
         cword
         (- (nvim.fn.col ".") 1))
        line-num (nvim.fn.line ".")]
   {:content cword
    :range {:start [line-num cword-index]
            :end [line-num (+ cword-index (length cword) -1)]}}))

(defn word []
  (if (ts.enabled?)
    (if-let [node (ts.get-leaf)]
      {:range (ts.range node)
       :content (ts.node->str node)}
      {:range nil
       :content nil})
    (legacy-word)))

(defn file-path []
  (nvim.fn.expand "%:p"))

(defn- buf-last-line-length [buf]
  (a.count (a.first (nvim.buf_get_lines buf (a.dec (nvim.buf_line_count buf)) -1 false))))

(defn range [start end]
  {:content (str.join "\n" (nvim.buf_get_lines 0 start end false))
   :range {:start [(a.inc start) 0]
           :end [end (buf-last-line-length 0)]}})

(defn buf []
  (range 0 -1))

(defn- getpos [expr]
  (let [[_ start end _] (nvim.fn.getpos expr)]
    [start (a.dec end)]))

(defn selection [{:kind kind :visual? visual?}]
  (let [sel-backup nvim.o.selection]
    (nvim.ex.let "g:conjure_selection_reg_backup = @@")
    (set nvim.o.selection :inclusive)

    (if
      visual? (nu.normal (.. "`<" kind "`>y"))
      (= kind :line) (nu.normal "'[V']y")
      (= kind :block) (nu.normal "`[`]y")
      (nu.normal "`[v`]y"))

    (let [content (nvim.eval "@@")]
      (set nvim.o.selection sel-backup)
      (nvim.ex.let "@@ = g:conjure_selection_reg_backup")
      {:content content
       :range {:start (getpos "'<")
               :end (getpos "'>")}})))

(defn context []
  (let [pat (client.get :context-pattern)
        f (if pat
            #(string.match $1 pat)
            (client.get :context))]
    (when f
      (->> (nvim.buf_get_lines
             0 0 (config.get-in [:extract :context_header_lines]) false)
           (str.join "\n")
           (f)))))

(defn prompt [prefix]
  (let [(ok? val) (pcall #(nvim.fn.input (or prefix "")))]
    (when ok?
      val)))

(defn prompt-char []
  (nvim.fn.nr2char (nvim.fn.getchar)))
