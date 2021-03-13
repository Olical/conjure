(+ 10 20)

(import matplotlib)
(.use matplotlib "Qt5Agg")
(.rcdefaults matplotlib)
(.use matplotlib "Qt5Agg")

(import [matplotlib [pyplot]])

(.ion pyplot)
(pyplot.style.use "default")
(pyplot.style.use "fivethirtyeight")

(defn test []
 "Plot a list."
 (setv fig (.figure pyplot))
 (setv axes (.add_subplot fig))
 (.plot axes (list (range 20)))
 {:figure fig :axes axes})

(test)
