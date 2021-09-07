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
  (var last-error nil)
  (let [capture #(set last-error [$1 $2 $3])
        foo-opts {:filename "foo.fnl"
                  :moduleName :foo
                  :onError capture}
        bar-opts {:filename "bar.fnl"
                  :moduleName :bar
                  :onError capture}
        bash-repl (fn [opts]
                    (let [eval! (ani.repl opts)]
                      (t.pr= [3] (eval! "(+ 1 2)"))

                      (t.pr= [] (eval! "(local hi 10)"))
                      (t.pr= [15] (eval! "(+ 5 hi)"))

                      (t.pr= [] (eval! "(def hi2 20)"))
                      (t.pr= [25] (eval! "(+ 5 hi2)"))

                      (t.pr= nil (eval! "(ohno)"))
                      (t.= "Compile" (a.first last-error))
                      (t.= (contains? (a.second last-error) "unknown global in strict mode: ohno"))

                      (t.= nil (eval! "(())"))
                      (t.= "Compile" (a.first last-error))
                      (t.= (contains? (a.second last-error) "expected a function"))))]

    (bash-repl foo-opts)
    (bash-repl foo-opts)
    (bash-repl bar-opts)
    (bash-repl bar-opts)))
