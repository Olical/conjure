(module conjure.client.fennel.aniseed-test
  {require {a conjure.aniseed.core
            ani conjure.client.fennel.aniseed}})

(def ex-mod "test.foo.bar")
(def ex-file "/some-big/ol/path/test/foo/bar.fnl")
(def ex-file2 "/some-big/ol/path/test/foo/bar/init.fnl")
(def ex-no-file "/some-big/ol/path/test/foo/bar/no/init.fnl")

(deftest module-name
  (tset package.loaded ex-mod {:my :module})

  (t.= ani.default-module-name (ani.module-name nil nil))
  (t.= ex-mod (ani.module-name ex-mod ex-file))
  (t.= ex-mod (ani.module-name nil ex-file))
  (t.= ex-mod (ani.module-name nil ex-file2))
  (t.= ani.default-module-name (ani.module-name nil ex-no-file))

  (tset package.loaded ex-mod nil))

(defn contains? [s substr]
  (values
    substr
    (if (string.find s substr)
      substr
      s)))

(deftest repl
  (let [foo-opts {:filename "foo.fnl"
                  :moduleName :foo}
        bar-opts {:filename "bar.fnl"
                  :moduleName :bar}
        bash-repl (fn [opts]
                    (let [eval! (ani.repl opts)]
                      (t.pr= {:ok? true :results [3]} (eval! "(+ 1 2)"))

                      (t.pr= {:ok? true :results []} (eval! "(local hi 10)"))
                      (t.pr= {:ok? true :results [15]} (eval! "(+ 5 hi)"))

                      (t.pr= {:ok? true :results []} (eval! "(def hi2 20)"))
                      (t.pr= {:ok? true :results [25]} (eval! "(+ 5 hi2)"))

                      (let [{: results : ok?} (eval! "(ohno)")]
                        (t.= false ok?)
                        (t.= (contains? (a.first results) "Compile error: unknown identifier: ohno")))


                      (let [{: results : ok?} (eval! "(())")]
                        (t.= false ok?)
                        (t.= (contains? (a.first results) "expected a function")))))]

    (bash-repl foo-opts)
    (bash-repl foo-opts)
    (tset package.loaded foo-opts.moduleName nil)

    (bash-repl bar-opts)
    (bash-repl bar-opts)
    (tset package.loaded bar-opts.moduleName nil)))

(deftest eval-str
  (fn eval! [code]
    (var result nil)
    (var raw nil)
    (ani.eval-str
      {:code code
       :context "foo.bar"
       :passive? true
       :file-path "foo/bar.fnl"
       :on-result #(set result $1)
       :on-result-raw #(set raw $1)})
    {:result result
     :raw raw})

  (t.pr= {:raw [30] :result "30"} (eval! "(+ 10 20)"))

  (let [{: raw : result} (eval! "(fn hi [] 10)")]
    (t.= :function (type (a.first raw)))
    (t.= (contains? result "#<function: ")))

  (t.pr= {:raw [10] :result "10"} (eval! "(hi)"))

  (let [{: result : raw} (eval! "(ohno)")]
    (t.= (contains? result "Compile error: unknown identifier: ohno")))

  (tset package.loaded :foo.bar nil))
