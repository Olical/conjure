(module conjure.test.buffer
  {require {nvim conjure.aniseed.nvim}})

(defn with-buf [lines f]
  (let [at (fn [cursor]
             (nvim.win_set_cursor 0 cursor))]
    (nvim.ex.syntax :on)
    (nvim.ex.filetype :on)
    (nvim.ex.split (.. (nvim.fn.tempname) "_test.clj"))
    (set nvim.o.filetype :clojure)
    (nvim.buf_set_lines 0 0 -1 false lines)
    (f at)
    (nvim.ex.bdelete_)))
