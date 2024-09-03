(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local clj (require :conjure.client.clojure.nrepl))

(describe "client.clojure.nrepl.init"
  (fn []
    (describe "context"
      (fn []

        (it "isn't a namespace"
          (fn []
            (assert.are.equals nil (clj.context "not a namespace"))))
        (it "simplest form"
          (fn []
            (assert.are.equals "foo" (clj.context "(ns foo)"))))
        (it "missing closing paren"
          (fn []
            (assert.are.equals "foo" (clj.context "(ns foo"))))
        (it "short meta"
          (fn []
            (assert.are.equals "foo" (clj.context "(ns ^:bar foo baz)"))))
        (it "short meta missing closing paren"
          (fn []
            (assert.are.equals "foo" (clj.context "(ns ^:bar foo baz"))))
        (it "long meta"
          (fn []
            (assert.are.equals "foo" (clj.context "(ns ^{:bar true} foo baz)"))))
        (it "newlines and docs"
          (fn []
            (assert.are.equals "foo" (clj.context "(ns \n^{:bar true} foo\n \"some docs\"\n baz"))))
        (it "strip shebang"
          (fn []
            (assert.are.equals "foo" (clj.context "#!/usr/bin/env bb\n(ns ^:bar foo)\n(def foo1 1)"))))

        (it "namespace metadata doesn't break evaluation"
          (fn []
            ;; https://github.com/Olical/conjure/issues/204
            (assert.are.equals "foo" (clj.context "(ns ^{:clj-kondo/config {:lint-as '{my-awesome/defn-like-macro clojure.core/defn}}} foo)"))
            (assert.are.equals "foo" (clj.context "(ns ^{:clj-kondo/config {:lint-as (quote {my-awesome/defn-like-macro clojure.core/defn})}} foo)"))))
        (it ") before namespace"
          (fn []
            ;; https://github.com/Olical/conjure/issues/207
            (assert.are.equals "foo" (clj.context "(ns ;)\n  foo)"))
            (assert.are.equals "foo" (clj.context "(ns ^{:doc \"...... (....) (..)))...\"}\n  foo)" b))))))))
