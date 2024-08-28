-- [nfnl] Compiled from fnl/conjure-spec/remote/transport/bencode_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local a = require("nfnl.core")
local bencode = require("conjure.remote.transport.bencode")
local function _2_()
  local function _3_()
    local bs = bencode.new()
    local data = {foo = {"bar"}}
    local function _4_()
      return assert.are.equals(bs.data, "")
    end
    it("data starts empty", _4_)
    local function _5_()
      return assert.same({data}, bencode["decode-all"](bs, bencode.encode(data)))
    end
    it("a single bencoded value", _5_)
    local function _6_()
      return assert.are.equals(bs.data, "")
    end
    return it("data is empty after a decode", _6_)
  end
  describe("basic", _3_)
  local function _7_()
    local bs = bencode.new()
    local data_a = {foo = {"bar"}}
    local data_b = {1, 2, 3}
    local function _8_()
      return assert.are.equals(bs.data, "")
    end
    it("data starts empty", _8_)
    local function _9_()
      return assert.same({data_a, data_b}, bencode["decode-all"](bs, (bencode.encode(data_a) .. bencode.encode(data_b))))
    end
    it("two bencoded values", _9_)
    local function _10_()
      return assert.are.equals(bs.data, "")
    end
    return it("data is empty after a decode", _10_)
  end
  describe("multiple-values", _7_)
  local function _11_()
    local bs = bencode.new()
    local data_a = {foo = {"bar"}}
    local data_b = {1, 2, 3}
    local encoded_b = bencode.encode(data_b)
    local function _12_()
      return assert.are.equals(bs.data, "")
    end
    it("data starts empty", _12_)
    local function _13_()
      return assert.same({data_a}, bencode["decode-all"](bs, (bencode.encode(data_a) .. string.sub(encoded_b, 1, 3))))
    end
    it("first value", _13_)
    local function _14_()
      return assert.are.equals("li1", bs.data)
    end
    it("after first, data contains partial data-b", _14_)
    local function _15_()
      return assert.same({data_b}, bencode["decode-all"](bs, string.sub(encoded_b, 4)))
    end
    it("second value after rest of data", _15_)
    local function _16_()
      return assert.are.equals(bs.data, "")
    end
    return it("data is empty after a decode", _16_)
  end
  return describe("partial-values", _11_)
end
return describe("conjure.remote.transport.bencode", _2_)
