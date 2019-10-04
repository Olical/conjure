(ns conjure.config-test
  (:require [clojure.test :as t]
            [conjure.config :as config]))

(t/deftest fetch
  (t/testing "empty"
    (binding [config/gather! (constantly nil)]
      (t/is (= (config/fetch) nil))))

  (t/testing "basic"
    (binding [config/gather! (constantly {:conns {:foo {:port 5555}}})]
      (t/is (= (config/fetch)
               {:conns {:foo {:port 5555
                              :host "127.0.0.1"
                              :lang :clj
                              :expr (#'config/default-exprs :clj)
                              :enabled? true}}}))))

  (t/testing "flags"
    (binding [config/gather! (constantly {:conns {:foo {:port 5555}
                                                  :bar {:port 5556, :enabled? false}}})]
      (t/is (= (config/fetch)
               {:conns {:foo {:port 5555
                              :host "127.0.0.1"
                              :lang :clj
                              :expr (#'config/default-exprs :clj)
                              :enabled? true}
                        :bar {:port 5556
                              :host "127.0.0.1"
                              :lang :clj
                              :expr (#'config/default-exprs :clj)
                              :enabled? false}}}))

      (t/is (= (config/fetch {:flags "+bar -foo bad $also -notgood"})
               {:conns {:foo {:port 5555
                              :host "127.0.0.1"
                              :lang :clj
                              :expr (#'config/default-exprs :clj)
                              :enabled? false}
                        :bar {:port 5556
                              :host "127.0.0.1"
                              :lang :clj
                              :expr (#'config/default-exprs :clj)
                              :enabled? true}}}))))

  (t/testing "hooks"
    (t/testing "entirely optional"
      (binding [config/gather! (constantly {:conns {:foo {:port 5555}}})]
        (t/is (nil? (config/hook {:config (config/fetch), :hook :refresh})))))

    (t/testing "conn level"
      (binding [config/gather! (constantly {:conns {:foo
                                                    {:port 5555
                                                     :hooks {:refresh '([x] (prn x))}}}})]
        (t/is (nil? (config/hook {:config (config/fetch), :hook :refresh})))
        (t/is (= '([x] (prn x))
                 (config/hook {:config (config/fetch)
                               :hook :refresh
                               :tag :foo})))))

    (t/testing "top level"
      (binding [config/gather! (constantly {:conns {:foo {:port 5555}}
                                            :hooks {:refresh '([x] (prn x))}})]
        (t/is (= '([x] (prn x))
                 (config/hook {:config (config/fetch)
                               :hook :refresh})))
        (t/is (= '([x] (prn x))
                 (config/hook {:config (config/fetch)
                               :hook :refresh
                               :tag :foo})))))

    (t/testing "override with conn level"
      (binding [config/gather! (constantly {:conns {:foo
                                                    {:port 5555
                                                     :hooks {:refresh '([x] (prn x))}}}
                                            :hooks {:refresh '([y] (prn y))}})]
        (t/is (= '([y] (prn y))
                 (config/hook {:config (config/fetch)
                               :hook :refresh})))
        (t/is (= '([x] (prn x))
                 (config/hook {:config (config/fetch)
                               :hook :refresh
                               :tag :foo})))))))
