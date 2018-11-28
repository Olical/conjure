(ns conjure.repl
  (:require [#?(:clj clojure.repl, :cljs cljs.repl) :as repl]))

(defn safe-call
  "Executes the given function and catches any errors, the errors are printed to stdout as a string.
  target-ns is the symbol of the namespace you want the code evaluated in."

  [f target-ns]

  (try
    (f)

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
     `(prn (with-out-str (repl/doc ~name)))

     :cljs
     ;; ClojureScript already captures and prints in one go.
     `(repl/doc ~name)))

(defn greet []
  (str "Ready to evaluate " #?(:clj "Clojure", :cljs "ClojureScript") "!"))

;; Clojure's load-file will show the last form in the file.
;; ClojureScript is weirdly async so we delay it and prn
#?(:clj
   (println (greet))

   :cljs
   (js/setTimeout #(println (greet)) 0))
