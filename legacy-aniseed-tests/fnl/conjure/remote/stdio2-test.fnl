(module conjure.remote.stdio2-test
  {require {stdio conjure.remote.stdio2}})

(deftest parse-cmd
  (t.pr= {:cmd "foo" :args []} (stdio.parse-cmd "foo"))
  (t.pr= {:cmd "foo" :args []} (stdio.parse-cmd ["foo"]))
  (t.pr= {:cmd "foo" :args ["bar" "baz"]} (stdio.parse-cmd "foo bar baz"))
  (t.pr= {:cmd "foo" :args ["bar" "baz"]} (stdio.parse-cmd ["foo" "bar" "baz"])))
