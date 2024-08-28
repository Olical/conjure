-- [nfnl] Compiled from fnl/conjure-spec/remote/transport/base64_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local b64 = require("conjure.remote.transport.base64")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.are.equals("", b64.encode(""))
    end
    it("empty to empty", _4_)
    local function _5_()
      return assert.are.equals("SGVsbG8sIFdvcmxkIQ==", b64.encode("Hello, World!"))
    end
    it("simple text to base64", _5_)
    local function _6_()
      return assert.are.equals("Hello, World!", b64.decode("SGVsbG8sIFdvcmxkIQ=="))
    end
    return it("base64 back to text", _6_)
  end
  return describe("basic", _3_)
end
return describe("conjure.remote.transport.base64", _2_)
