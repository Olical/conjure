(fn with-buf [lines f]
  (let [at (fn [cursor]
             (vim.api.nvim_win_set_cursor 0 cursor))]
    (vim.cmd "silent! syntax on")
    (vim.cmd "silent! filetype on")
    (vim.cmd "silent! set filetype=clojure")
    (vim.cmd (.. "silent! edit " (vim.fn.tempname) "_test.clj"))
    (vim.api.nvim_buf_set_lines 0 0 -1 false lines)
    (f at)
    (vim.cmd "silent! bdelete!")))

{: with-buf}
