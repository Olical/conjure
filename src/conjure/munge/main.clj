(ns conjure.munge.main
  "Munge dependencies for injection at runtime."
  (:require [clojure.java.io :as io]
            [clojure.tools.namespace.find :as find]
            [clojure.tools.namespace.parse :as parse]
            [clojure.tools.namespace.file :as file]
            [clojure.tools.namespace.dependency :as dep]
            [mranderson.core :as ma]))

(def ma-root (io/file "target/mranderson"))

(defn -main []
  (ma/mranderson {:clojars "https://repo.clojars.org"
                  :central "https://repo.maven.apache.org/maven2"}
                 (map #(with-meta % {:inline-dep true})
                      (read-string (slurp "injected-deps.edn")))
                 {:pname "conjure"
                  :pversion "0.0.0"
                  :pprefix "conjure"
                  :srcdeps ma-root}
                 {:src-path ma-root
                  :parent-clj-dirs []
                  :branch []})

  (let [parsed (into {} (map
                          (fn [file]
                            (let [decl (file/read-file-ns-decl file)]
                              [(parse/name-from-ns-decl decl)
                               {:file file
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
         (spit (io/file ma-root "load-order.edn"))))

  (shutdown-agents))
