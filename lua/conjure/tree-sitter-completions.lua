-- [nfnl] fnl/conjure/tree-sitter-completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local a = autoload("conjure.nfnl.core")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local util = autoload("conjure.util")
local res = autoload("conjure.resources")
local M = define("conjure.tree-sitter-completions")
local symbol_query_path_template = "queries/%s/cmpl.scm"
local query_cache = {}
local function build_completion_query(ts_lang, cmpl_resource)
  local query_path = string.format(symbol_query_path_template, cmpl_resource)
  local query_text = res["get-resource-contents"](query_path)
  if query_text then
    return vim.treesitter.query.parse(ts_lang, query_text)
  else
    return nil
  end
end
local function get_cached_completion_query(cmpl_resource)
  local cached_query = query_cache[cmpl_resource]
  if cached_query then
    return cached_query
  else
    return nil
  end
end
local function get_completion_query(ts_lang, cmpl_resource)
  local cached_query = get_cached_completion_query(cmpl_resource)
  if cached_query then
    return cached_query
  else
    local query = build_completion_query(ts_lang, cmpl_resource)
    query_cache[cmpl_resource] = query
    return query
  end
end
local function contains_node(nodes, n)
  if (nil == n) then
    return false
  else
    local function _5_(_241)
      return n:equal(_241)
    end
    return a.some(_5_, nodes)
  end
end
local function get_scope_parent(node, scopes)
  if ((nil == node) or (nil == node:parent())) then
    return nil
  elseif contains_node(scopes, node:parent()) then
    return node:parent()
  else
    return get_scope_parent(node:parent(), scopes)
  end
end
local function get_nth_scope_parent(n, node, scopes)
  if (n == 0) then
    return node
  else
    return get_nth_scope_parent((n - 1), get_scope_parent(node, scopes), scopes)
  end
end
local function get_node_scopes(node, scopes, matched_scopes)
  local acc = (matched_scopes or {})
  local next_scope = get_scope_parent(node, scopes)
  if contains_node(scopes, node) then
    table.insert(acc, node)
  else
  end
  if (nil == next_scope) then
    return acc
  else
    return get_node_scopes(next_scope, scopes, acc)
  end
end
local function extract_scopes(query, captures)
  local results = {}
  for id, n in captures do
    local captured_label = query.captures[id]
    if ("local.scope" == captured_label) then
      table.insert(results, n)
    else
    end
  end
  return results
end
local function is_in_scope(target, scope)
  return ((nil == scope) or scope:equal(target) or vim.treesitter.is_ancestor(scope, target))
end
local function get_node_text(node, buffer, meta)
  local base_text = vim.treesitter.get_node_text(node, buffer)
  local prefix = meta.prefix
  if prefix then
    return (prefix .. base_text)
  else
    return base_text
  end
end
local function get_completions_for_query(query)
  local buffer = vim.api.nvim_get_current_buf()
  local cursor_node = vim.treesitter.get_node()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local scope_captures = query:iter_captures(cursor_node:root(), buffer, 0, row)
  local scopes = extract_scopes(query, scope_captures)
  local captures = query:iter_captures(cursor_node:root(), buffer, 0, row)
  local results = {}
  for id, n, meta in captures do
    local captured_label = query.captures[id]
    if ("global.define" == captured_label) then
      table.insert(results, get_node_text(n, buffer, meta))
    elseif (("local.bind" == captured_label) and not cursor_node:equal(n:parent()) and is_in_scope(cursor_node, get_nth_scope_parent(1, n, scopes))) then
      table.insert(results, get_node_text(n, buffer, meta))
    elseif (("local.define" == captured_label) and not cursor_node:equal(n:parent()) and is_in_scope(cursor_node, get_nth_scope_parent(2, n, scopes))) then
      table.insert(results, get_node_text(n, buffer, meta))
    else
    end
  end
  return util["ordered-distinct"](results)
end
M["get-completions-at-cursor"] = function(ts_lang, cmpl_resource)
  local query = get_completion_query(ts_lang, cmpl_resource)
  if query then
    return get_completions_for_query(query)
  else
    return {}
  end
end
M["make-prefix-filter"] = function(prefix)
  local sanitized_prefix = string.gsub((prefix or ""), "%%", "%%%%")
  local prefix_pattern = ("^" .. sanitized_prefix)
  local prefix_filter
  local function _15_(s)
    return string.match(s, prefix_pattern)
  end
  prefix_filter = _15_
  local function _16_(list)
    return a.filter(prefix_filter, list)
  end
  return _16_
end
return M
