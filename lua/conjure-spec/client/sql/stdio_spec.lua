-- [nfnl] Compiled from fnl/conjure-spec/client/sql/stdio_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local sql = require("conjure.client.sql.stdio")
local function _2_()
  local function _3_()
    local function _4_()
      local function _5_()
        return "meta"
      end
      assert.same("foo\n", sql["prep-code"]({code = "foo -- bar", node = {type = _5_}}))
      local function _6_()
        return "meta"
      end
      assert.same("foo -- bar\nsomething\n", sql["prep-code"]({code = "foo -- bar\nsomething -- quuz", node = {type = _6_}}))
      local function _7_()
        return "meta"
      end
      assert.same("foo -- bar\nsomething -- quux\n\n", sql["prep-code"]({code = "foo -- bar\nsomething -- quux\n", node = {type = _7_}}))
      local function _8_()
        return "statement"
      end
      assert.same("foo;\n", sql["prep-code"]({code = "foo -- bar", node = {type = _8_}}))
      return nil
    end
    return it("prepares sql code appropriately", _4_)
  end
  return describe("prep-code", _3_)
end
return describe("conjure.client.sql.stdio", _2_)
