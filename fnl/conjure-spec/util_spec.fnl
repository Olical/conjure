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
  "concat-nodup"
  (fn []
    (it "concats arrays [:a] and [:b] together"
        (fn []
          (assert.same [:a :b] (util.concat-nodup [:a] [:b]))))

    (it "concats arrays [:a] and [:a] together to get [:a]"
        (fn []
          (assert.same [:a] (util.concat-nodup [:a] [:a]))))

    (it "concats arrays [:a :b] and [:c :a] together to get [:a :b :c]"
        (fn []
          (assert.same [:a :b :c] (util.concat-nodup [:a :b] [:c :a]))))))

(describe
  "dedup"
  (fn []
    (it "dedup array [:a] gives [:a]"
        (fn []
          (assert.same [:a] (util.dedup [:a]))))

    (it "dedup array [:a :b :b] gives [:a :b]"
        (fn []
          (assert.same [:a :b] (util.dedup [:a :b :b]))))

    (it "dedup array [:a :b :c :b :a :c] gives [:a :b :c]"
        (fn []
          (assert.same [:a :b :c] (util.dedup [:a :b :c :b :a :c]))))))

(describe
  "make-prefix-filter"
  (fn []
    (it "filters to aaa from aaa bbb abb with prefix aa"
        (fn []
          (let [filter (util.make-prefix-filter "aa")]
            (assert.same [:aaa] (filter [:aaa :bbb :abb])))))

    (it "filters to %thing from aaa %thing b%b with prefix %"
        (fn []
          (let [filter (util.make-prefix-filter "%")]
            (assert.same [:%thing] (filter [:aaa :%thing :b%b])))))

    (it "filters nothing from aaa word 2342 with prefix nil"
        (fn []
          (let [filter (util.make-prefix-filter nil)]
            (assert.same [:aaa :word :2342] (filter [:aaa :word :2342])))))))

