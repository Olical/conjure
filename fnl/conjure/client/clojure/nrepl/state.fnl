(import-macros {: module : def : defn : defonce : def- : defn- : defonce- : wrap-last-expr : wrap-module-body : deftest} :nfnl.macros.aniseed)

(module conjure.client.clojure.nrepl.state
  {autoload {client conjure.client}})

(defonce get
  (client.new-state
    (fn []
      {:conn nil
       :auto-repl-port nil
       :auto-repl-proc nil
       :join-next {:key nil}})))

*module*
