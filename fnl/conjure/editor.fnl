(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local fs (autoload :conjure.fs))
(local util (autoload :conjure.util))

(local M (define :conjure.editor))

(fn percent-fn [total-fn]
  (fn [pc]
    (math.floor (* (/ (total-fn) 100) (* pc 100)))))

(fn M.width []
  vim.o.columns)

(fn M.height []
  vim.o.lines)

(set M.percent-width (percent-fn M.width))
(set M.percent-height (percent-fn M.height))

(fn M.cursor-left []
  (vim.fn.screencol))

(fn M.cursor-top []
  (vim.fn.screenrow))

(fn M.go-to [path-or-win line column]
  (when (core.string? path-or-win)
    (vim.cmd.edit (fs.localise-path path-or-win)))

  (vim.api.nvim_win_set_cursor
    (if (= :number (type path-or-win))
      path-or-win
      0)
    [line (core.dec column)]))

(fn M.go-to-mark [m]
  (vim.cmd (.. "normal! `" m)))

(fn M.go-back []
  (vim.cmd (.. "normal! " (util.replace-termcodes "<c-o>"))))

(fn M.has-filetype? [ft]
  (core.some #(= ft $1) (nvim.fn.getcompletion ft :filetype)))

M
