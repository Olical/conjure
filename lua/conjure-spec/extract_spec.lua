-- [nfnl] fnl/conjure-spec/extract_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local extract = require("conjure.extract")
local _local_2_ = require("conjure-spec.util")
local with_buf = _local_2_["with-buf"]
local function ex(...)
  local result = extract.form(...)
  if result then
    result.node = nil
  else
  end
  return result
end
local function _4_()
  local function _5_()
    local function _6_(at)
      local function _7_()
        at({3, 10})
        return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, ex({}))
      end
      it("inside the form", _7_)
      local function _8_()
        at({3, 9})
        return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, ex({}))
      end
      it("on the opening paren", _8_)
      local function _9_()
        at({3, 16})
        return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, ex({}))
      end
      it("on the closing paren", _9_)
      local function _10_()
        at({3, 8})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, ex({}))
      end
      it("one before the inner form", _10_)
      local function _11_()
        at({3, 17})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, ex({}))
      end
      it("on the last paren of the outer form", _11_)
      local function _12_()
        at({2, 0})
        return assert.are.equals(nil, ex({}))
      end
      it("matching nothing", _12_)
      local function _13_()
        at({1, 0})
        return assert.same({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(ns foo)"}, ex({}))
      end
      return it("ns form", _13_)
    end
    return with_buf({"(ns foo)", "", "(+ 10 20 (* 10 2))"}, _6_)
  end
  describe("current-form", _5_)
  local function _14_()
    local function _15_(at)
      local function _16_()
        at({3, 10})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, ex({["root?"] = true}))
      end
      it("root from inside a child form", _16_)
      local function _17_()
        at({3, 6})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, ex({["root?"] = true}))
      end
      it("root from the root", _17_)
      local function _18_()
        at({3, 0})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, ex({["root?"] = true}))
      end
      it("root from the opening paren of the root", _18_)
      local function _19_()
        at({3, 9})
        return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, ex({["root?"] = true}))
      end
      it("root from the opening paren of the child form", _19_)
      local function _20_()
        at({2, 0})
        return assert.equals(nil, ex({["root?"] = true}))
      end
      return it("matching nothing for root", _20_)
    end
    return with_buf({"(ns foo)", "", "(+ 10 20 (* 10 2))"}, _15_)
  end
  describe("root-form", _14_)
  local function _21_()
    local function _22_(at)
      local function _23_()
        at({4, 0})
        return assert.same({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; ()\n 5)"}, ex({}))
      end
      it("skips the comment paren with current form", _23_)
      local function _24_()
        at({4, 0})
        return assert.same({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; ()\n 5)"}, ex({["root?"] = true}))
      end
      return it("skips the comment paren with root form", _24_)
    end
    return with_buf({"(ns ohno)", "", "(inc", " ; ()", " 5)"}, _22_)
  end
  describe("ignoring-comments", _21_)
  local function _25_()
    local function _26_(at)
      local function _27_()
        at({1, 0})
        return assert.same({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(str \\))"}, ex({}))
      end
      return it("escaped parens are skipped over", _27_)
    end
    with_buf({"(str \\))"}, _26_)
    local function _28_(at)
      local function _29_()
        at({5, 2})
        return assert.same({range = {start = {5, 0}, ["end"] = {5, 6}}, content = "(+ 1 2)"}, ex({["root?"] = true}))
      end
      return it("root from a form with a commented closing paren on the next line", _29_)
    end
    return with_buf({"(ns foo)", "", "(+ 10 20 (* 10 2))", "", "(+ 1 2)", "; )", "", "(+ 4 6)"}, _28_)
  end
  return describe("escaped-parens", _25_)
end
return describe("extract", _4_)
