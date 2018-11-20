(ns conjure.core)

(defn init []
  #?(:clj :lang-clj
     :cljs :lang-cljs))
