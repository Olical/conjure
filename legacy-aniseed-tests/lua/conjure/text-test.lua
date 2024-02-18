local _2afile_2a = "test/fnl/conjure/text-test.fnl"
local _2amodule_name_2a = "conjure.text-test"
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
local text = require("conjure.text")
do end (_2amodule_locals_2a)["text"] = text
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["="]("", text["left-sample"]("", 0), "handles empty strings")
    t["="]("f", text["left-sample"]("f", 1), "handles single characters")
    t["="]("foo bar", text["left-sample"]("foo bar", 10), "does nothing if correct")
    t["="]("foo bar", text["left-sample"]("foo    \n\n bar", 10), "replaces lots of whitespace with a space")
    t["="]("foo bar b...", text["left-sample"]("foo    \n\n bar \n\n baz", 10), "cuts the string if too long")
    return t["="]("foo bar", text["left-sample"]("   foo \n \n bar  \n", 10), "trims leading and trailing whitespace")
  end
  tests_24_auto["left-sample"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    return t["="]("...o bar baz", text["right-sample"]("foo    \n\n bar \n\n baz", 10), "same as left-sample, but we want the right")
  end
  tests_24_auto["right-sample"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    t["pr="]({""}, text["split-lines"](""), "nothing to nothing")
    t["pr="]({"foo", "bar"}, text["split-lines"]("foo\nbar"), "basic split")
    t["pr="]({"foo", "", "bar"}, text["split-lines"]("foo\n\nbar"), "blank lines")
    return t["pr="]({"foo", "bar"}, text["split-lines"]("foo\13\nbar"), "Windows CRLF")
  end
  tests_24_auto["split-lines"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _4_(t)
    t["pr="]({"; "}, text["prefixed-lines"]("", "; "), "nothing to nothing")
    t["pr="]({"; foo"}, text["prefixed-lines"]("foo", "; "), "single line")
    return t["pr="]({"; foo", "; bar"}, text["prefixed-lines"]("foo\nbar", "; "), "multiple lines")
  end
  tests_24_auto["prefixed-lines"] = _4_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _5_(t)
    t["="](true, text["starts-with"]("foobar", "foo"))
    t["="](true, text["starts-with"]("foobar", "foob"))
    t["="](false, text["starts-with"]("foobar", "foox"))
    return t["="](nil, text["starts-with"](nil, "ohno"))
  end
  tests_24_auto["starts-with"] = _5_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _6_(t)
    t["="](true, text["ends-with"]("foobar", "bar"))
    t["="](true, text["ends-with"]("foobar", "obar"))
    t["="](false, text["ends-with"]("foobar", "xbar"))
    return t["="](nil, text["ends-with"](nil, "ohno"))
  end
  tests_24_auto["ends-with"] = _6_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _7_(t)
    t["="]("()", text["first-and-last-chars"]("(hello-world)"))
    t["="]("", text["first-and-last-chars"](""))
    t["="]("(", text["first-and-last-chars"]("("))
    return t["="](nil, text["first-and-last-chars"](nil))
  end
  tests_24_auto["first-and-last-chars"] = _7_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _8_(t)
    t["pr="]({}, text.chars())
    t["pr="]({}, text.chars(""))
    return t["pr="]({"a", "b", "c"}, text.chars("abc"))
  end
  tests_24_auto["chars"] = _8_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _9_(t)
    t["="]("", text["upper-first"](""))
    t["="]("A", text["upper-first"]("A"))
    t["="]("A", text["upper-first"]("a"))
    t["="]("Foo bar bAZ 5", text["upper-first"]("foo bar bAZ 5"))
    t["="](nil, text["upper-first"](nil))
    return t["="]("123", text["upper-first"]("123"))
  end
  tests_24_auto["upper-first"] = _9_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a