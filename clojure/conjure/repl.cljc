(ns conjure.repl
  (:require [#?(:clj clojure.repl, :cljs cljs.repl) :as repl]))

;; ClojureScript requires a little dance to get it self-evaluating.
;; @mfikes to the rescue yet again! https://gist.github.com/mfikes/66a120e18b75b6f4a3ecd0db8a976d84
#?(:cljs
   (do
     (require 'cljs.js)

     (let [eval *eval*
           st (cljs.js/empty-state)]
       (set! *eval*
             (fn [form]
               (binding [cljs.env/*compiler* st
                         cljs.js/*eval-fn* cljs.js/js-eval]
                 (eval form)))))))

(defn magic-eval
  "Evaluates the form and catches any errors, the errors are printed to stdout as a string.
  target-ns is the symbol of the namespace you want the code evaluated in."

  [form target-ns]

  (try
    (binding [*ns* (find-ns target-ns)]
      (eval form))

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
