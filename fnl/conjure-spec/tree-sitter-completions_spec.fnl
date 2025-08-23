(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local tsc (require :conjure.tree-sitter-completions))

(describe
  "make-prefix-filter"
  (fn []
    (it "filters to aaa from aaa bbb abb with prefix aa"
        (fn []
          (let [filter (tsc.make-prefix-filter "aa")]
            (assert.same [:aaa] (filter [:aaa :bbb :abb])))))

    (it "filters to %thing from aaa %thing b%b with prefix %"
        (fn []
          (let [filter (tsc.make-prefix-filter "%")]
            (assert.same [:%thing] (filter [:aaa :%thing :b%b])))))

    (it "filters nothing from aaa word 2342 with prefix nil"
        (fn []
          (let [filter (tsc.make-prefix-filter nil)]
            (assert.same [:aaa :word :2342] (filter [:aaa :word :2342])))))))

