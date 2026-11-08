-- [nfnl] fnl/conjure/tree-sitter.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local a = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local M = define("conjure.tree-sitter")
M["enabled?"] = function()
  local and_2_ = config["get-in"]({"extract", "tree_sitter", "enabled"})
  if and_2_ then
    local ok_3f, parser = pcall(vim.treesitter.get_parser)
    and_2_ = (ok_3f and parser)
  end
  if and_2_ then
    return true
  else
    return false
  end
end
M["parse!"] = function()
  local ok_3f, parser = pcall(vim.treesitter.get_parser)
  if (ok_3f and (nil ~= parser)) then
    return parser:parse()
  else
    return nil
  end
end
M["node->str"] = function(node)
  if node then
    if vim.treesitter.get_node_text then
      return vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
    else
      return vim.treesitter.query.get_node_text(node, vim.api.nvim_get_current_buf())
    end
  else
    return nil
  end
end
M["lisp-comment-node?"] = function(node)
  return text["starts-with"](M["node->str"](node), "(comment")
end
M.parent = function(node)
  if node then
    return node:parent()
  else
    return nil
  end
end
M["document?"] = function(node)
  return not M.parent(node)
end
M.range = function(node)
  if node then
    local sr, sc, er, ec = node:range()
    return {start = {a.inc(sr), sc}, ["end"] = {a.inc(er), a.dec(ec)}}
  else
    return nil
  end
end
M["node->table"] = function(node)
  if (a.get(node, "range") and a.get(node, "content")) then
    return node
  elseif node then
    return {range = M.range(node), content = M["node->str"](node), node = node}
  else
    return nil
  end
end
M["get-node-at-cursor"] = function()
  local node = vim.treesitter.get_node()
  if (node and M["document?"](node)) then
    local _let_11_ = vim.api.nvim_win_get_cursor(0)
    local row = _let_11_[1]
    local col = _let_11_[2]
    local row0 = a.dec(row)
    return node:named_descendant_for_range(row0, col, row0, a.inc(col))
  else
    return node
  end
end
M["get-root"] = function(node)
  M["parse!"]()
  local node0 = (node or M["get-node-at-cursor"]())
  local parent_node = M.parent(node0)
  if M["document?"](node0) then
    return nil
  elseif M["document?"](parent_node) then
    return node0
  elseif client["optional-call"]("comment-node?", parent_node) then
    return node0
  else
    return M["get-root"](parent_node)
  end
end
M["leaf?"] = function(node)
  if node then
    return (0 == node:child_count())
  else
    return nil
  end
end
M["sym?"] = function(node)
  if node then
    return (string.find(node:type(), "sym") or (node:type() == "package_lit") or vim.tbl_contains({"field_expression", "scoped_identifier"}, node:type()) or client["optional-call"]("symbol-node?", node))
  else
    return nil
  end
end
M["get-leaf"] = function(node)
  M["parse!"]()
  local node0 = (node or M["get-node-at-cursor"]())
  if (M["leaf?"](node0) or M["sym?"](node0)) then
    local node1 = node0
    while M["sym?"](M.parent(node1)) do
      node1 = M.parent(node1)
    end
    return node1
  else
    return nil
  end
end
M["node-surrounded-by-form-pair-chars?"] = function(node, extra_pairs)
  local node_str = M["node->str"](node)
  local first_and_last_chars = text["first-and-last-chars"](node_str)
  local function _18_(_17_)
    local start = _17_[1]
    local _end = _17_[2]
    return (first_and_last_chars == (start .. _end))
  end
  local or_19_ = a.some(_18_, config["get-in"]({"extract", "form_pairs"}))
  if not or_19_ then
    local function _21_(_20_)
      local start = _20_[1]
      local _end = _20_[2]
      return (vim.startswith(node_str, start) and vim.endswith(node_str, _end))
    end
    or_19_ = a.some(_21_, extra_pairs)
  end
  return (or_19_ or false)
end
M["node-prefixed-by-chars?"] = function(node, prefixes)
  local node_str = M["node->str"](node)
  local function _22_(prefix)
    return vim.startswith(node_str, prefix)
  end
  return (a.some(_22_, prefixes) or false)
end
M["get-form"] = function(node)
  if not node then
    M["parse!"]()
  else
  end
  local node0 = (node or M["get-node-at-cursor"]())
  if M["document?"](node0) then
    return nil
  elseif (M["leaf?"](node0) or (false == client["optional-call"]("form-node?", node0))) then
    return M["get-form"](M.parent(node0))
  else
    local _let_24_ = (client["optional-call"]("get-form-modifier", node0) or {})
    local modifier = _let_24_.modifier
    local res = _let_24_
    if (not modifier or ("none" == modifier)) then
      return node0
    elseif ("parent" == modifier) then
      return M["get-form"](M.parent(node0))
    elseif ("node" == modifier) then
      return res.node
    elseif ("raw" == modifier) then
      return res["node-table"]
    else
      a.println("Warning: Conjure client returned an unknown get-form-modifier", res)
      return node0
    end
  end
end
M["add-language"] = function(lang)
  local add
  do
    local case_27_ = vim.treesitter
    if ((_G.type(case_27_) == "table") and ((_G.type(case_27_.language) == "table") and (nil ~= case_27_.language.add))) then
      local f = case_27_.language.add
      add = f
    elseif ((_G.type(case_27_) == "table") and ((_G.type(case_27_.language) == "table") and (nil ~= case_27_.language.require_language))) then
      local f = case_27_.language.require_language
      local function _28_(...)
        return pcall(f, ...)
      end
      add = _28_
    elseif ((_G.type(case_27_) == "table") and (nil ~= case_27_.require_language)) then
      local f = case_27_.require_language
      local function _29_(...)
        return pcall(f, ...)
      end
      add = _29_
    else
      add = nil
    end
  end
  return add(lang)
end
local function get_root_node_for_str(lang, code)
  local parser = vim.treesitter.get_string_parser(code, lang)
  parser:parse()
  local trees = parser:trees()
  if (trees and (#trees > 0)) then
    local root_tree = trees[1]
    return root_tree:root()
  else
    return nil
  end
end
M["valid-str?"] = function(lang, code)
  if M["enabled?"]() then
    local root_node = get_root_node_for_str(lang, code)
    return (root_node and not root_node:has_error())
  else
    return true
  end
end
return M
