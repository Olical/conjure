(module conjure.editor
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            fs conjure.fs}})

(defn- percent-fn [total-fn]
  (fn [pc]
    (math.floor (* (/ (total-fn) 100) (* pc 100)))))

(defn width []
  nvim.o.columns)

(defn height []
  nvim.o.lines)

(def percent-width (percent-fn width))
(def percent-height (percent-fn height))

(defn cursor-left []
  (nvim.fn.screencol))

(defn cursor-top []
  (nvim.fn.screenrow))

(defn go-to [path-or-win line column]
  (when (a.string? path-or-win)
    (nvim.ex.edit (fs.resolve-relative path-or-win)))

  (nvim.win_set_cursor
    (if (= :number (type path-or-win))
      path-or-win
      0)
    [line (a.dec column)]))

(defn go-to-mark [m]
  (nvim.ex.normal_ (.. "`" m)))

(defn go-back []
  (nvim.ex.normal_ (nvim.replace_termcodes "<c-o>" true false true)))

(defn has-filetype? [ft]
  (a.some #(= ft $1) (nvim.fn.getcompletion ft :filetype)))
