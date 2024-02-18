local _2afile_2a = "test/fnl/conjure/client/clojure/nrepl/init-test.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.init-test"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local clj = require("conjure.client.clojure.nrepl")
do end (_2amodule_locals_2a)["clj"] = clj
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["="](nil, clj.context("not a namespace"), "isn't a namespace")
    t["="]("foo", clj.context("(ns foo)"), "simplest form")
    t["="]("foo", clj.context("(ns foo"), "missing closing paren")
    t["="]("foo", clj.context("(ns ^:bar foo baz)"), "short meta")
    t["="]("foo", clj.context("(ns ^:bar foo baz"), "short meta missing closing paren")
    t["="]("foo", clj.context("(ns ^{:bar true} foo baz)"), "long meta")
    t["="]("foo", clj.context("(ns \n^{:bar true} foo\n \"some docs\"\n baz"), "newlines and docs")
    t["="]("foo", clj.context("#!/usr/bin/env bb\n(ns ^:bar foo)\n(def foo1 1)", "strip shebang"))
    t["="]("foo", clj.context("(ns ^{:clj-kondo/config {:lint-as '{my-awesome/defn-like-macro clojure.core/defn}}} foo)"))
    t["="]("foo", clj.context("(ns ^{:clj-kondo/config {:lint-as (quote {my-awesome/defn-like-macro clojure.core/defn})}} foo)"))
    t["="]("foo", clj.context("(ns ;)\n  foo)"))
    return t["="]("foo", clj.context("(ns ^{:doc \"...... (....) (..)))...\"}\n  foo)"))
  end
  tests_24_auto["context"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a