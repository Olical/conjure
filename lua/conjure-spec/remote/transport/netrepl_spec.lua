-- [nfnl] Compiled from fnl/conjure-spec/remote/transport/netrepl_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local before_each = _local_1_["before-each"]
local assert = require("luassert.assert")
local trn = require("conjure.remote.transport.netrepl")
local function _2_()
  local function _3_()
    local function _4_()
      assert.are.equals("\3\0\0\0foo", trn.encode("foo"))
      return assert.are.equals("\6\0\0\0foobar", trn.encode("foobar"))
    end
    return it("no partial messages", _4_)
  end
  describe("encode", _3_)
  local function _5_()
    local function _6_()
      local decode = trn.decoder()
      assert.same({"foo"}, decode(trn.encode("foo")))
      return assert.same({"foo bar baz"}, decode(trn.encode("foo bar baz")))
    end
    return it("When full message, only that message arrives", _6_)
  end
  describe("decoder-simple", _5_)
  local function _7_()
    local function _8_()
      local decode = trn.decoder()
      assert.same({"foo"}, decode(trn.encode("foo")))
      return assert.same({"foo", "bar", "baz"}, decode((trn.encode("foo") .. trn.encode("bar") .. trn.encode("baz"))))
    end
    return it("Full message, but multiple packed into the same chunk", _8_)
  end
  describe("decoder-multi", _7_)
  local function _9_()
    local function _10_()
      local decode = trn.decoder()
      local msg = trn.encode("Hello, World!")
      local a = string.sub(msg, 1, 7)
      local b = string.sub(msg, 8)
      assert.same({}, decode(a))
      return assert.same({"Hello, World!"}, decode(b))
    end
    it("Partial messages cut across multiple chunks 1/3", _10_)
    local function _11_()
      local decode = trn.decoder()
      local msg = trn.encode("Hello, World!")
      local a = string.sub(msg, 1, 7)
      local b = string.sub(msg, 8)
      assert.same({"Hey!"}, decode((trn.encode("Hey!") .. a)))
      return assert.same({"Hello, World!", "Yo!"}, decode((b .. trn.encode("Yo!"))))
    end
    it("Partial messages cut across multiple chunks 2/3", _11_)
    local function _12_()
      local decode = trn.decoder()
      local msg = trn.encode("Hello, World!")
      local a = string.sub(msg, 1, 4)
      local b = string.sub(msg, 5)
      assert.same({}, decode(a))
      assert.same({"Hello, World!", "foo"}, decode((b .. trn.encode("foo") .. a)))
      return assert.same({"Hello, World!", "bar"}, decode((b .. trn.encode("bar"))))
    end
    return it("Partial messages cut across multiple chunks 3/3", _12_)
  end
  describe("decoder-partial", _9_)
  local function _13_()
    local function _14_()
      local decode = trn.decoder()
      local msg = "error: could not find module ./dev/janet/oter:\n    dev/janet/oter.jimage\n    dev/janet/oter.janet\n    dev/janet/oter/init.janet\n    dev/janet/oter.so\n  in require [boot.janet] on line 2272, column 20\n  in import* [boot.janet] on line 2292, column 15\n  in _thunk [repl] (tailcall) on line 4, column 37\n"
      return assert.same({msg}, decode(trn.encode(msg)))
    end
    return it("Problematic message", _14_)
  end
  return describe("decoder-long", _13_)
end
return describe("conjure.remote.transport.netrepl", _2_)
