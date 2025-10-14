(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local config (autoload :conjure.config))
(local client (autoload :conjure.client))
(local ts (autoload :conjure.tree-sitter))
(local searchpair (autoload :conjure.extract.searchpair))

(local M (define :conjure.extract))

(fn M.form [opts]
  (if (ts.enabled?)
    (ts.node->table
      (if opts.root?
        (ts.get-root)
        (ts.get-form)))
    (searchpair.form opts)))

; https://stackoverflow.com/questions/15020143/vim-script-check-if-the-cursor-is-on-the-current-word/15058922
(fn M.legacy-word []
  (let [cword (vim.fn.expand "<cword>")
        line (vim.fn.getline ".")
        cword-index
        (vim.fn.strridx
         line
         cword
         (- (vim.fn.col ".") 1))
        line-num (vim.fn.line ".")]
   {:content cword
    :range {:start [line-num cword-index]
            :end [line-num (+ cword-index (length cword) -1)]}}))

(fn M.word []
  (if (ts.enabled?)
    (let [node (ts.get-leaf)]
      (if node
        {:range (ts.range node)
         :content (ts.node->str node)}
        {:range nil
         :content nil}))
    (M.legacy-word)))

(fn M.file-path []
  (vim.fn.expand "%:p"))

(fn buf-last-line-length [buf]
  (core.count (core.first (vim.api.nvim_buf_get_lines buf (core.dec (vim.api.nvim_buf_line_count buf)) -1 false))))

(fn M.range [start end]
  {:content (str.join "\n" (vim.api.nvim_buf_get_lines 0 start end false))
   :range {:start [(core.inc start) 0]
           :end [end (buf-last-line-length 0)]}})

(fn M.buf []
  (M.range 0 -1))

(fn getpos [expr]
  (let [[_ start end _] (vim.fn.getpos expr)]
    [start (core.dec end)]))

; Temporary replacement for nu.normal.
;   (local nu (autoload :conjure.aniseed.nvim.util))
(fn nu_normal [keys]
  (vim.cmd (.. "silent exe \"normal! " keys "\"")))

(fn M.selection [{:kind kind :visual? visual?}]
  (let [sel-backup vim.o.selection]
    (vim.cmd "let g:conjure_selection_reg_backup = @@")
    (set vim.o.selection :inclusive)

    (if
      visual? (nu_normal (.. "`<" kind "`>y"))
      (= kind :line) (nu_normal "'[V']y")
      (= kind :block) (nu_normal "`[`]y")
      (nu_normal "`[v`]y"))

    (let [content (vim.api.nvim_eval "@@")]
      (set vim.o.selection sel-backup)
      (vim.cmd "let @@ = g:conjure_selection_reg_backup")
      {:content content
       :range {:start (getpos "'<")
               :end (getpos "'>")}})))

(fn M.context []
  (let [pat (client.get :context-pattern)
        f (if pat
            #(string.match $1 pat)
            (client.get :context))]
    (when f
      (->> (vim.api.nvim_buf_get_lines
             0 0 (config.get-in [:extract :context_header_lines]) false)
           (str.join "\n")
           (f)))))

(fn M.prompt [prefix]
  (let [(ok? val) (pcall #(vim.fn.input (or prefix "")))]
    (when ok?
      val)))

(fn M.prompt-char []
  (vim.fn.nr2char (vim.fn.getchar)))

M
