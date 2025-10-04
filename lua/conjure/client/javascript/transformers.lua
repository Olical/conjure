-- [nfnl] fnl/conjure/client/javascript/transformers.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_["define"]
local autoload = _local_1_["autoload"]
local tsc = autoload("conjure.client.javascript.ts-common")
local ir = autoload("conjure.client.javascript.import-replacer")
local M = define("conjure.client.javascript.transformers")
local node_handlers = {}
local function transform(node, code)
  local node_type = node:type()
  local handler = (node_handlers[node_type] or node_handlers.default)
  local _ok, result = nil, nil
  local function _2_()
    return handler(node, code)
  end
  local function _3_(err)
    return ("/* [ERROR] transforming node " .. node_type .. ": " .. err .. " */")
  end
  _ok, result = xpcall(_2_, _3_)
  return result
end
local function _4_(node, code)
  if (node:child_count() == 0) then
    return tsc["get-text"](node, code)
  else
    local pieces = {}
    local prev_end
    do
      local _, _0, b = node:start()
      prev_end = b
    end
    for child in node:iter_children() do
      local _, _0, start = child:start()
      local _1, _2, stop = child:end_()
      table.insert(pieces, string.sub(code, (prev_end + 1), start))
      table.insert(pieces, transform(child, code))
      prev_end = stop
    end
    local function _5_()
      local _, _0, _end = node:end_()
      return _end
    end
    table.insert(pieces, string.sub(code, (prev_end + 1), _5_()))
    return table.concat(pieces, "")
  end
end
node_handlers.default = _4_
local function _7_(_, _0)
  return ""
end
node_handlers.comment = _7_
local function transform_arrow_fn(arrow_fn, name, code)
  local params = tsc["get-text"](tsc["get-child"](arrow_fn, "parameters"), code)
  local body_node = tsc["get-child"](arrow_fn, "body")
  local body_text = transform(body_node, code)
  local first_child = arrow_fn:child(0)
  local async_3f = (first_child and (first_child:type() == "async"))
  local async_kw
  if async_3f then
    async_kw = "async "
  else
    async_kw = ""
  end
  local final_body
  do
    local _9_ = body_node:type()
    if (_9_ == "statement_block") then
      final_body = (" " .. body_text)
    elseif (_9_ == "parenthesized_expression") then
      final_body = (" { return " .. body_text .. " }")
    else
      local _ = _9_
      final_body = (" { return " .. body_text .. " }")
    end
  end
  return (async_kw .. "function " .. name .. params .. final_body)
end
local function handle_statement(node, code)
  local text = node_handlers.default(node, code)
  local trimmed = vim.fn.trim(text)
  local last_char = string.sub(trimmed, -1)
  if ((last_char == ";") or (last_char == ":")) then
    return text
  else
    return (text .. ";")
  end
end
local function _12_(node, code)
  local var_decl = node:child(1)
  local value_node = (var_decl and (var_decl:type() == "variable_declarator") and tsc["get-child"](var_decl, "value"))
  if (value_node and ("arrow_function" == value_node:type())) then
    local name = tsc["get-text"](tsc["get-child"](var_decl, "name"), code)
    return transform_arrow_fn(value_node, name, code)
  else
    return handle_statement(node, code)
  end
end
node_handlers.lexical_declaration = _12_
local function _14_(node, code)
  local obj = node:field("object")[1]
  if (obj and ((obj:type() == "call_expression") or (obj:type() == "member_expression"))) then
    local default_text = node_handlers.default(node, code)
    local flattened = string.gsub(default_text, "%s*\n%s*", "")
    return flattened
  else
    return node_handlers.default(node, code)
  end
end
node_handlers.member_expression = _14_
node_handlers.import_statement = ir["import-statement"](handle_statement)
node_handlers.call_expression = ir["call-expression"](node_handlers.default)
local function _16_(node, code)
  local child = node:child(1)
  local _17_ = child:type()
  if ((_17_ == "interface_declaration") or (_17_ == "class_declaration")) then
    return node_handlers.default(node, code)
  elseif (_17_ == "export_clause") then
    return ""
  else
    local _ = _17_
    return node_handlers.default(child, code)
  end
end
node_handlers.export_statement = _16_
for _, t in pairs({"expression_statement", "variable_declaration", "return_statement", "throw_statement", "break_statement", "continue_statement", "debugger_statement", "class_declaration", "field_definition", "public_field_definition", "function_declaration"}) do
  node_handlers[t] = handle_statement
end
M.transform = function(s)
  local tree = tsc["get-tree"](s)
  local root = tree:root()
  local transformed = transform(root, s)
  return string.gsub(transformed, "%s*\n%s*", " ")
end
return M
