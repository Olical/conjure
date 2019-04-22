(ns conjure.nvim-test
  (:require [clojure.test :as t]
            [conjure.nvim :as nvim]
            [conjure.nvim.api :as api]))

(t/deftest current-ctx
  (with-redefs [api/call (constantly 5)
                api/call-batch (constantly
                                 ["foo.clj"
                                  ["(ns foo)"]
                                  10])]
    (t/is (= (nvim/current-ctx)
             {:path "foo.clj"
              :buf 5
              :win 10
              :ns 'foo}))))
