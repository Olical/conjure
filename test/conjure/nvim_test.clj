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

(t/deftest read-form
  (let [src ["(+ 10 10)"
             "[:foo] {:x :y} (hello (world)) [:bar]"
             ":hello"]
        pair-pos (fn [[_ [s _ e args]] positions]
                   (get positions
                        (if (str/starts-with? args "b") s e)
                        [0 0]))]
    (defmethod call :nvim-get-current-buf [_] 5)
    (defmethod call :nvim-get-current-win [_] 10)
    (defmethod call :nvim-eval [_]
      (let [[row col] (call {:method :nvim-win-get-cursor})]
        (str (get-in src [(dec row) col]))))
    (defmethod call :nvim-buf-get-lines [{[buf start end] :params}]
      (t/is (= buf 5))
      (->> src
           (drop start)
           (take (- end start))
           (vec)))

    (t/testing "basic paren form"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params
                  {"(" [2 16]
                   ")" [2 30]}))
      (defmethod call :nvim-win-get-cursor [_] [2 17])
      (t/is (= (nvim/read-form) "(hello (world))")))

    (t/testing "cursor on a boundary"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params
                  {"(" [1 1]
                   ")" [2 29]}))
      (defmethod call :nvim-win-get-cursor [_] [2 22])
      (t/is (= (nvim/read-form) "(world)")))

    (t/testing "root of an inner form"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params
                  {"(" [2 16]
                   ")" [2 30]}))
      (defmethod call :nvim-win-get-cursor [_] [2 22])
      (t/is (= (nvim/read-form {:root? true}) "(hello (world))")))))

(t/deftest read-buffer
  (defmethod call :nvim-get-current-buf [_] 5)
  (defmethod call :nvim-buf-get-lines [{[buf start end strict-indexing?] :params}]
    (t/is (= buf 5))
    (t/is (= start 0))
    (t/is (= end -1))
    (t/is (false? strict-indexing?))
    ["foo" "bar"])

  (t/is (= (nvim/read-buffer) "foo\nbar")))
