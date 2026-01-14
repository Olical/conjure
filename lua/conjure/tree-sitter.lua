-- [nfnl] fnl/conjure/tree-sitter.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local a = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local function enabled_3f()
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
local function parse_21()
  local ok_3f, parser = pcall(vim.treesitter.get_parser)
  if ok_3f then
    return parser:parse()
  else
    return nil
  end
end
local function node__3estr(node)
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
local function lisp_comment_node_3f(node)
  return text["starts-with"](node__3estr(node), "(comment")
end
local function parent(node)
  if node then
    return node:parent()
  else
    return nil
  end
end
local function document_3f(node)
  return not parent(node)
end
local function range(node)
  if node then
    local sr, sc, er, ec = node:range()
    return {start = {a.inc(sr), sc}, ["end"] = {a.inc(er), a.dec(ec)}}
  else
    return nil
  end
end
local function node__3etable(node)
  if (a.get(node, "range") and a.get(node, "content")) then
    return node
  elseif node then
    return {range = range(node), content = node__3estr(node), node = node}
  else
    return nil
  end
end
local function get_root(node)
  parse_21()
  local node0 = (node or vim.treesitter.get_node())
  local parent_node = parent(node0)
  if document_3f(node0) then
    return nil
  elseif document_3f(parent_node) then
    return node0
  elseif client["optional-call"]("comment-node?", parent_node) then
    return node0
  else
    return get_root(parent_node)
  end
end
local function leaf_3f(node)
  if node then
    return (0 == node:child_count())
  else
    return nil
  end
end
local function sym_3f(node)
  if node then
    return (string.find(node:type(), "sym") or (node:type() == "package_lit") or client["optional-call"]("symbol-node?", node))
  else
    return nil
  end
end
local function get_leaf(node)
  parse_21()
  local node0 = (node or vim.treesitter.get_node())
  if (leaf_3f(node0) or sym_3f(node0)) then
    local node1 = node0
    while sym_3f(parent(node1)) do
      node1 = parent(node1)
    end
    return node1
  else
    return nil
  end
end
local function node_surrounded_by_form_pair_chars_3f(node, extra_pairs)
  local node_str = node__3estr(node)
  local first_and_last_chars = text["first-and-last-chars"](node_str)
  local function _16_(_15_)
    local start = _15_[1]
    local _end = _15_[2]
    return (first_and_last_chars == (start .. _end))
  end
  local or_17_ = a.some(_16_, config["get-in"]({"extract", "form_pairs"}))
  if not or_17_ then
    local function _19_(_18_)
      local start = _18_[1]
      local _end = _18_[2]
      return (vim.startswith(node_str, start) and vim.endswith(node_str, _end))
    end
    or_17_ = a.some(_19_, extra_pairs)
  end
  return (or_17_ or false)
end
local function node_prefixed_by_chars_3f(node, prefixes)
  local node_str = node__3estr(node)
  local function _20_(prefix)
    return vim.startswith(node_str, prefix)
  end
  return (a.some(_20_, prefixes) or false)
end
local function get_form(node)
  if not node then
    parse_21()
  else
  end
  local node0 = (node or vim.treesitter.get_node())
  if document_3f(node0) then
    return nil
  elseif (leaf_3f(node0) or (false == client["optional-call"]("form-node?", node0))) then
    return get_form(parent(node0))
  else
    local _let_22_ = (client["optional-call"]("get-form-modifier", node0) or {})
    local modifier = _let_22_.modifier
    local res = _let_22_
    if (not modifier or ("none" == modifier)) then
      return node0
    elseif ("parent" == modifier) then
      return get_form(parent(node0))
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
local function add_language(lang)
  local add
  do
    local case_25_ = vim.treesitter
    if ((_G.type(case_25_) == "table") and ((_G.type(case_25_.language) == "table") and (nil ~= case_25_.language.add))) then
      local f = case_25_.language.add
      add = f
    elseif ((_G.type(case_25_) == "table") and ((_G.type(case_25_.language) == "table") and (nil ~= case_25_.language.require_language))) then
      local f = case_25_.language.require_language
      local function _26_(...)
        return pcall(f, ...)
      end
      add = _26_
    elseif ((_G.type(case_25_) == "table") and (nil ~= case_25_.require_language)) then
      local f = case_25_.require_language
      local function _27_(...)
        return pcall(f, ...)
      end
      add = _27_
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
local function valid_str_3f(lang, code)
  local root_node = get_root_node_for_str(lang, code)
  return (root_node and not root_node:has_error())
end
return {["enabled?"] = enabled_3f, ["parse!"] = parse_21, ["node->str"] = node__3estr, ["lisp-comment-node?"] = lisp_comment_node_3f, parent = parent, ["document?"] = document_3f, range = range, ["node->table"] = node__3etable, ["get-root"] = get_root, ["leaf?"] = leaf_3f, ["sym?"] = sym_3f, ["get-leaf"] = get_leaf, ["node-surrounded-by-form-pair-chars?"] = node_surrounded_by_form_pair_chars_3f, ["node-prefixed-by-chars?"] = node_prefixed_by_chars_3f, ["get-form"] = get_form, ["add-language"] = add_language, ["valid-str?"] = valid_str_3f}
