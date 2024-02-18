local _2afile_2a = "test/fnl/conjure/remote/transport/netrepl-test.fnl"
local _2amodule_name_2a = "conjure.remote.transport.netrepl-test"
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
local trn = require("conjure.remote.transport.netrepl")
do end (_2amodule_locals_2a)["trn"] = trn
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["="]("\3\0\0\0foo", trn.encode("foo"))
    return t["="]("\6\0\0\0foobar", trn.encode("foobar"))
  end
  tests_24_auto["encode"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    local decode = trn.decoder()
    t["pr="]({"foo"}, decode(trn.encode("foo")))
    return t["pr="]({"foo bar baz"}, decode(trn.encode("foo bar baz")))
  end
  tests_24_auto["decoder-simple"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    local decode = trn.decoder()
    t["pr="]({"foo"}, decode(trn.encode("foo")))
    return t["pr="]({"foo", "bar", "baz"}, decode((trn.encode("foo") .. trn.encode("bar") .. trn.encode("baz"))))
  end
  tests_24_auto["decoder-multi"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _4_(t)
    do
      local decode = trn.decoder()
      local msg = trn.encode("Hello, World!")
      local a = string.sub(msg, 1, 7)
      local b = string.sub(msg, 8)
      t["pr="]({}, decode(a))
      t["pr="]({"Hello, World!"}, decode(b))
    end
    do
      local decode = trn.decoder()
      local msg = trn.encode("Hello, World!")
      local a = string.sub(msg, 1, 7)
      local b = string.sub(msg, 8)
      t["pr="]({"Hey!"}, decode((trn.encode("Hey!") .. a)))
      t["pr="]({"Hello, World!", "Yo!"}, decode((b .. trn.encode("Yo!"))))
    end
    local decode = trn.decoder()
    local msg = trn.encode("Hello, World!")
    local a = string.sub(msg, 1, 4)
    local b = string.sub(msg, 5)
    t["pr="]({}, decode(a))
    t["pr="]({"Hello, World!", "foo"}, decode((b .. trn.encode("foo") .. a)))
    return t["pr="]({"Hello, World!", "bar"}, decode((b .. trn.encode("bar"))))
  end
  tests_24_auto["decoder-partial"] = _4_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _5_(t)
    local decode = trn.decoder()
    local msg = "error: could not find module ./dev/janet/oter:\n    dev/janet/oter.jimage\n    dev/janet/oter.janet\n    dev/janet/oter/init.janet\n    dev/janet/oter.so\n  in require [boot.janet] on line 2272, column 20\n  in import* [boot.janet] on line 2292, column 15\n  in _thunk [repl] (tailcall) on line 4, column 37\n"
    return t["pr="]({msg}, decode(trn.encode(msg)))
  end
  tests_24_auto["decoder-long"] = _5_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a