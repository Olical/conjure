-- [nfnl] Compiled from fnl/conjure-spec/bridge_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local bridge = require("conjure.bridge")
local assert = require("luassert.assert")
local function _2_()
  local function _3_()
    local result = bridge["viml->lua"]("my.module", "my_function", nil)
    return assert.equal(result, "lua require('my.module')['my_function']()")
  end
  it("converts a module and function to a Lua require call without arguments", _3_)
  local function _4_()
    local result = bridge["viml->lua"]("my.module", "my_function", {args = "arg1, arg2"})
    return assert.equal(result, "lua require('my.module')['my_function'](arg1, arg2)")
  end
  return it("converts a module and function to a Lua require call with arguments", _4_)
end
return describe("viml->lua", _2_)
