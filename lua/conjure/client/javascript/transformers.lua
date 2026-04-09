-- [nfnl] fnl/conjure/client/javascript/transformers.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_.define
local autoload = _local_1_.autoload
local eval = autoload("conjure.eval")
local tsc = autoload("conjure.client.javascript.ts-common")
local ir = autoload("conjure.client.javascript.import-replacer")
local log = autoload("conjure.log")
local a = autoload("conjure.nfnl.core")
local M = define("conjure.client.javascript.transformers")
local node_handlers = {}
local err_type__3estr = {err = "ERROR", warn = "WARNING"}
local function table_3f(e)
  return ("table" == type(e))
end
local function handle_transform_error(err)
  local opts = (eval["previous-evaluations"]["conjure.client.javascript.stdio"] or {})
  local range = opts.range
  local _let_2_ = (range or {})
  local start = _let_2_.start
  local _let_3_ = (start or {})
  local line = _let_3_[1]
  local col = _let_3_[2]
  local err0
  if table_3f(err) then
    err0 = err
  else
    err0 = {}
  end
  local eline = err0.ln
  local ecol = err0.col
  local einfo = err0.info
  local tp = err0.type
  local tp0 = (err_type__3estr[tp] or "ERROR")
  local final_line = ((line or 0) + (eline or 0))
  local final_col
  if ecol then
    final_col = (1 + ecol)
  else
    final_col = col
  end
  local info = (einfo or "no info")
  local pref = ("[" .. tp0 .. "]")
  return log.append({("/* " .. pref .. " transforming node " .. "at line " .. final_line .. " column " .. final_col .. ". Info: " .. info .. " */")})
end
local function transform(node, code)
  local node_type = node:type()
  local handler = (node_handlers[node_type] or node_handlers.default)
  local _ok, result
  local function _6_()
    return handler(node, code)
  end
  _ok, result = xpcall(_6_, handle_transform_error)
  return result
end
local function subs_newline(code, start, prev_end)
  local subs = string.sub(code, (prev_end + 1), start)
  local subs0 = string.gsub(subs, "%s*[\r\n]+%s*", " ")
  local subs1, _ = subs0
  return subs1
end
local function _7_(node, code)
  if (node:child_count() == 0) then
    return tsc["get-text"](node, code)
  else
    local pieces = {}
    local prev_end
    local _8_
    do
      local _, _0, b = node:start()
      _8_ = b
    end
    prev_end = {val = _8_}
    for child in node:iter_children() do
      local _, _0, start = child:start()
      local _1, _2, _end = child:end_()
      table.insert(pieces, subs_newline(code, start, prev_end.val))
      table.insert(pieces, transform(child, code))
      prev_end.val = _end
    end
    local _9_
    do
      local _, _0, _end = node:end_()
      _9_ = _end
    end
    table.insert(pieces, subs_newline(code, _9_, prev_end.val))
    return table.concat(pieces, "")
  end
end
node_handlers.default = _7_
local function _11_(_, _0)
  return ""
end
node_handlers.comment = _11_
local function forbidden_kw_3f(n, code)
  local t = n:type()
  local txt = tsc["get-text"](n, code)
  return ((t == "this") or (t == "super") or (t == "meta_property") or ((t == "identifier") and (txt == "arguments")) or (txt == "new.target"))
end
local function body_contains_forbidden_keyword_3f(node, code)
  local stack = {node}
  local found = nil
  while (not found and next(stack)) do
    local n = table.remove(stack)
    if forbidden_kw_3f(n, code) then
      found = n
    else
      for c in n:iter_children() do
        table.insert(stack, c)
      end
    end
  end
  return found
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
local function transform_arrow_fn(arrow_fn, name, code)
  local body_node = tsc["get-child"](arrow_fn, "body")
  local forbidden = body_contains_forbidden_keyword_3f(body_node, code)
  if forbidden then
    local ln, col = forbidden:start()
    handle_transform_error({type = "warn", info = ("Cannot transform arrow function, it contains '" .. forbidden:type() .. "'"), ln = ln, col = col})
    return nil
  else
    local params = tsc["get-text"](tsc["get-child"](arrow_fn, "parameters"), code)
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
      local case_15_ = body_node:type()
      if (case_15_ == "statement_block") then
        final_body = (" " .. body_text)
      elseif (case_15_ == "parenthesized_expression") then
        final_body = (" { return " .. body_text .. " }")
      else
        local _ = case_15_
        final_body = (" { return " .. body_text .. " }")
      end
    end
    return (async_kw .. "function " .. name .. params .. final_body .. ";")
  end
end
local function _18_(node, code)
  local var_decl = node:child(1)
  local value_node = (var_decl and (var_decl:type() == "variable_declarator") and tsc["get-child"](var_decl, "value"))
  if (value_node and ("arrow_function" == value_node:type())) then
    local name = tsc["get-text"](tsc["get-child"](var_decl, "name"), code)
    return (transform_arrow_fn(value_node, name, code) or handle_statement(node, code))
  else
    return handle_statement(node, code)
  end
end
node_handlers.lexical_declaration = _18_
local function _20_(node, code)
  local obj = node:field("object")[1]
  if (obj and ((obj:type() == "call_expression") or (obj:type() == "member_expression"))) then
    local default_text = node_handlers.default(node, code)
    local flattened = string.gsub(default_text, "%s*\n%s*", "")
    return flattened
  else
    return node_handlers.default(node, code)
  end
end
node_handlers.member_expression = _20_
node_handlers.import_statement = ir["import-statement"](handle_statement)
node_handlers.call_expression = ir["call-expression"](node_handlers.default)
local function _22_(node, code)
  local child = node:child(1)
  local case_23_ = child:type()
  if ((case_23_ == "interface_declaration") or (case_23_ == "class_declaration")) then
    return node_handlers.default(node, code)
  elseif (case_23_ == "export_clause") then
    return ""
  else
    local _ = case_23_
    return node_handlers.default(child, code)
  end
end
node_handlers.export_statement = _22_
for _, t in pairs({"type_alias_declaration", "expression_statement", "variable_declaration", "return_statement", "throw_statement", "break_statement", "continue_statement", "debugger_statement", "class_declaration", "field_definition", "public_field_definition", "function_declaration"}) do
  node_handlers[t] = handle_statement
end
M.transform = function(s)
  local tree = tsc["get-tree"](s)
  local root = tree:root()
  local transformed = transform(root, s)
  return vim.fn.trim(transformed)
end
return M
