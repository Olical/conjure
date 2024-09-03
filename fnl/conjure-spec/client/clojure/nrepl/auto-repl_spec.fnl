(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local auto-repl (require :conjure.client.clojure.nrepl.auto-repl))

(describe "client.clojure.nrepl.auto-repl"
  (fn []
    (describe "enportify"
      (fn []
        (it "subject is foo"
          (fn []
            (assert.same {:subject "foo"} (auto-repl.enportify "foo"))))

        (let [{: subject : port} (auto-repl.enportify "foo:$port")]
          (it "port is in string form"
            (fn []
              (assert.are.equals "string" (type port))))
          (it "port number is between 1000 and 100000"
            (fn []
              (assert.is_true (< 1000 (tonumber port) 100000))))
          (it "subject is foo:port"
            (fn []
              (assert.are.equals (.. "foo:" port) subject)))
          )

    ))
  ))
