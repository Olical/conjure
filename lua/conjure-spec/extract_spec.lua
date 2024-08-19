-- [nfnl] Compiled from fnl/conjure-spec/extract_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local extract = require("conjure.extract")
local nvim = require("conjure.aniseed.nvim")
local function _2_()
  local function at(cursor)
    return nvim.win_set_cursor(0, cursor)
  end
  local function setup(lines)
    nvim.ex.silent_("syntax", "on")
    nvim.ex.silent_("filetype", "on")
    nvim.ex.silent_("set", "filetype", "clojure")
    nvim.ex.silent_("edit", (nvim.fn.tempname() .. "_test.clj"))
    return nvim.buf_set_lines(0, 0, -1, false, lines)
  end
  local function teardown()
    return nvim.ex.silent_("bdelete!")
  end
  local function _3_()
    setup({"(ns foo)", "", "(+ 10 20 (* 10 2))"})
    local function _4_()
      at({3, 10})
      return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}))
    end
    it("inside the form", _4_)
    local function _5_()
      at({3, 9})
      return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}))
    end
    it("on the opening paren", _5_)
    local function _6_()
      at({3, 16})
      return assert.same({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}))
    end
    it("on the closing paren", _6_)
    local function _7_()
      at({3, 8})
      return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({}))
    end
    it("one before the inner form", _7_)
    local function _8_()
      at({3, 17})
      return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({}))
    end
    it("on the last paren of the outer form", _8_)
    local function _9_()
      at({2, 0})
      return assert.are.equals(nil, extract.form({}))
    end
    it("matching nothing", _9_)
    local function _10_()
      at({1, 0})
      return assert.same({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(ns foo)"}, extract.form({}))
    end
    it("ns form", _10_)
    return teardown()
  end
  describe("current-form", _3_)
  local function _11_()
    setup({"(ns foo)", "", "(+ 10 20 (* 10 2))"})
    local function _12_()
      at({3, 10})
      return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
    end
    it("root from inside a child form", _12_)
    local function _13_()
      at({3, 6})
      return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
    end
    it("root from the root", _13_)
    local function _14_()
      at({3, 0})
      return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
    end
    it("root from the opening paren of the root", _14_)
    local function _15_()
      at({3, 9})
      return assert.same({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}))
    end
    it("root from the opening paren of the child form", _15_)
    local function _16_()
      at({2, 0})
      return assert.equals(nil, extract.form({["root?"] = true}))
    end
    it("matching nothing for root", _16_)
    return teardown()
  end
  describe("root-form", _11_)
  local function _17_()
    setup({"(ns ohno)", "", "(inc", " ; ()", " 5)"})
    local function _18_()
      at({4, 0})
      return assert.same({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; ()\n 5)"}, extract.form({}))
    end
    it("skips the comment paren with current form", _18_)
    local function _19_()
      at({4, 0})
      return assert.same({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; ()\n 5)"}, extract.form({["root?"] = true}))
    end
    it("skips the comment paren with root form", _19_)
    return teardown()
  end
  describe("ignoring-comments", _17_)
  local function _20_()
    setup({"(str \\))"})
    local function _21_()
      at({1, 0})
      return assert.same({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(str \\))"}, extract.form({}))
    end
    it("escaped parens are skipped over", _21_)
    teardown()
    setup({"(ns foo)", "", "(+ 10 20 (* 10 2))", "", "(+ 1 2)", "; )", "", "(+ 4 6)"})
    local function _22_()
      at({5, 2})
      return assert.same({range = {start = {5, 0}, ["end"] = {5, 6}}, content = "(+ 1 2)"}, extract.form({["root?"] = true}))
    end
    it("root from a form with a commented closing paren on the next line", _22_)
    return teardown()
  end
  return describe("escaped-parens", _20_)
end
return describe("extract", _2_)
