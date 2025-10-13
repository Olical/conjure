-- [nfnl] fnl/conjure/remote/transport/elisp.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local stack = autoload("conjure.stack")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local M = define("conjure.remote.transport.elisp")
local function err(...)
  return error(str.join({"conjure.remote.transport.elisp: ", ...}))
end
local symbol_char_pat = "[a-zA-Z0-9_-]"
local number_char_pat = "[0-9.-]"
local whitespace_char_pat = "%s"
local function read_2a(cs, ctxs, result)
  if core["empty?"](cs) then
    return result
  else
    local prev_cs = cs
    local c = core.first(cs)
    local cs0 = core.rest(cs)
    local _let_2_ = (stack.peek(ctxs) or {})
    local ctx_name = _let_2_["name"]
    local ctx_value = _let_2_["value"]
    if (("list" == ctx_name) and (nil ~= result)) then
      table.insert(ctx_value, result)
      return read_2a(prev_cs, ctxs, nil)
    elseif ("escaped-string" == ctx_name) then
      return read_2a(cs0, stack.pop(ctxs), (result .. c))
    elseif ("string" == ctx_name) then
      if ("\"" == c) then
        return read_2a(cs0, stack.pop(ctxs), result)
      elseif ("\\" == c) then
        return read_2a(cs0, stack.push(ctxs, {name = "escaped-string"}), result)
      else
        return read_2a(cs0, ctxs, (result .. c))
      end
    elseif ("symbol" == ctx_name) then
      if string.find(c, symbol_char_pat) then
        return read_2a(cs0, ctxs, (result .. c))
      else
        return read_2a(prev_cs, stack.pop(ctxs), result)
      end
    elseif ("number" == ctx_name) then
      if string.find(c, number_char_pat) then
        local function _5_()
          local result0 = (result .. c)
          if core["empty?"](cs0) then
            return tonumber(result0)
          else
            return result0
          end
        end
        return read_2a(cs0, ctxs, _5_())
      else
        return read_2a(prev_cs, stack.pop(ctxs), tonumber(result))
      end
    elseif (("list" == ctx_name) or core["nil?"](ctx_name)) then
      if ("\"" == c) then
        return read_2a(cs0, stack.push(ctxs, {name = "string"}), "")
      elseif (":" == c) then
        return read_2a(cs0, stack.push(ctxs, {name = "symbol"}), "")
      elseif ("(" == c) then
        return read_2a(cs0, stack.push(ctxs, {name = "list", value = {}}), nil)
      elseif (")" == c) then
        return read_2a(cs0, stack.pop(ctxs), ctx_value)
      elseif string.find(c, whitespace_char_pat) then
        return read_2a(cs0, ctxs, result)
      elseif string.find(c, number_char_pat) then
        return read_2a(prev_cs, stack.push(ctxs, {name = "number"}), "")
      else
        return err("Unknown character: ", c)
      end
    else
      return err("Unknown `ctx`: ", ctx_name)
    end
  end
end
M.read = function(s)
  return read_2a(text.chars(s), {}, nil)
end
return M
