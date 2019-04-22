(ns conjure.nvim-test
  (:require [clojure.test :as t]
            [conjure.nvim :as nvim]
            [conjure.rpc :as rpc]))

(defmulti request :method)

(t/use-fixtures
  :each
  (fn [f]
    (try
      (defmethod request :default [{:keys [method] :as req}]
        (throw (ex-info (str "Unhandled request: " method) req)))

      (defmethod request :nvim-call-atomic [{:keys [params]}]
        (map (fn [{:keys [method params]}]
               (request {:method method, :params params}))
             params))

      (binding [rpc/request request]
        (f))
      (finally
        (remove-all-methods request)))))

#_(t/deftest current-ctx
    (defmethod request :nvim-get-current-buf [_] 5)

    (t/is (= (nvim/current-ctx)
             {:path "foo.clj"
              :buf 5
              :win 10
              :ns 'foo})))
