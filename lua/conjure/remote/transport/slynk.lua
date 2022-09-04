local _2afile_2a = "fnl/conjure/remote/transport/slynk.fnl"
local _2amodule_name_2a = "conjure.remote.transport.slynk"
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
local a, log = autoload("conjure.aniseed.core"), autoload("conjure.log")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["log"] = log
local function encode(msg)
  local n = a.count(msg)
  local header = string.format("%06x", (1 + n))
  return (header .. msg .. "\n")
end
_2amodule_2a["encode"] = encode
local function decode(msg)
  local len = tonumber(string.sub(msg, 1, 7), 16)
  local cmd = string.sub(msg, 7, len)
  return cmd
end
_2amodule_2a["decode"] = decode
local function string_stream(str)
  local index = 1
  local function _1_()
    local r = str:byte(index)
    index = (index + 1)
    return r
  end
  return _1_
end
_2amodule_locals_2a["string-stream"] = string_stream
local function parse_string_to_nested_list(string_to_parse)
  local return_val = {}
  local stack = {return_val}
  local word = {}
  local opened_quote = false
  local escaped = false
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
  local function process_whitespace(b)
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
  do
    local slash_byte = string.byte("\\")
    local quote_byte = string.byte("\"")
    local paren_open = string.byte("(")
    local paren_close = string.byte(")")
    local space_byte = string.byte(" ")
    local tab_byte = string.byte("\9")
    local newline_byte = string.byte("\n")
    for b in string_stream(string_to_parse) do
      local _10_ = b
      if (_10_ == slash_byte) then
        slash_escape(b)
      elseif (_10_ == quote_byte) then
        open_close_quote(b)
      elseif (_10_ == paren_open) then
        open_paren(b)
      elseif (_10_ == paren_close) then
        close_paren(b)
      elseif (_10_ == space_byte) then
        process_whitespace(b)
      elseif (_10_ == tab_byte) then
        process_whitespace(b)
      elseif (_10_ == newline_byte) then
        process_whitespace(b)
      elseif true then
        local _ = _10_
        add_to_word(b)
      else
      end
    end
  end
  finish_word()
  return return_val
end
_2amodule_2a["parse-string-to-nested-list"] = parse_string_to_nested_list
return _2amodule_2a