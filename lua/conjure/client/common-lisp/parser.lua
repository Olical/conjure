local _2afile_2a = "fnl/conjure/client/common-lisp/parser.fnl"
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
local a, log, str, text = autoload("conjure.aniseed.core"), autoload("conjure.log"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local function display_stdout(msg)
  if ((nil ~= msg) and ("" ~= msg)) then
    return log.append(text["prefixed-lines"](msg, "; "))
  else
    return nil
  end
end
_2amodule_locals_2a["display-stdout"] = display_stdout
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
local function string_stream(str0)
  local index = 1
  local function _4_()
    local r = str0:byte(index)
    index = (index + 1)
    return r
  end
  return _4_
end
_2amodule_locals_2a["string-stream"] = string_stream
local function parse_string_to_nested_list(string_to_parse)
  local return_val = {}
  local stack = {return_val}
  local word = {}
  local opened_quote = false
  local escaped = false
  local slash_byte = string.byte("\\")
  local quote_byte = string.byte("\"")
  local paren_open = string.byte("(")
  local paren_close = string.byte(")")
  local space_byte = string.byte(" ")
  local tab_byte = string.byte("\9")
  local newline_byte = string.byte("\n")
  local function get_stack()
    return stack[#stack]
  end
  local function add_to_word(b)
    table.insert(word, b)
    escaped = false
    return nil
  end
  local function slash_escape(b)
    if escaped then
      return add_to_word(b)
    else
      escaped = true
      return nil
    end
  end
  local function insert_word_and_clear()
    opened_quote = false
    table.insert(get_stack(), string.char(unpack(word)))
    word = {}
    return nil
  end
  local function finish_word()
    if not a["empty?"](word) then
      return insert_word_and_clear()
    else
      return nil
    end
  end
  local function maybe_finish_word(b)
    if opened_quote then
      return add_to_word(b)
    else
      return finish_word()
    end
  end
  local function open_close_quote(b)
    if escaped then
      return add_to_word(b)
    else
      if opened_quote then
        return insert_word_and_clear()
      else
        opened_quote = true
        return nil
      end
    end
  end
  local function open_paren(b)
    if opened_quote then
      return add_to_word(b)
    else
      local new_table = {}
      table.insert(get_stack(), new_table)
      return table.insert(stack, new_table)
    end
  end
  local function close_paren(b)
    if opened_quote then
      return add_to_word(b)
    else
      if (#stack > 1) then
        finish_word()
        return table.remove(stack)
      else
        return nil
      end
    end
  end
  for b in string_stream(string_to_parse) do
    local _13_ = b
    if (_13_ == slash_byte) then
      slash_escape(b)
    elseif (_13_ == quote_byte) then
      open_close_quote(b)
    elseif (_13_ == paren_open) then
      open_paren(b)
    elseif (_13_ == paren_close) then
      close_paren(b)
    elseif (_13_ == space_byte) then
      maybe_finish_word(b)
    elseif (_13_ == tab_byte) then
      maybe_finish_word(b)
    elseif (_13_ == newline_byte) then
      maybe_finish_word(b)
    elseif true then
      local _ = _13_
      add_to_word(b)
    else
    end
  end
  finish_word()
  return return_val
end
_2amodule_2a["parse-string-to-nested-list"] = parse_string_to_nested_list
local function get_return_value(table)
  local _let_15_ = table
  local _let_16_ = _let_15_[1]
  local res = _let_16_[1]
  local _let_17_ = _let_16_[2]
  local stdout = _let_17_[1]
  local valu = _let_17_[2]
  local eval_id = _let_15_[2]
  return stdout, valu
end
_2amodule_locals_2a["get-return-value"] = get_return_value
local function display_error(rest)
  local _let_18_ = rest
  local eval_id = _let_18_[1]
  local b = _let_18_[2]
  local err = _let_18_[3]
  local rest0 = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_18_, 4)
  return display_stdout(str.join("\n", err))
end
_2amodule_locals_2a["display-error"] = display_error
local function parse_result(received)
  local _let_19_ = unpack(parse_string_to_nested_list(received))
  local _return = _let_19_[1]
  local rest = (function (t, k) local mt = getmetatable(t) if "table" == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) else return {(table.unpack or unpack)(t, k)} end end)(_let_19_, 2)
  local _20_ = _return
  if (_20_ == ":return") then
    return get_return_value(rest)
  elseif (_20_ == ":debug") then
    return display_error(rest)
  elseif true then
    local _ = _20_
    return display_stdout(("Unsure how to parse " .. _return))
  else
    return nil
  end
end
_2amodule_2a["parse-result"] = parse_result
return _2amodule_2a