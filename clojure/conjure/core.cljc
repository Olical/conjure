(ns conjure.core)

(defn wrapped-eval
  "Evaluates the form and catches any errors. The errors are printed to stdout as a string."

  [form]

  (try
    (eval form)

    #?(:clj
       (catch Exception e
         (binding [*out* *err*]
           (prn e)))

       :cljs
       (catch :default e
         (js/console.error e)))))

;; This last form is displayed in the log buffer, it's a handy check that
;; everything worked as expected and you're in the correct _kind_ of REPL.
(str "Ready to evaluate " #?(:clj "Clojure", :cljs "ClojureScript") "!")
