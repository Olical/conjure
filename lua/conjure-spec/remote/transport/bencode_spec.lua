-- [nfnl] fnl/conjure-spec/remote/transport/bencode_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local ffi = require("ffi")
local bencode = require("conjure.remote.transport.bencode")
local function buffer_content(bs)
  local ptr, blen = bs.buf:ref()
  return ffi.string(ptr, blen)
end
local function assert_buffer(bs, expected)
  return assert.are.equals(expected, buffer_content(bs))
end
local function assert_stack_depth(bs, expected)
  return assert.are.equals(expected, #bs.stack)
end
local function assert_stack_empty(bs)
  return assert_stack_depth(bs, 0)
end
local function _2_()
  local function _3_()
    local bs = bencode.new()
    local data = {foo = {"bar"}}
    local function _4_()
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("buffer starts empty", _4_)
    local function _5_()
      return assert.same({data}, bencode["decode-all"](bs, bencode.encode(data)))
    end
    it("a single bencoded value", _5_)
    local function _6_()
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    return it("buffer is empty after a decode", _6_)
  end
  describe("basic functionality", _3_)
  local function _7_()
    local function _8_()
      return assert.are.equals("d11:client-name7:conjure2:id3:abc2:op5:clonee", bencode.encode({op = "clone", id = "abc", ["client-name"] = "conjure"}))
    end
    it("encodes dict keys in sorted order", _8_)
    local function _9_()
      return assert.are.equals("d1:ai1e1:bi2e1:cd1:xi0e1:yi0e1:zi0ee1:di4e1:ei5e1:fi6e1:gi7e1:hi8ee", bencode.encode({h = 8, g = 7, f = 6, e = 5, d = 4, c = {z = 0, y = 0, x = 0}, b = 2, a = 1}))
    end
    return it("sorts nested dicts and many keys", _9_)
  end
  describe("dict key ordering", _7_)
  local function _10_()
    local bs = bencode.new()
    local data_a = {foo = {"bar"}}
    local data_b = {1, 2, 3}
    local function _11_()
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("buffer starts empty", _11_)
    local function _12_()
      return assert.same({data_a, data_b}, bencode["decode-all"](bs, (bencode.encode(data_a) .. bencode.encode(data_b))))
    end
    it("two bencoded values", _12_)
    local function _13_()
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    return it("buffer is empty after a decode", _13_)
  end
  describe("multiple-values", _10_)
  local function _14_()
    local bs = bencode.new()
    local data_a = {foo = {"bar"}}
    local data_b = {1, 2, 3}
    local encoded_b = bencode.encode(data_b)
    local function _15_()
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("buffer starts empty", _15_)
    local function _16_()
      return assert.same({data_a}, bencode["decode-all"](bs, (bencode.encode(data_a) .. string.sub(encoded_b, 1, 3))))
    end
    it("first value with partial list start", _16_)
    local function _17_()
      assert_buffer(bs, "i1")
      assert_stack_depth(bs, 1)
      return assert.are.equals("list", bs.stack[1].t)
    end
    it("after first, buffer contains partial integer and list is on stack", _17_)
    local function _18_()
      return assert.same({data_b}, bencode["decode-all"](bs, string.sub(encoded_b, 4)))
    end
    it("second value completes the list", _18_)
    local function _19_()
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    return it("buffer is empty after completion", _19_)
  end
  describe("partial list parsing", _14_)
  local function _20_()
    local function _21_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "i"))
      assert_buffer(bs, "i")
      return assert_stack_empty(bs)
    end
    it("incomplete integer at start", _21_)
    local function _22_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "i123"))
      assert_buffer(bs, "i123")
      return assert_stack_empty(bs)
    end
    it("incomplete integer with partial number", _22_)
    local function _23_()
      local bs = bencode.new()
      bencode["decode-all"](bs, "i123")
      assert.same({123}, bencode["decode-all"](bs, "e"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("complete integer after partial", _23_)
    local function _24_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "i-"))
      assert_buffer(bs, "i-")
      assert.same({-42}, bencode["decode-all"](bs, "42e"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    return it("negative integer split", _24_)
  end
  describe("integer edge cases", _20_)
  local function _25_()
    local function _26_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "3"))
      assert_buffer(bs, "3")
      return assert_stack_empty(bs)
    end
    it("incomplete string length", _26_)
    local function _27_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "3:"))
      assert_buffer(bs, "3:")
      return assert_stack_empty(bs)
    end
    it("incomplete string with colon but no content", _27_)
    local function _28_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "3:fo"))
      assert_buffer(bs, "3:fo")
      return assert_stack_empty(bs)
    end
    it("incomplete string with partial content", _28_)
    local function _29_()
      local bs = bencode.new()
      bencode["decode-all"](bs, "3:fo")
      assert.same({"foo"}, bencode["decode-all"](bs, "o"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("complete string after partial", _29_)
    local function _30_()
      local bs = bencode.new()
      assert.same({""}, bencode["decode-all"](bs, "0:"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("zero-length string", _30_)
    local function _31_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "1"))
      assert.same({}, bencode["decode-all"](bs, "0"))
      assert.same({}, bencode["decode-all"](bs, ":"))
      assert.same({}, bencode["decode-all"](bs, "hello"))
      assert.same({"helloworld"}, bencode["decode-all"](bs, "world"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    return it("multi-digit length split across chunks", _31_)
  end
  describe("string edge cases", _25_)
  local function _32_()
    local function _33_()
      local bs = bencode.new()
      assert.same({{}}, bencode["decode-all"](bs, "le"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("empty list", _33_)
    local function _34_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "l"))
      assert_buffer(bs, "")
      assert_stack_depth(bs, 1)
      return assert.are.equals("list", bs.stack[1].t)
    end
    it("list start only", _34_)
    local function _35_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "ll"))
      assert_buffer(bs, "")
      assert_stack_depth(bs, 2)
      assert.are.equals("list", bs.stack[1].t)
      return assert.are.equals("list", bs.stack[2].t)
    end
    it("nested list start", _35_)
    local function _36_()
      local bs = bencode.new()
      bencode["decode-all"](bs, "ll")
      assert.same({{{}}}, bencode["decode-all"](bs, "ee"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("complete nested empty lists", _36_)
    local function _37_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "li42"))
      assert_buffer(bs, "i42")
      assert_stack_depth(bs, 1)
      bencode["decode-all"](bs, "e3:fo")
      assert_buffer(bs, "3:fo")
      assert.same({{42, "foo"}}, bencode["decode-all"](bs, "oe"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    return it("list with mixed incomplete elements", _37_)
  end
  describe("list edge cases", _32_)
  local function _38_()
    local function _39_()
      local bs = bencode.new()
      assert.same({{}}, bencode["decode-all"](bs, "de"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("empty dict", _39_)
    local function _40_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "d"))
      assert_buffer(bs, "")
      assert_stack_depth(bs, 1)
      return assert.are.equals("dict", bs.stack[1].t)
    end
    it("dict start only", _40_)
    local function _41_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "d3:fo"))
      assert_buffer(bs, "3:fo")
      return assert_stack_depth(bs, 1)
    end
    it("dict with incomplete key", _41_)
    local function _42_()
      local bs = bencode.new()
      bencode["decode-all"](bs, "d3:fo")
      assert.same({}, bencode["decode-all"](bs, "o"))
      assert_buffer(bs, "")
      assert_stack_depth(bs, 1)
      return assert.are.equals("foo", bs.stack[1].k)
    end
    it("dict with complete key but no value", _42_)
    local function _43_()
      local bs = bencode.new()
      bencode["decode-all"](bs, "d3:foo")
      assert.same({}, bencode["decode-all"](bs, "i4"))
      assert_buffer(bs, "i4")
      assert_stack_depth(bs, 1)
      return assert.are.equals("foo", bs.stack[1].k)
    end
    it("dict with incomplete value", _43_)
    local function _44_()
      local bs = bencode.new()
      bencode["decode-all"](bs, "d3:fooi4")
      assert.same({{foo = 42}}, bencode["decode-all"](bs, "2ee"))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("complete dict after partial parsing", _44_)
    local function _45_()
      local bs = bencode.new()
      assert.same({}, bencode["decode-all"](bs, "ld"))
      assert_stack_depth(bs, 2)
      assert.are.equals("list", bs.stack[1].t)
      return assert.are.equals("dict", bs.stack[2].t)
    end
    it("nested dict in list", _45_)
    local function _46_()
      local bs = bencode.new()
      bencode["decode-all"](bs, "d3:fool")
      assert_stack_depth(bs, 2)
      assert.are.equals("dict", bs.stack[1].t)
      assert.are.equals("list", bs.stack[2].t)
      return assert.are.equals("foo", bs.stack[1].k)
    end
    return it("list in dict value", _46_)
  end
  describe("dict edge cases", _38_)
  local function _47_()
    local function _48_()
      local bs = bencode.new()
      local encoded = bencode.encode({key = "value"})
      local final_result = {}
      for i = 1, #encoded do
        local result = bencode["decode-all"](bs, string.sub(encoded, i, i))
        for _, v in ipairs(result) do
          table.insert(final_result, v)
        end
      end
      assert.same({{key = "value"}}, final_result)
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("single character chunks", _48_)
    local function _49_()
      local bs = bencode.new()
      assert.same({123}, bencode["decode-all"](bs, "i123e3:"))
      assert.same({"foo"}, bencode["decode-all"](bs, "foo"))
      assert.same({}, bencode["decode-all"](bs, ""))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("exact boundary splits", _49_)
    local function _50_()
      local bs = bencode.new()
      local data = {numbers = {1, 2, 3}, nested = {inner = "value"}}
      local encoded = bencode.encode(data)
      local mid = math.floor((#encoded / 2))
      assert.same({}, bencode["decode-all"](bs, string.sub(encoded, 1, mid)))
      assert.same({data}, bencode["decode-all"](bs, string.sub(encoded, (mid + 1))))
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    it("large nested structure split", _50_)
    local function _51_()
      local bs = bencode.new()
      local item = {id = "item", data = "some-long-data-string-that-takes-space", nums = {1, 2, 3, 4, 5}}
      local list = {}
      for _ = 1, 50 do
        table.insert(list, item)
      end
      local encoded = bencode.encode(list)
      local chunk_size = 32
      local final_result = {}
      for start = 1, #encoded, chunk_size do
        local _end = math.min((start + chunk_size + -1), #encoded)
        local chunk = string.sub(encoded, start, _end)
        local result = bencode["decode-all"](bs, chunk)
        for _, v in ipairs(result) do
          table.insert(final_result, v)
        end
      end
      assert.same({list}, final_result)
      assert_buffer(bs, "")
      return assert_stack_empty(bs)
    end
    return it("very large data structure in 32-char chunks", _51_)
  end
  return describe("boundary conditions", _47_)
end
return describe("conjure.remote.transport.bencode", _2_)
