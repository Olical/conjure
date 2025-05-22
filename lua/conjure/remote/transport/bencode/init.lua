-- [nfnl] fnl/conjure/remote/transport/bencode/init.fnl
local buffer = require("string.buffer")
local ffi = require("ffi")
local function new()
  return {buf = buffer.new(), stack = {}}
end
local function decode_all(state, chunk)
  if (chunk and (#chunk > 0)) then
    state.buf:put(chunk)
  else
  end
  local i = 0
  local acc = {}
  local ptr, blen = state.buf:ref()
  local function need(n)
    return ((i + n) <= blen)
  end
  local function push(v)
    local depth = #state.stack
    if (depth == 0) then
      return table.insert(acc, v)
    else
      local frame = state.stack[depth]
      if (frame.t == "list") then
        return table.insert(frame.v, v)
      else
        if (frame.k == nil) then
          if not (type(v) == "string") then
            error("dict key must be string")
          else
          end
          frame.k = v
          return nil
        else
          frame.v[frame.k] = v
          frame.k = nil
          return nil
        end
      end
    end
  end
  local function parse()
    if not need(1) then
      return nil, true
    else
      local c = ptr[i]
      if (c == string.byte("i")) then
        i = (i + 1)
        local start = i
        while true do
          if not need(1) then
            return nil, true
          else
          end
          if (ptr[i] == string.byte("e")) then
            local num = tonumber(ffi.string((ptr + start), (i - start)))
            i = (i + 1)
            return num
          else
            i = (i + 1)
          end
        end
        return nil
      elseif ((c >= string.byte("0")) and (c <= string.byte("9"))) then
        local start = i
        while true do
          i = (i + 1)
          if not need(1) then
            return nil, true
          else
          end
          if (ptr[i] == string.byte(":")) then
            break
          else
          end
        end
        local len = tonumber(ffi.string((ptr + start), (i - start)))
        i = (i + 1)
        if not need(len) then
          return nil, true
        else
        end
        local s = ffi.string((ptr + i), len)
        i = (i + len)
        return s
      elseif ((c == string.byte("l")) or (c == string.byte("d"))) then
        i = (i + 1)
        local _11_
        if (c == string.byte("l")) then
          _11_ = "list"
        else
          _11_ = "dict"
        end
        return table.insert(state.stack, {t = _11_, v = {}, k = nil})
      elseif (c == string.byte("e")) then
        if (#state.stack == 0) then
          error("unexpected 'e'")
        else
        end
        i = (i + 1)
        local frame = table.remove(state.stack)
        if ((frame.t == "dict") and not (frame.k == nil)) then
          error("dictionary ended while waiting for value")
        else
        end
        return frame.v
      else
        return error(string.format("bad bencode byte 0x%02x", c))
      end
    end
  end
  while true do
    local start = i
    local val, incomplete = parse()
    if incomplete then
      i = start
      break
    else
    end
    if val then
      push(val)
    else
    end
  end
  if (i > 0) then
    state.buf:skip(i)
  else
  end
  return acc
end
local function is_list_3f(x)
  local n = #x
  for k, _ in pairs(x) do
    if not ((type(k) == "number") and ((k % 1) == 0) and ((1 <= k) and (k <= n))) then
      return false
    else
    end
  end
  for i = 1, n do
    if (x[i] == nil) then
      return false
    else
    end
  end
  return true
end
local function encode(x)
  local _22_ = type(x)
  if (_22_ == "string") then
    return (#x .. ":" .. x)
  elseif (_22_ == "number") then
    if ((x % 1) == 0) then
      return ("i" .. x .. "e")
    else
      return error(("bencode: non\226\128\145integer number " .. x))
    end
  elseif (_22_ == "table") then
    if is_list_3f(x) then
      local function _24_()
        local tbl_21_ = {}
        local i_22_ = 0
        for _, v in ipairs(x) do
          local val_23_ = encode(v)
          if (nil ~= val_23_) then
            i_22_ = (i_22_ + 1)
            tbl_21_[i_22_] = val_23_
          else
          end
        end
        return tbl_21_
      end
      return ("l" .. table.concat(_24_()) .. "e")
    else
      local keys = {}
      for k, _ in pairs(x) do
        assert((type(k) == "string"), "bencode: dict key not string")
        table.insert(keys, k)
      end
      table.sort(keys)
      local function _26_()
        local tbl_21_ = {}
        local i_22_ = 0
        for _, k in ipairs(keys) do
          local val_23_ = (encode(k) .. encode(x[k]))
          if (nil ~= val_23_) then
            i_22_ = (i_22_ + 1)
            tbl_21_[i_22_] = val_23_
          else
          end
        end
        return tbl_21_
      end
      return ("d" .. table.concat(_26_()) .. "e")
    end
  else
    local _ = _22_
    return error(("bencode: unsupported type " .. type(x)))
  end
end
return {new = new, ["decode-all"] = decode_all, encode = encode}
