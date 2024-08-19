(local nvim (require :conjure.aniseed.nvim))

(fn with-buf [lines f]
  (let [at (fn [cursor]
             (nvim.win_set_cursor 0 cursor))]
    (nvim.ex.silent_ :syntax :on)
    (nvim.ex.silent_ :filetype :on)
    (nvim.ex.silent_ :set :filetype :clojure)
    (nvim.ex.silent_ :edit (.. (nvim.fn.tempname) "_test.clj"))
    (nvim.buf_set_lines 0 0 -1 false lines)
    (f at)
    (nvim.ex.silent_ :bdelete!)))

{: with-buf}
