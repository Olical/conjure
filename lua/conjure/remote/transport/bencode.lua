-- [nfnl] fnl/conjure/remote/transport/bencode.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_.define
local buffer = require("string.buffer")
local ffi = require("ffi")
local core = require("conjure.nfnl.core")
local M = define("conjure.remote.transport.bencode")
M.new = function()
  return {buf = buffer.new(), stack = {}}
end
local _5ci = string.byte("i")
local _5ce = string.byte("e")
local _5cl = string.byte("l")
local _5cd = string.byte("d")
local _5c0 = string.byte("0")
local _5c9 = string.byte("9")
local _5c_ = string.byte(":")
M["decode-all"] = function(state, chunk)
  if chunk then
    state.buf:put(chunk)
  else
  end
  local vals = {}
  local ptr, blen = state.buf:ref()
  local offset = -1
  local function check(n)
    if (n < blen) then
      return n
    else
      return nil
    end
  end
  local function push(val)
    local frame = core.last(state.stack)
    if frame then
      if ((_G.type(frame) == "table") and (frame.t == "list")) then
        return table.insert(frame.v, val)
      elseif ((_G.type(frame) == "table") and (frame.t == "dict") and (frame.k == nil)) then
        assert((type(val) == "string"), "bencode: dict key not string")
        frame.k = val
        return nil
      elseif ((_G.type(frame) == "table") and (frame.t == "dict") and (nil ~= frame.k)) then
        local k = frame.k
        frame["k"] = nil
        frame["v"][k] = val
        return frame
      else
        return nil
      end
    else
      return table.insert(vals, val)
    end
  end
  local function parse_number(_3fterm, _3finclusive)
    local start
    local _6_
    if _3finclusive then
      _6_ = 0
    else
      _6_ = 1
    end
    start = (offset + _6_)
    local pos = start
    while (check((pos + 1)) and (ptr[pos] ~= (_3fterm or _5ce))) do
      pos = (pos + 1)
    end
    if (ptr[pos] == (_3fterm or _5ce)) then
      local str = ffi.string((ptr + start), (pos - start))
      local num = tonumber(str)
      offset = pos
      return num
    else
      return nil
    end
  end
  local function parse_string()
    local len = parse_number(_5c_, true)
    if len then
      local str_end = check((offset + len))
      if str_end then
        local str = ffi.string((ptr + offset + 1), len)
        offset = str_end
        return str
      else
        return nil
      end
    else
      return nil
    end
  end
  local BEGIN = {}
  local function parse_collection(t)
    return {BEGIN, t}
  end
  local function parse_terminator()
    assert((#state.stack > 0), "bencode: unexpected terminator")
    local frame = table.remove(state.stack)
    assert(((frame.t ~= "dict") or (frame.k == nil)), "bencode: dict ended with pending key")
    return frame.v
  end
  local function parse()
    if check((offset + 1)) then
      local original_offset = offset
      local c = ptr[(offset + 1)]
      offset = (offset + 1)
      local _11_
      if (c == _5ci) then
        _11_ = parse_number()
      else
        local and_13_ = (c == c)
        if and_13_ then
          and_13_ = ((c >= _5c0) and (c <= _5c9))
        end
        if and_13_ then
          _11_ = parse_string()
        elseif (c == _5cl) then
          _11_ = parse_collection("list")
        elseif (c == _5cd) then
          _11_ = parse_collection("dict")
        elseif (c == _5ce) then
          _11_ = parse_terminator()
        else
          local _ = c
          _11_ = error(string.format("bencode: bad char 0x%02x", c))
        end
      end
      local or_21_ = _11_
      if not or_21_ then
        offset = original_offset
        or_21_ = nil
      end
      return or_21_
    else
      return nil
    end
  end
  for val in parse do
    if ((_G.type(val) == "table") and (val[1] == BEGIN) and (nil ~= val[2])) then
      local t = val[2]
      table.insert(state.stack, {t = t, k = nil, v = {}})
    else
      local _ = val
      push(val)
    end
  end
  state.buf:skip((offset + 1))
  return vals
end
local function is_list_3f(x)
  local keys = core.keys(x)
  local valid_3f = true
  for i = 1, #keys do
    if not valid_3f then break end
    valid_3f = (valid_3f and (keys[i] == i))
  end
  return valid_3f
end
local function wrap(prefix, suffix, x)
  return (prefix .. x .. suffix)
end
M.encode = function(x)
  local case_24_ = type(x)
  if (case_24_ == "string") then
    return (#x .. ":" .. x)
  elseif (case_24_ == "number") then
    assert(((x % 1) == 0), ("bencode: non-integer number " .. x))
    return wrap("i", "e", x)
  elseif (case_24_ == "table") then
    if is_list_3f(x) then
      return wrap("l", "e", table.concat(core.map(M.encode, core.vals(x))))
    else
      local ks = core.keys(x)
      for _, k in ipairs(ks) do
        assert((type(k) == "string"), "bencode: dict key not string")
      end
      table.sort(ks)
      local function _25_(k)
        return (M.encode(k) .. M.encode(x[k]))
      end
      return wrap("d", "e", table.concat(core.map(_25_, ks)))
    end
  else
    local _ = case_24_
    return error(("bencode: unsupported type " .. type(x)))
  end
end
return M
