(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local a (require :nfnl.core))
(local stdio (require :conjure.remote.stdio))

(describe "conjure.remote.stdio"
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
