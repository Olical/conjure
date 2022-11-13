(module conjure.client.clojure.nrepl.auto-repl-test
  {require {auto-repl conjure.client.clojure.nrepl.auto-repl}})

(deftest enportify
  (t.pr= {:subject "foo"} (auto-repl.enportify "foo"))

  (let [{: subject : port} (auto-repl.enportify "foo:$port")]
    (t.= "string" (type port))
    (t.ok? (< 1000 (tonumber port) 100000))
    (t.= (.. "foo:" port) subject)))
