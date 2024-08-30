-- [nfnl] Compiled from fnl/conjure-spec/client_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local before_each = _local_1_["before-each"]
local assert = require("luassert.assert")
local client = require("conjure.client")
local function _2_()
  local function _3_()
    return assert.is_false(client["multiple-states?"]())
  end
  return it("returns false before the first change", _3_)
end
describe("multiple-states? before a change", _2_)
local function _4_()
  local function _5_()
    return assert.equal("default", client["state-key"]())
  end
  return it("can be executed to get the current state key", _5_)
end
describe("state-key", _4_)
local function _6_()
  local function _7_()
    client["set-state-key!"]("new-key")
    return assert.equal("new-key", client["state-key"]())
  end
  return it("changes the state key value", _7_)
end
describe("set-state-key!", _6_)
local function _8_()
  local function _9_()
    return assert.is_true(client["multiple-states?"]())
  end
  return it("returns true after the first change", _9_)
end
describe("multiple-states? after a change", _8_)
local function _10_()
  local function _11_()
    local state
    local function _12_()
      return {foo = {bar = 1}}
    end
    state = client["new-state"](_12_)
    assert.is_function(state)
    assert.equal(1, state("foo", "bar"))
    client["set-state-key!"]("new-key")
    assert.equal(1, state("foo", "bar"))
    state("foo")["bar"] = 2
    assert.equal(2, state("foo", "bar"))
    client["set-state-key!"]("default")
    return assert.equal(1, state("foo", "bar"))
  end
  return it("returns a function we can use to look up the current state-key's data for this specific state, the function encloses it's own table of state indexed by state-key", _11_)
end
describe("new-state", _10_)
local function _13_()
  local function _14_()
    local function _15_()
      local function _16_()
        return client["current-client-module-name"]()
      end
      assert.same({filetype = "fennel", ["module-name"] = "conjure.client.fennel.aniseed"}, client["with-filetype"]("fennel", _16_))
      return nil
    end
    return it("returns the fennel module when we're in a fennel file", _15_)
  end
  return describe("with-filetype", _14_)
end
describe("current-client-module-name", _13_)
local function _17_()
  local function _18_()
    local function _19_()
      return client.current()
    end
    assert.same(require("conjure.client.fennel.aniseed"), client["with-filetype"]("fennel", _19_))
    return nil
  end
  return it("returns the fennel module when we're in a fennel file", _18_)
end
describe("current", _17_)
local function _20_()
  local function _21_()
    local function _22_()
      return client.get("buf-suffix")
    end
    assert.same(require("conjure.client.fennel.aniseed")["buf-suffix"], client["with-filetype"]("fennel", _22_))
    return nil
  end
  return it("looks up a value from the current client", _21_)
end
describe("get", _20_)
local function _23_()
  local function _24_()
    local function _25_()
      return client.call("->list", "foo")
    end
    assert.same({"foo"}, client["with-filetype"]("sql", _25_))
    return nil
  end
  return it("executes a function from a client", _24_)
end
describe("call", _23_)
local function _26_()
  local function _27_()
    local function _28_()
      return client.call("->list", "foo")
    end
    assert.same({"foo"}, client["with-filetype"]("sql", _28_))
    return nil
  end
  it("executes a function from a client", _27_)
  local function _29_()
    local function _30_()
      return client["optional-call"]("does-not-exist", "foo")
    end
    assert.same(nil, client["with-filetype"]("sql", _30_))
    return nil
  end
  return it("skips it if the function does not exist", _29_)
end
describe("optional-call", _26_)
local function _31_()
  local function _32_()
    local suffixes = {}
    local function _33_()
      return table.insert(suffixes, client.get("buf-suffix"))
    end
    client["each-loaded-client"](_33_)
    assert.same({".sql", ".fnl"}, suffixes)
    return nil
  end
  return it("runs a function for each loaded client", _32_)
end
return describe("each-loaded-client", _31_)
