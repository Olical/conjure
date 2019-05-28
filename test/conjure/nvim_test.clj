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
  (defmethod call :nvim-buf-line-count [_] 1)
  (defmethod call :nvim-buf-get-lines [{[buf] :params}]
    (t/is (= buf 5))
    ["(ns foo)"])
  (defmethod call :nvim-get-option [_] 300)

  (t/is (= (nvim/current-ctx)
           {:path "foo.clj"
            :buf 5
            :win 10
            :ns 'foo
            :columns 300})))

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

    (t/testing "no form"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params {}))
      (defmethod call :nvim-win-get-cursor [_] [2 17])
      (t/is (= (nvim/read-form) nil)))

    (t/testing "basic paren form"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params
                  {"(" [2 16]
                   ")" [2 30]}))
      (defmethod call :nvim-win-get-cursor [_] [2 17])
      (t/is (= (nvim/read-form)
               {:form "(hello (world))"
                :cursor [1 2]
                :origin [2 16]})))

    (t/testing "cursor on a boundary"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params
                  {"(" [1 1]
                   ")" [2 29]}))
      (defmethod call :nvim-win-get-cursor [_] [2 22])
      (t/is (= (nvim/read-form)
               {:form "(world)"
                :cursor [1 0]
                :origin [2 23]})))

    (t/testing "root of an inner form"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params
                  {"(" [2 16]
                   ")" [2 30]}))
      (defmethod call :nvim-win-get-cursor [_] [2 22])
      (t/is (= (nvim/read-form {:root? true})
               {:form "(hello (world))"
                :cursor [1 7]
                :origin [2 16]})))

    (t/testing "a skip is provided to non-root form reads"
      ;; Non-root has skip.
      (defmethod call :nvim-call-function [{:keys [params]}]
        (t/is (= (count (second params)) 5))
        (pair-pos params
                  {"(" [2 16]
                   ")" [2 30]}))
      (defmethod call :nvim-win-get-cursor [_] [2 17])
      (t/is (= (nvim/read-form)
               {:form "(hello (world))"
                :cursor [1 2]
                :origin [2 16]}))

      ;; Root does not.
      (defmethod call :nvim-call-function [{:keys [params]}]
        (t/is (= (count (second params)) 4))
        (pair-pos params
                  {"(" [2 16]
                   ")" [2 30]}))
      (defmethod call :nvim-win-get-cursor [_] [2 22])
      (t/is (= (nvim/read-form {:root? true})
               {:form "(hello (world))"
                :cursor [1 7]
                :origin [2 16]})))

    (t/testing "providing a win skips a call"
      (defmethod call :nvim-call-function [{:keys [params]}]
        (pair-pos params
                  {"(" [2 16]
                   ")" [2 30]}))
      (defmethod call :nvim-win-get-cursor [_] [2 17])
      (defmethod call :nvim-get-current-win [_]
        (throw (Error. "asked for win")))
      (t/is (thrown? Error (nvim/read-form)))
      (t/is (= (nvim/read-form {:win 10})
               {:form "(hello (world))"
                :cursor [1 2]
                :origin [2 16]})))))

(t/deftest read-buffer
  (defmethod call :nvim-get-current-buf [_] 5)
  (defmethod call :nvim-buf-get-lines [{[buf start end strict-indexing?] :params}]
    (t/is (= buf 5))
    (t/is (= start 0))
    (t/is (= end -1))
    (t/is (false? strict-indexing?))
    ["foo" "bar"])

  (t/is (= (nvim/read-buffer) "foo\nbar")))
