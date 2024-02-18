(module conjure.remote.stdio-test
  {require {stdio conjure.remote.stdio}})

(deftest parse-cmd
  (t.pr= {:cmd "foo" :args []} (stdio.parse-cmd "foo"))
  (t.pr= {:cmd "foo" :args []} (stdio.parse-cmd ["foo"]))
  (t.pr= {:cmd "foo" :args ["bar" "baz"]} (stdio.parse-cmd "foo bar baz"))
  (t.pr= {:cmd "foo" :args ["bar" "baz"]} (stdio.parse-cmd ["foo" "bar" "baz"])))
