local _2afile_2a = "test/fnl/conjure/extract-test.fnl"
local _2amodule_name_2a = "conjure.extract-test"
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
local buffer, extract = require("conjure.test.buffer"), require("conjure.extract")
do end (_2amodule_locals_2a)["buffer"] = buffer
_2amodule_locals_2a["extract"] = extract
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    local function _2_(at)
      at({3, 10})
      t["pr="]({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}), "inside the form")
      at({3, 9})
      t["pr="]({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}), "on the opening paren")
      at({3, 16})
      t["pr="]({range = {start = {3, 9}, ["end"] = {3, 16}}, content = "(* 10 2)"}, extract.form({}), "on the closing paren")
      at({3, 8})
      t["pr="]({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({}), "one before the inner form")
      at({3, 17})
      t["pr="]({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({}), "on the last paren of the outer form")
      at({2, 0})
      t["="](nil, extract.form({}), "matching nothing")
      at({1, 0})
      return t["pr="]({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(ns foo)"}, extract.form({}), "ns form")
    end
    return buffer["with-buf"]({"(ns foo)", "", "(+ 10 20 (* 10 2))"}, _2_)
  end
  tests_24_auto["current-form"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    local function _4_(at)
      at({3, 10})
      t["pr="]({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}), "root from inside a child form")
      at({3, 6})
      t["pr="]({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}), "root from the root")
      at({3, 0})
      t["pr="]({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}), "root from the opening paren of the root")
      at({3, 9})
      t["pr="]({range = {start = {3, 0}, ["end"] = {3, 17}}, content = "(+ 10 20 (* 10 2))"}, extract.form({["root?"] = true}), "root from the opening paren of the child form")
      at({2, 0})
      return t["="](nil, extract.form({["root?"] = true}), "matching nothing for root")
    end
    return buffer["with-buf"]({"(ns foo)", "", "(+ 10 20 (* 10 2))"}, _4_)
  end
  tests_24_auto["root-form"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _5_(t)
    local function _6_(at)
      at({4, 0})
      t["pr="]({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; )\n 5)"}, extract.form({}), "skips the comment paren with current form")
      at({4, 0})
      return t["pr="]({range = {start = {3, 0}, ["end"] = {5, 2}}, content = "(inc\n ; )\n 5)"}, extract.form({["root?"] = true}), "skips the comment paren with root form")
    end
    return buffer["with-buf"]({"(ns ohno)", "", "(inc", " ; )", " 5)"}, _6_)
  end
  tests_24_auto["ignoring-comments"] = _5_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _7_(t)
    local function _8_(at)
      at({1, 0})
      return t["pr="]({range = {start = {1, 0}, ["end"] = {1, 7}}, content = "(str \\))"}, extract.form({}), "escaped parens are skipped over")
    end
    buffer["with-buf"]({"(str \\))"}, _8_)
    local function _9_(at)
      at({5, 2})
      return t["pr="]({range = {start = {5, 0}, ["end"] = {5, 6}}, content = "(+ 1 2)"}, extract.form({["root?"] = true}), "root from a form with a commented closing paren on the next line")
    end
    return buffer["with-buf"]({"(ns foo)", "", "(+ 10 20 (* 10 2))", "", "(+ 1 2)", "; )", "", "(+ 4 6)"}, _9_)
  end
  tests_24_auto["escaped-parens"] = _7_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a