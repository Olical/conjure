(defproject dev "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.10.1"]
                 [org.clojure/tools.logging "1.1.0"]]
  :plugins [[cider/cider-nrepl "0.24.0"]]
  :source-paths ["dev/clojure/src"]
  :repl-options {:init-ns dev.sandbox})
