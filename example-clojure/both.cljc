(defn run []
  #?(:clj (prn "This is Clojure!")
     :cljs (prn "This is ClojureScript!")))

(run)
