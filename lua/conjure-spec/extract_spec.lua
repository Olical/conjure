-- [nfnl] Compiled from fnl/conjure-spec/extract_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local extract = require("conjure.extract")
local _local_2_ = require("conjure-spec.util")
local with_buf = _local_2_["with-buf"]
local function _3_()
  local function _4_()
    local function _5_(at)
      local function _6_()
        at({3, 10})
        return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}))
      end
      it("inside the form", _6_)
      local function _7_()
        at({3, 9})
        return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}))
      end
      it("on the opening paren", _7_)
      local function _8_()
        at({3, 16})
        return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}))
      end
      it("on the closing paren", _8_)
      local function _9_()
        at({3, 8})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({}))
      end
      it("one before the inner form", _9_)
      local function _10_()
        at({3, 17})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({}))
      end
      it("on the last paren of the outer form", _10_)
      local function _11_()
        at({2, 0})
        return assert.are.equals(nil, extract.form({}))
      end
      it("matching nothing", _11_)
      local function _12_()
        at({1, 0})
        return assert.same({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(ns foo)"}, extract.form({}))
      end
      return it("ns form", _12_)
    end
    return with_buf({"(ns foo)", "", "(+ 10 20 (* 10 2))"}, _5_)
  end
  describe("current-form", _4_)
  local function _13_()
    local function _14_(at)
      local function _15_()
        at({3, 10})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
      end
      it("root from inside a child form", _15_)
      local function _16_()
        at({3, 6})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
      end
      it("root from the root", _16_)
      local function _17_()
        at({3, 0})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
      end
      it("root from the opening paren of the root", _17_)
      local function _18_()
        at({3, 9})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
      end
      it("root from the opening paren of the child form", _18_)
      local function _19_()
        at({2, 0})
        return assert.equals(nil, extract.form({["root?"] = true}))
      end
      return it("matching nothing for root", _19_)
    end
    return with_buf({"(ns foo)", "", "(+ 10 20 (* 10 2))"}, _14_)
  end
  describe("root-form", _13_)
  local function _20_()
    local function _21_(at)
      local function _22_()
        at({4, 0})
        return assert.same({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; ()\n 5)"}, extract.form({}))
      end
      it("skips the comment paren with current form", _22_)
      local function _23_()
        at({4, 0})
        return assert.same({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; ()\n 5)"}, extract.form({["root?"] = true}))
      end
      return it("skips the comment paren with root form", _23_)
    end
    return with_buf({"(ns ohno)", "", "(inc", " ; ()", " 5)"}, _21_)
  end
  describe("ignoring-comments", _20_)
  local function _24_()
    local function _25_(at)
      local function _26_()
        at({1, 0})
        return assert.same({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(str \\))"}, extract.form({}))
      end
      return it("escaped parens are skipped over", _26_)
    end
    with_buf({"(str \\))"}, _25_)
    local function _27_(at)
      local function _28_()
        at({5, 2})
        return assert.same({range = {start = {5, 0}, ["end"] = {5, 6}}, content = "(+ 1 2)"}, extract.form({["root?"] = true}))
      end
      return it("root from a form with a commented closing paren on the next line", _28_)
    end
    return with_buf({"(ns foo)", "", "(+ 10 20 (* 10 2))", "", "(+ 1 2)", "; )", "", "(+ 4 6)"}, _27_)
  end
  return describe("escaped-parens", _24_)
end
return describe("extract", _3_)
