local _2afile_2a = "fnl/conjure/client/common-lisp/output.fnl"
local _2amodule_name_2a = "conjure.client.common-lisp.parser"
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
local a, log, str, text, trn = autoload("conjure.aniseed.core"), autoload("conjure.log"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.remote.transport.slynk")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["trn"] = trn
local function display_stdout(msg)
  if ((nil ~= msg) and ("" ~= msg)) then
    return log.append(text["prefixed-lines"](msg, "; "))
  else
    return nil
  end
end
_2amodule_2a["display-stdout"] = display_stdout
local function escape_string(_in)
  local function replace(_in0, pat, rep)
    local s, c = string.gsub(_in0, pat, rep)
    return s
  end
  return replace(replace(_in, "\\", "\\\\"), "\"", "\\\"")
end
_2amodule_2a["escape-string"] = escape_string
local function wrap_message(msg)
  if not a["nil?"](msg) then
    return str.join({"\"", escape_string(msg), "\""})
  else
    return nil
  end
end
_2amodule_2a["wrap-message"] = wrap_message
local function wrap_message_or_nil(msg)
  if a["nil?"](msg) then
    return "nil"
  else
    return wrap_message(msg)
  end
end
_2amodule_2a["wrap-message-or-nil"] = wrap_message_or_nil
local function get_return_value(table)
  local _let_4_ = table
  local _let_5_ = _let_4_[1]
  local res = _let_5_[1]
  local _let_6_ = _let_5_[2]
  local stdout = _let_6_[1]
  local valu = _let_6_[2]
  local eval_id = _let_4_[2]
  return stdout, valu
end
_2amodule_locals_2a["get-return-value"] = get_return_value
local function display_error(rest)
  local _let_7_ = rest
  local eval_id = _let_7_[1]
  local b = _let_7_[2]
  local err = _let_7_[3]
  local rest0 = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_7_, 4)
  return display_stdout(str.join("\n", err))
end
_2amodule_locals_2a["display-error"] = display_error
local function parse_result(received)
  local _let_8_ = unpack(trn["parse-string-to-nested-list"](received))
  local _return = _let_8_[1]
  local rest = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_8_, 2)
  local _9_ = _return
  if (_9_ == ":return") then
    return get_return_value(rest)
  elseif (_9_ == ":debug") then
    return display_error(rest)
  elseif true then
    local _ = _9_
    return display_stdout(("Unsure how to parse " .. _return))
  else
    return nil
  end
end
_2amodule_2a["parse-result"] = parse_result
return _2amodule_2a