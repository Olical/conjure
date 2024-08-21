-- [nfnl] Compiled from fnl/conjure/tree-sitter.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("nfnl.core")
local nvim = autoload("conjure.aniseed.nvim")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local ts
do
  local ok_3f, x = nil, nil
  local function _2_()
    return require("nvim-treesitter.ts_utils")
  end
  ok_3f, x = pcall(_2_)
  if ok_3f then
    ts = x
  else
    ts = nil
  end
end
local function enabled_3f()
  local and_4_ = ("table" == type(ts)) and config["get-in"]({"extract", "tree_sitter", "enabled"})
  if and_4_ then
    local ok_3f, parser = pcall(vim.treesitter.get_parser)
    and_4_ = (ok_3f and parser)
  end
  if and_4_ then
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
      return vim.treesitter.get_node_text(node, nvim.get_current_buf())
    else
      return vim.treesitter.query.get_node_text(node, nvim.get_current_buf())
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
    return {range = range(node), content = node__3estr(node)}
  else
    return nil
  end
end
local function get_root(node)
  parse_21()
  local node0 = (node or ts.get_node_at_cursor())
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
    return (string.find(node:type(), "sym") or client["optional-call"]("symbol-node?", node))
  else
    return nil
  end
end
local function get_leaf(node)
  parse_21()
  local node0 = (node or ts.get_node_at_cursor())
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
      return (text["starts-with"](node_str, start) and text["ends-with"](node_str, _end))
    end
    or_19_ = a.some(_21_, extra_pairs)
  end
  return (or_19_ or false)
end
local function node_prefixed_by_chars_3f(node, prefixes)
  local node_str = node__3estr(node)
  local function _22_(prefix)
    return text["starts-with"](node_str, prefix)
  end
  return (a.some(_22_, prefixes) or false)
end
local function get_form(node)
  if not node then
    parse_21()
  else
  end
  local node0 = (node or ts.get_node_at_cursor())
  if document_3f(node0) then
    return nil
  elseif (leaf_3f(node0) or (false == client["optional-call"]("form-node?", node0))) then
    return get_form(parent(node0))
  else
    local _let_24_ = (client["optional-call"]("get-form-modifier", node0) or {})
    local modifier = _let_24_["modifier"]
    local res = _let_24_
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
return {["enabled?"] = enabled_3f, ["parse!"] = parse_21, ["node->str"] = node__3estr, ["lisp-comment-node?"] = lisp_comment_node_3f, parent = parent, ["document?"] = document_3f, range = range, ["node->table"] = node__3etable, ["get-root"] = get_root, ["leaf?"] = leaf_3f, ["sym?"] = sym_3f, ["get-leaf"] = get_leaf, ["node-surrounded-by-form-pair-chars?"] = node_surrounded_by_form_pair_chars_3f, ["node-prefixed-by-chars?"] = node_prefixed_by_chars_3f, ["get-form"] = get_form}
