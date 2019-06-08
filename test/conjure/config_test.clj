(ns conjure.config-test
  (:require [clojure.test :as t]
            [conjure.config :as config]))

(t/deftest fetch
  (binding [config/gather (constantly {:conns {:foo {:port 5555}}})]
    (t/is (= (config/fetch nil)
             {:conns {:foo {:port 5555
                            :host "127.0.0.1"
                            :lang :clj
                            :expr (#'config/default-exprs :clj)
                            :enabled? true}}}))))
