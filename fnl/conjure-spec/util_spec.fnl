(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local util (require :conjure.util))

(describe
  "wrap-require-fn-call"
  (fn []
    (it "creates a fn that requries a file and calls a fn"
        (fn []
          (set package.loaded.example-module
               {:wrapped-fn-example (fn [] :hello-world!)})
          (assert.equals
            :hello-world!
            ((util.wrap-require-fn-call
               "example-module"
               "wrapped-fn-example")))))))

(describe
  "replace-termcodes"
  (fn []
    (it "escapes sequences like <C-o>"
        (fn []
          (assert.equals
            "hello\015world"
            (util.replace-termcodes "hello<C-o>world"))))))

(describe
  "ordered-distinct"
  (fn []
    (it "[:a] gives [:a]"
        (fn []
          (assert.same [:a] (util.ordered-distinct [:a]))))

    (it "[:b :b :a] gives [:b :a]"
        (fn []
          (assert.same [:b :a] (util.ordered-distinct [:b :b :a]))))

    (it "[:b :c :b :a :c :a] gives [:b :c :a]"
        (fn []
          (assert.same [:b :c :a] (util.ordered-distinct [:b :c :b :a :c :a]))))))

