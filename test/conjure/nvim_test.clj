(ns conjure.nvim-test
  (:require [clojure.test :as t]
            [conjure.nvim :as nvim]
            [conjure.nvim.api :as api]))

(defmulti call :method)

(t/use-fixtures
  :each
  (fn [f]
    (try
      (defmethod call :default [{:keys [method] :as req}]
        (throw (ex-info (str "Unhandled call: " method) req)))

      (binding [api/call call
                api/call-batch #(map call %)]
        (f))
      (finally
        (remove-all-methods call)))))

(t/deftest current-ctx
  (defmethod call :nvim-get-current-buf [_] 5)
  (defmethod call :nvim-get-current-win [_] 10)
  (defmethod call :nvim-buf-get-name [_] "foo.clj")
  (defmethod call :nvim-buf-get-lines [_] ["(ns foo)"])

  (t/is (= (nvim/current-ctx)
           {:path "foo.clj"
            :buf 5
            :win 10
            :ns 'foo})))
