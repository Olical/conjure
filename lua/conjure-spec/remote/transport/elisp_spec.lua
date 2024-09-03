-- [nfnl] Compiled from fnl/conjure-spec/remote/transport/elisp_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local elisp = require("conjure.remote.transport.elisp")
local function _2_()
  local function _3_()
    local function _4_()
      assert.are.equals(nil, elisp.read(""))
      assert.are.equals("foo", elisp.read("\"foo\""))
      assert.are.equals("foo", elisp.read("  \"foo\"  "))
      assert.are.equals("foo", elisp.read(":foo"))
      assert.are.equals("foo", elisp.read("   :foo    "))
      return assert.are.equals("bar", elisp.read("   :foo \"hi\" \n :bar  "))
    end
    it("strings and symbols", _4_)
    local function _5_()
      assert.are.equals(0, elisp.read("0"))
      assert.are.equals(1, elisp.read(" 1  "))
      assert.are.equals(0.5, elisp.read("  0.5"))
      assert.are.equals(30, elisp.read("   30 "))
      assert.are.equals(30.2, elisp.read("   30.2 "))
      assert.are.equals(0.2, elisp.read(".2 "))
      assert.are.equals(-0.3, elisp.read("   -.3 "))
      return assert.are.equals(-20.25, elisp.read("   -20.25 "))
    end
    it("numbers", _5_)
    local function _6_()
      assert.same({}, elisp.read("()"))
      assert.same({{}, {}}, elisp.read("(()())"))
      assert.same({1, {2, 3, 4}, 5, {6, "seven"}, "eight", 9}, elisp.read("(1 (2 3 4) 5 (6 \"seven\") :eight 9)"))
      return assert.same({1, 2, 3}, elisp.read("(1 2 3)"))
    end
    it("lists", _6_)
    local function _7_()
      return assert.same({"Class", ": ", {"value", "clojure.lang.PersistentArrayMap", 0}, {"newline"}, "Contents: ", {"newline"}, "  ", {"value", "a", 1}, " = ", {"value", "1", 2}, {"newline"}, "  ", {"value", "b", 3}, " = ", {"value", "2", 4}, {"newline"}}, elisp.read("(\"Class\" \": \" (:value \"clojure.lang.PersistentArrayMap\" 0) (:newline) \"Contents: \" (:newline) \"  \" (:value \"a\" 1) \" = \" (:value \"1\" 2) (:newline) \"  \" (:value \"b\" 3) \" = \" (:value \"2\" 4) (:newline))"))
    end
    return it("nested forms", _7_)
  end
  return describe("reads", _3_)
end
return describe("remote.transport.elisp", _2_)
