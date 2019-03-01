(ns conjure.dev
  "Boots up the entire development environment."
  (:require [figwheel.main.api :as fig]
            [clojure.core.server :as server]))

(defn -main []
  (future
    (loop []
      (if (fig/repl-env "dev")
        (do
          (server/start-server {:accept 'cljs.core.server/io-prepl
                                :address "127.0.0.1"
                                :port 5885
                                :name "dev"
                                :args [:repl-env (fig/repl-env "dev")]})
          (println "[Conjure] Started socket prepl on port 5885"))
        (do
          (Thread/sleep 500)
          (recur)))))

  (fig/start
    {:id "dev"
     :options {:main 'conjure.main
               :target :nodejs}
     :config {:watch-dirs ["src"]}})

  (shutdown-agents))
