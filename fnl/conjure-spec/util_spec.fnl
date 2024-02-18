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
