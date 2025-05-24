-- [nfnl] fnl/conjure/remote/transport/bencode/init.fnl
local buffer = require("string.buffer")
local ffi = require("ffi")
local core = require("conjure.nfnl.core")
local function new()
  return {buf = buffer.new(), stack = {}}
end
local _5ci = string.byte("i")
local _5ce = string.byte("e")
local _5cl = string.byte("l")
local _5cd = string.byte("d")
local _5c0 = string.byte("0")
local _5c9 = string.byte("9")
local _5c_ = string.byte(":")
local function decode_all(state, chunk)
  if (chunk and (#chunk > 0)) then
    state.buf:put(chunk)
  else
  end
  local offset = 0
  local vals = {}
  local ptr, blen = state.buf:ref()
  local function check(n)
    if (n <= blen) then
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
    local _5_
    if _3finclusive then
      _5_ = 0
    else
      _5_ = 1
    end
    start = (offset + _5_)
    local pos = start
    while (check((pos + 1)) and (ptr[pos] ~= (_3fterm or _5ce))) do
      pos = (pos + 1)
    end
    if (ptr[pos] == (_3fterm or _5ce)) then
      local num = tonumber(ffi.string((ptr + start), (pos - start)))
      offset = (pos + 1)
      return num
    else
      return nil
    end
  end
  local function parse_string()
    local original_offset = offset
    local len = parse_number(_5c_, true)
    if len then
      local str_end = check((offset + len))
      if str_end then
        local str = ffi.string((ptr + offset), len)
        offset = str_end
        return str
      else
        offset = original_offset
        return nil
      end
    else
      return nil
    end
  end
  local BEGIN = {}
  local function parse_collection(t)
    offset = (offset + 1)
    return {BEGIN, t}
  end
  local function parse_terminator()
    assert((#state.stack > 0), "bencode: unexpected terminator")
    offset = (offset + 1)
    local frame = table.remove(state.stack)
    assert(((frame.t ~= "dict") or (frame.k == nil)), "bencode: dict ended with pending key")
    return frame.v
  end
  local function parse()
    local c = (check((offset + 1)) and ptr[offset])
    if c then
      if (c == _5ci) then
        return parse_number()
      else
        local and_10_ = (c == c)
        if and_10_ then
          and_10_ = ((c >= _5c0) and (c <= _5c9))
        end
        if and_10_ then
          return parse_string()
        elseif (c == _5cl) then
          return parse_collection("list")
        elseif (c == _5cd) then
          return parse_collection("dict")
        elseif (c == _5ce) then
          return parse_terminator()
        else
          local _ = c
          return error(string.format("bencode: bad byte 0x%02x", c))
        end
      end
    else
      return nil
    end
  end
  for val in parse do
    if (val == nil) then break end
    if ((_G.type(val) == "table") and (val[1] == BEGIN) and (nil ~= val[2])) then
      local t = val[2]
      table.insert(state.stack, {t = t, k = nil, v = {}})
    else
      local _ = val
      push(val)
    end
  end
  if (offset > 0) then
    state.buf:skip(offset)
  else
  end
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
local function encode(x)
  local _16_ = type(x)
  if (_16_ == "string") then
    return (#x .. ":" .. x)
  elseif (_16_ == "number") then
    assert(((x % 1) == 0), ("bencode: non\226\128\145integer number " .. x))
    return wrap("i", "e", x)
  elseif (_16_ == "table") then
    if is_list_3f(x) then
      return wrap("l", "e", table.concat(core.map(encode, core.vals(x))))
    else
      table.sort(x)
      local function _18_(_17_)
        local k = _17_[1]
        local v = _17_[2]
        assert((type(k) == "string"), "bencode: dict key not string")
        return (encode(k) .. encode(v))
      end
      return wrap("d", "e", table.concat(core["map-indexed"](_18_, x)))
    end
  else
    local _ = _16_
    return error(("bencode: unsupported type " .. type(x)))
  end
end
return {new = new, ["decode-all"] = decode_all, encode = encode}
