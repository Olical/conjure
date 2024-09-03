(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local fs (autoload :conjure.fs))
(local nvim (autoload :conjure.aniseed.nvim))
(local util (autoload :conjure.util))

(fn percent-fn [total-fn]
  (fn [pc]
    (math.floor (* (/ (total-fn) 100) (* pc 100)))))

(fn width []
  vim.o.columns)

(fn height []
  vim.o.lines)

(local percent-width (percent-fn width))
(local percent-height (percent-fn height))

(fn cursor-left []
  (vim.fn.screencol))

(fn cursor-top []
  (vim.fn.screenrow))

(fn go-to [path-or-win line column]
  (when (a.string? path-or-win)
    (nvim.ex.edit (fs.localise-path path-or-win)))

  (nvim.win_set_cursor
    (if (= :number (type path-or-win))
      path-or-win
      0)
    [line (a.dec column)]))

(fn go-to-mark [m]
  (nvim.ex.normal_ (.. "`" m)))

(fn go-back []
  (nvim.ex.normal_ (util.replace-termcodes "<c-o>")))

(fn has-filetype? [ft]
  (a.some #(= ft $1) (nvim.fn.getcompletion ft :filetype)))

{: width
 : height
 : percent-width
 : percent-height
 : cursor-left
 : cursor-top
 : go-to
 : go-to-mark
 : go-back
 : has-filetype?}
