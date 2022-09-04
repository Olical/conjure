(module conjure.client.clojure.nrepl.init-test
  {require {clj conjure.client.clojure.nrepl}})

(deftest context
  (t.= nil (clj.context "not a namespace") "isn't a namespace")
  (t.= "foo" (clj.context "(ns foo)") "simplest form")
  (t.= "foo" (clj.context "(ns foo") "missing closing paren")
  (t.= "foo" (clj.context "(ns ^:bar foo baz)") "short meta")
  (t.= "foo" (clj.context "(ns ^:bar foo baz") "short meta missing closing paren")
  (t.= "foo" (clj.context "(ns ^{:bar true} foo baz)") "long meta")
  (t.= "foo" (clj.context "(ns \n^{:bar true} foo\n \"some docs\"\n baz") "newlines and docs")
  (t.= "foo" (clj.context "#!/usr/bin/env bb\n(ns ^:bar foo)\n(def foo1 1)" "strip shebang"))

  ;; https://github.com/Olical/conjure/issues/204
  (t.= "foo" (clj.context "(ns ^{:clj-kondo/config {:lint-as '{my-awesome/defn-like-macro clojure.core/defn}}} foo)"))
  (t.= "foo" (clj.context "(ns ^{:clj-kondo/config {:lint-as (quote {my-awesome/defn-like-macro clojure.core/defn})}} foo)"))

  ;; https://github.com/Olical/conjure/issues/207
  (t.= "foo" (clj.context "(ns ;)\n  foo)"))
  (t.= "foo" (clj.context "(ns ^{:doc \"...... (....) (..)))...\"}\n  foo)")))
