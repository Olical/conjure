(ns conjure.nvim-test
  (:require [clojure.test :as t]
            [clojure.string :as str]
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
  (defmethod call :nvim-buf-get-name [{[buf] :params}]
    (t/is (= buf 5))
    "foo.clj")
  (defmethod call :nvim-buf-get-lines [{[buf] :params}]
    (t/is (= buf 5))
    ["(ns foo)"])

  (t/is (= (nvim/current-ctx)
           {:path "foo.clj"
            :buf 5
            :win 10
            :ns 'foo})))

#_
(t/deftest read-form
  (defmethod call :nvim-get-current-buf [_] 5)
  (defmethod call :nvim-get-current-win [_] 10)
  (defmethod call :nvim-eval [_] "e")
  (defmethod call :nvim-call-function [{[_ [s _ e args]] :params}]
    (get {["()" :b] [2 16]
          ["()" :f] [2 30]}
         [(str s e)
          (if (str/starts-with? args "b")
            :b
            :f)]
         [0 0]))
  (defmethod call :nvim-win-get-cursor [{[win] :params}]
    (t/is (= win 10))
    [2 18])
  (defmethod call :nvim-buf-get-lines [{[buf start end] :params}]
    (t/is (= buf 5))
    (t/is (= start 1))
    (t/is (= end 2))
    ["(+ 10 10)"
     "[:foo] {:x :y} (hello (world)) [:bar]"
     ":hello"])

  (t/is (= (nvim/read-form) "(hello (world))")))
