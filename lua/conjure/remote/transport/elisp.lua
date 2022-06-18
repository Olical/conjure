local _2afile_2a = "fnl/conjure/remote/transport/elisp.fnl"
local _2amodule_name_2a = "conjure.remote.transport.elisp"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, stack, str, text = autoload("conjure.aniseed.core"), autoload("conjure.stack"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["stack"] = stack
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local function err(...)
  return error(str.join({_2amodule_name_2a, ": ", ...}))
end
_2amodule_locals_2a["err"] = err
local function read_2a(cs, ctxs, result)
  if a["empty?"](cs) then
    return result
  else
    local prev_cs = cs
    local c = a.first(cs)
    local cs0 = a.rest(cs)
    local ctx = stack.peek(ctxs)
    if ("escaped-string" == ctx) then
      return read_2a(cs0, stack.pop(ctxs), (result .. c))
    elseif ("string" == ctx) then
      if ("\"" == c) then
        return read_2a(cs0, stack.pop(ctxs), result)
      elseif ("\\" == c) then
        return read_2a(cs0, stack.push(ctxs, "escaped-string"), result)
      else
        return read_2a(cs0, ctxs, (result .. c))
      end
    elseif ("symbol" == ctx) then
      if string.find(c, "[a-zA-Z0-9_-]") then
        return read_2a(cs0, ctxs, (result .. c))
      else
        return read_2a(prev_cs, stack.pop(ctxs), result)
      end
    elseif a["nil?"](ctx) then
      if ("\"" == c) then
        return read_2a(cs0, stack.push(ctxs, "string"), "")
      elseif (":" == c) then
        return read_2a(cs0, stack.push(ctxs, "symbol"), "")
      elseif string.find(c, "%s") then
        return read_2a(cs0, ctxs, result)
      else
        return err("Unknown character: ", c)
      end
    else
      return err("Unknown `ctx`: ", ctx)
    end
  end
end
_2amodule_locals_2a["read*"] = read_2a
local function read(s)
  return read_2a(text.chars(s), {}, nil)
end
_2amodule_2a["read"] = read
return _2amodule_2a