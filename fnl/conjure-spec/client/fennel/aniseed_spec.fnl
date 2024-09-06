(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local a (require :nfnl.core))
(local ani (require :conjure.client.fennel.aniseed))

(describe "client.fennel.aniseed"
  (fn []
    (local ex-mod "test.foo.bar")
    (local ex-file "/some-big/ol/path/test/foo/bar.fnl")
    (local ex-file2 "/some-big/ol/path/test/foo/bar/init.fnl")
    (local ex-no-file "/some-big/ol/path/test/foo/bar/no/init.fnl")

    (fn contains? [s substr]
      (values
        substr
        (if (string.find s substr)
          substr
          s)))

    (describe "module-name"
      (fn []
        (tset package.loaded ex-mod {:my :module})

        (it "default name"
          (fn []
            (assert.are.equals ani.default-module-name (ani.module-name nil nil))))
        (it "ex-mod and ex-file"
          (fn []
            (assert.are.equals ex-mod (ani.module-name ex-mod ex-file))))
        (it "ex-file and no ex-mod"
          (fn []
            (assert.are.equals ex-mod (ani.module-name nil ex-file))))
        (it "ex-file2 and no ex-mod"
          (fn []
            (assert.are.equals ex-mod (ani.module-name nil ex-file2))))
        (it "default module name when no ex-file"
          (fn []
            (assert.are.equals ani.default-module-name (ani.module-name nil ex-no-file))))

        (tset package.loaded ex-mod nil)
    ))
    (describe "eval-str"
       (fn []
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

         (it "evaluates a form"
             (fn []
               (assert.same {:raw [30] :result "30"} (eval! "(+ 10 20)"))))
         (it "eval a function definition"
             (fn []
               (let [{: raw : result} (eval! "(fn hi [] 10)")]
                 (assert.are.equals :function (type (a.first raw)))
                 (assert.are.equals :string (type result))
                 (assert.is_not_nil (contains? result "#<function: "))
                 )))
         (it "evaluates a function"
             (fn []
               (assert.same {:raw [10] :result "10"} (eval! "(hi)"))))
         (it "evaulates unknown identifier"
             (fn []
               (let [{: result : raw} (eval! "(ohno)")]
                 (assert.are.equals (contains? result "Compile error: unknown identifier: ohno")))))

         (tset package.loaded :foo.bar nil)))
    (describe "repl"
      (fn []
        (let [foo-opts {:filename "foo.fnl"
                        :moduleName :foo}
              bar-opts {:filename "bar.fnl"
                        :moduleName :bar}
              bash-repl
              (fn [opts]
                (let [name (. opts :moduleName)
                      eval! (ani.repl opts)]
                  (it (..  "evaluate a form in module " name)
                    (fn []
                      (assert.same {:ok? true :results [3]} (eval! "(+ 1 2)"))
                      ))

                  (it (..  "create local and evaluate a form with it in module " name)
                    (fn []
                      (assert.same {:ok? true :results []} (eval! "(local hi 10)"))
                      (assert.same {:ok? true :results [15]} (eval! "(+ 5 hi)"))
                      ))

                  (it (..  "create def and evaluate a form with it in module " name)
                    (fn []
                      (assert.same {:ok? true :results []} (eval! "(def hi2 20)"))
                      (assert.same {:ok? true :results [25]} (eval! "(+ 5 hi2)"))
                      ))))]

      (bash-repl foo-opts)
      (bash-repl foo-opts)
      (tset package.loaded foo-opts.moduleName nil)

      (bash-repl bar-opts)
      (bash-repl bar-opts)
      (tset package.loaded bar-opts.moduleName nil))))))
