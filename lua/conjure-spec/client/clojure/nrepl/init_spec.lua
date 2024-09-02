-- [nfnl] Compiled from fnl/conjure-spec/client/clojure/nrepl/init_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local a = require("nfnl.core")
local clj = require("conjure.client.clojure.nrepl")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.are.equals(nil, clj.context("not a namespace"))
    end
    it("isn't a namespace", _4_)
    local function _5_()
      return assert.are.equals("foo", clj.context("(ns foo)"))
    end
    it("simplest form", _5_)
    local function _6_()
      return assert.are.equals("foo", clj.context("(ns foo"))
    end
    it("missing closing paren", _6_)
    local function _7_()
      return assert.are.equals("foo", clj.context("(ns ^:bar foo baz)"))
    end
    it("short meta", _7_)
    local function _8_()
      return assert.are.equals("foo", clj.context("(ns ^:bar foo baz"))
    end
    it("short meta missing closing paren", _8_)
    local function _9_()
      return assert.are.equals("foo", clj.context("(ns ^{:bar true} foo baz)"))
    end
    it("long meta", _9_)
    local function _10_()
      return assert.are.equals("foo", clj.context("(ns \n^{:bar true} foo\n \"some docs\"\n baz"))
    end
    it("newlines and docs", _10_)
    local function _11_()
      return assert.are.equals("foo", clj.context("#!/usr/bin/env bb\n(ns ^:bar foo)\n(def foo1 1)"))
    end
    it("strip shebang", _11_)
    local function _12_()
      assert.are.equals("foo", clj.context("(ns ^{:clj-kondo/config {:lint-as '{my-awesome/defn-like-macro clojure.core/defn}}} foo)"))
      return assert.are.equals("foo", clj.context("(ns ^{:clj-kondo/config {:lint-as (quote {my-awesome/defn-like-macro clojure.core/defn})}} foo)"))
    end
    it("namespace metadata doesn't break evaluation", _12_)
    local function _13_()
      assert.are.equals("foo", clj.context("(ns ;)\n  foo)"))
      return assert.are.equals("foo", clj.context("(ns ^{:doc \"...... (....) (..)))...\"}\n  foo)", b))
    end
    return it(") before namespace", _13_)
  end
  return describe("context", _3_)
end
return describe("client.clojure.nrepl.init", _2_)
