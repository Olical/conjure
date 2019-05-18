(ns conjure.tools.compile
  (:require [clojure.java.io :as io]
            [clojure.tools.namespace.find :as find]
            [clojure.tools.namespace.parse :as parse]
            [clojure.tools.namespace.file :as file]
            [clojure.tools.namespace.dependency :as dep]
            [mranderson.core :as ma]))

(def ma-root (io/file "target/mranderson"))

(defn -main []
  ;; AOT compile Conjure's source.
  (compile 'conjure.main)

  ;; Map runtime deps through Mr Anderson.
  (ma/mranderson {:clojars "https://repo.clojars.org"
                  :central "https://repo.maven.apache.org/maven2"}
                 (map #(with-meta % {:inline-dep true})
                      '[[compliment "0.3.8"]
                        [org.clojure/tools.namespace "0.3.0-alpha4"]])
                 {:pname "conjure"
                  :pversion "0.0.0"
                  :pprefix "conjure"
                  :srcdeps ma-root}
                 {:src-path ma-root
                  :parent-clj-dirs []
                  :branch []})

  ;; Build a list of files to load in dependency order for runtime deps.
  (let [parsed (into {} (map
                          (fn [file]
                            (let [decl (file/read-file-ns-decl file)]
                              [(parse/name-from-ns-decl decl)
                               {:file file
                                :name (parse/name-from-ns-decl decl)
                                :deps (parse/deps-from-ns-decl decl)}])))
                     (find/find-sources-in-dir ma-root))]
    (->> (vals parsed)
         (reduce
           (fn [g {:keys [deps] :as node}]
             (reduce
               (fn [g dep]
                 (if-let [target (get parsed dep)]
                   (dep/depend g node target)
                   g))
               g
               deps))
           (dep/graph))
         (dep/topo-sort)
         (mapv (comp str :file))
         (pr-str)
         (spit (io/file ma-root "load-order.edn")))))
