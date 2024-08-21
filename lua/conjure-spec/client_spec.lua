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
return describe("multiple-states? after a change", _8_)
