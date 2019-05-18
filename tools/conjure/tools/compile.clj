(ns conjure.tools.compile
  (:require [clojure.java.io :as io]
            [mranderson.core :as ma]))

(defn -main []
  ;; AOT compile Conjure's source.
  (compile 'conjure.main)

  (let [ma-root "target/mranderson"]
    ;; Map runtime deps through Mr Anderson.
    (ma/mranderson {:clojars "https://repo.clojars.org"}
                   (map #(with-meta % {:inline-dep true})
                        '[[compliment "0.3.8"]])
                   {:pname "conjure"
                    :pversion "0.0.0"
                    :pprefix "conjure"
                    :srcdeps ma-root}
                   {:src-path (io/file ma-root)
                    :parent-clj-dirs []
                    :branch []}))

  ;; Build a list of files to load in dependency order for runtime deps.
  )
