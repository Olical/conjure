(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local nvim (autoload :conjure.aniseed.nvim))
(local nu (autoload :conjure.aniseed.nvim.util))
(local str (autoload :conjure.aniseed.string))
(local config (autoload :conjure.config))
(local client (autoload :conjure.client))
(local ts (autoload :conjure.tree-sitter))
(local searchpair (autoload :conjure.extract.searchpair))

(fn form [opts]
  (if (ts.enabled?)
    (ts.node->table
      (if opts.root?
        (ts.get-root)
        (ts.get-form)))
    (searchpair.form opts)))

; https://stackoverflow.com/questions/15020143/vim-script-check-if-the-cursor-is-on-the-current-word/15058922
(fn legacy-word []
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

(fn word []
  (if (ts.enabled?)
    (let [node (ts.get-leaf)]
      (if node
        {:range (ts.range node)
         :content (ts.node->str node)}
        {:range nil
         :content nil}))
    (legacy-word)))

(fn file-path []
  (nvim.fn.expand "%:p"))

(fn buf-last-line-length [buf]
  (a.count (a.first (nvim.buf_get_lines buf (a.dec (nvim.buf_line_count buf)) -1 false))))

(fn range [start end]
  {:content (str.join "\n" (nvim.buf_get_lines 0 start end false))
   :range {:start [(a.inc start) 0]
           :end [end (buf-last-line-length 0)]}})

(fn buf []
  (range 0 -1))

(fn getpos [expr]
  (let [[_ start end _] (nvim.fn.getpos expr)]
    [start (a.dec end)]))

(fn selection [{:kind kind :visual? visual?}]
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

(fn context []
  (let [pat (client.get :context-pattern)
        f (if pat
            #(string.match $1 pat)
            (client.get :context))]
    (when f
      (->> (nvim.buf_get_lines
             0 0 (config.get-in [:extract :context_header_lines]) false)
           (str.join "\n")
           (f)))))

(fn prompt [prefix]
  (let [(ok? val) (pcall #(nvim.fn.input (or prefix "")))]
    (when ok?
      val)))

(fn prompt-char []
  (nvim.fn.nr2char (nvim.fn.getchar)))

{: form
 : legacy-word
 : word
 : file-path
 : range
 : buf
 : selection
 : context
 : prompt
 : prompt-char}
