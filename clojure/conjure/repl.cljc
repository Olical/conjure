(ns conjure.repl
  (:require [#?(:clj clojure.repl, :cljs cljs.repl) :as repl]))

(defn magic-eval
  "Evaluates the form and catches any errors, the errors are printed to stdout as a string."

  [form]

  (try
    (eval form)

    #?(:clj
       (catch Throwable e
         (binding [*out* *err*]
           (println e)))

       :cljs
       ;; ClojureScript gives us :default as a catch all.
       (catch :default e
         (js/console.error e)))))

(defmacro doc
  "Looks up doc for the symbol and captures the out string which is re-printed in one go."

  [name]

  #?(:clj
     ;; If you're wondering why this is like this, check out the source of doc.
     ;; It prints through a series of prns which Conjure interprets as separate outputs.
     ;; So you end up with gaps between each part of the doc with timestamps.
     `(println (with-out-str (repl/doc ~name)))

     :cljs
     ;; ClojureScript already captures and prints in one go.
     `(repl/doc ~name)))

;; This last form is displayed in the log buffer, it's a handy check that
;; everything worked as expected and you're in the correct _kind_ of REPL.
(str "Ready to evaluate " #?(:clj "Clojure", :cljs "ClojureScript") "!")
