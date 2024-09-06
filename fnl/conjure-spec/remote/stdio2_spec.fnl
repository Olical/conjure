(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local stdio (require :conjure.remote.stdio2))

(describe "conjure.remote.stdio2"
  (fn []
    (describe "parse-cmd"
      (fn []
        (it "parses a string"
          (fn []
            (assert.same {:cmd "foo" :args []} (stdio.parse-cmd "foo"))))
        (it "parses a list of one string"
          (fn []
            (assert.same {:cmd "foo" :args []} (stdio.parse-cmd ["foo"]))))
        (it "parses a string with words separated by spaces"
          (fn []
            (assert.same {:cmd "foo" :args ["bar" "baz"]} (stdio.parse-cmd "foo bar baz"))))
        (it "parses a list of more than one string"
          (fn []
            (assert.same {:cmd "foo" :args ["bar" "baz"]} (stdio.parse-cmd ["foo" "bar" "baz"]))))))))
