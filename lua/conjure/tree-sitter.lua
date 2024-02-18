-- [nfnl] Compiled from fnl/conjure/tree-sitter.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.tree-sitter"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, client, config, nvim, str, text = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local document_3f = (_2amodule_2a)["document?"]
local enabled_3f = (_2amodule_2a)["enabled?"]
local get_form = (_2amodule_2a)["get-form"]
local get_leaf = (_2amodule_2a)["get-leaf"]
local get_root = (_2amodule_2a)["get-root"]
local leaf_3f = (_2amodule_2a)["leaf?"]
local lisp_comment_node_3f = (_2amodule_2a)["lisp-comment-node?"]
local node__3estr = (_2amodule_2a)["node->str"]
local node__3etable = (_2amodule_2a)["node->table"]
local node_prefixed_by_chars_3f = (_2amodule_2a)["node-prefixed-by-chars?"]
local node_surrounded_by_form_pair_chars_3f = (_2amodule_2a)["node-surrounded-by-form-pair-chars?"]
local parent = (_2amodule_2a).parent
local parse_21 = (_2amodule_2a)["parse!"]
local range = (_2amodule_2a).range
local sym_3f = (_2amodule_2a)["sym?"]
local a0 = (_2amodule_locals_2a).a
local client0 = (_2amodule_locals_2a).client
local config0 = (_2amodule_locals_2a).config
local nvim0 = (_2amodule_locals_2a).nvim
local str0 = (_2amodule_locals_2a).str
local text0 = (_2amodule_locals_2a).text
local ts = (_2amodule_locals_2a).ts
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local ts0
do
  local ok_3f, x = nil, nil
  local function _1_()
    return require("nvim-treesitter.ts_utils")
  end
  ok_3f, x = pcall(_1_)
  if ok_3f then
    ts0 = x
  else
    ts0 = nil
  end
end
_2amodule_locals_2a["ts"] = ts0
do local _ = {nil, nil} end
local function enabled_3f0()
  local function _3_()
    local ok_3f, parser = pcall(vim.treesitter.get_parser)
    return (ok_3f and parser)
  end
  if (("table" == type(ts0)) and config0["get-in"]({"extract", "tree_sitter", "enabled"}) and _3_()) then
    return true
  else
    return false
  end
end
_2amodule_2a["enabled?"] = enabled_3f0
do local _ = {enabled_3f0, nil} end
local function parse_210()
  local ok_3f, parser = pcall(vim.treesitter.get_parser)
  if ok_3f then
    return parser:parse()
  else
    return nil
  end
end
_2amodule_2a["parse!"] = parse_210
do local _ = {parse_210, nil} end
local function node__3estr0(node)
  if node then
    if vim.treesitter.get_node_text then
      return vim.treesitter.get_node_text(node, nvim0.get_current_buf())
    else
      return vim.treesitter.query.get_node_text(node, nvim0.get_current_buf())
    end
  else
    return nil
  end
end
_2amodule_2a["node->str"] = node__3estr0
do local _ = {node__3estr0, nil} end
local function lisp_comment_node_3f0(node)
  return text0["starts-with"](node__3estr0(node), "(comment")
end
_2amodule_2a["lisp-comment-node?"] = lisp_comment_node_3f0
do local _ = {lisp_comment_node_3f0, nil} end
local function parent0(node)
  if node then
    return node:parent()
  else
    return nil
  end
end
_2amodule_2a["parent"] = parent0
do local _ = {parent0, nil} end
local function document_3f0(node)
  return not parent0(node)
end
_2amodule_2a["document?"] = document_3f0
do local _ = {document_3f0, nil} end
local function range0(node)
  if node then
    local sr, sc, er, ec = node:range()
    return {start = {a0.inc(sr), sc}, ["end"] = {a0.inc(er), a0.dec(ec)}}
  else
    return nil
  end
end
_2amodule_2a["range"] = range0
do local _ = {range0, nil} end
local function node__3etable0(node)
  if (a0.get(node, "range") and a0.get(node, "content")) then
    return node
  elseif node then
    return {range = range0(node), content = node__3estr0(node)}
  else
    return nil
  end
end
_2amodule_2a["node->table"] = node__3etable0
do local _ = {node__3etable0, nil} end
local function get_root0(node)
  parse_210()
  local node0 = (node or ts0.get_node_at_cursor())
  local parent_node = parent0(node0)
  if document_3f0(node0) then
    return nil
  elseif document_3f0(parent_node) then
    return node0
  elseif client0["optional-call"]("comment-node?", parent_node) then
    return node0
  else
    return get_root0(parent_node)
  end
end
_2amodule_2a["get-root"] = get_root0
do local _ = {get_root0, nil} end
local function leaf_3f0(node)
  if node then
    return (0 == node:child_count())
  else
    return nil
  end
end
_2amodule_2a["leaf?"] = leaf_3f0
do local _ = {leaf_3f0, nil} end
local function sym_3f0(node)
  if node then
    return (string.find(node:type(), "sym") or client0["optional-call"]("symbol-node?", node))
  else
    return nil
  end
end
_2amodule_2a["sym?"] = sym_3f0
do local _ = {sym_3f0, nil} end
local function get_leaf0(node)
  parse_210()
  local node0 = (node or ts0.get_node_at_cursor())
  if (leaf_3f0(node0) or sym_3f0(node0)) then
    local node1 = node0
    while sym_3f0(parent0(node1)) do
      node1 = parent0(node1)
    end
    return node1
  else
    return nil
  end
end
_2amodule_2a["get-leaf"] = get_leaf0
do local _ = {get_leaf0, nil} end
local function node_surrounded_by_form_pair_chars_3f0(node, extra_pairs)
  local node_str = node__3estr0(node)
  local first_and_last_chars = text0["first-and-last-chars"](node_str)
  local function _17_(_15_)
    local _arg_16_ = _15_
    local start = _arg_16_[1]
    local _end = _arg_16_[2]
    return (first_and_last_chars == (start .. _end))
  end
  local function _20_(_18_)
    local _arg_19_ = _18_
    local start = _arg_19_[1]
    local _end = _arg_19_[2]
    return (text0["starts-with"](node_str, start) and text0["ends-with"](node_str, _end))
  end
  return (a0.some(_17_, config0["get-in"]({"extract", "form_pairs"})) or a0.some(_20_, extra_pairs) or false)
end
_2amodule_2a["node-surrounded-by-form-pair-chars?"] = node_surrounded_by_form_pair_chars_3f0
do local _ = {node_surrounded_by_form_pair_chars_3f0, nil} end
local function node_prefixed_by_chars_3f0(node, prefixes)
  local node_str = node__3estr0(node)
  local function _21_(prefix)
    return text0["starts-with"](node_str, prefix)
  end
  return (a0.some(_21_, prefixes) or false)
end
_2amodule_2a["node-prefixed-by-chars?"] = node_prefixed_by_chars_3f0
do local _ = {node_prefixed_by_chars_3f0, nil} end
local function get_form0(node)
  if not node then
    parse_210()
  else
  end
  local node0 = (node or ts0.get_node_at_cursor())
  if document_3f0(node0) then
    return nil
  elseif (leaf_3f0(node0) or (false == client0["optional-call"]("form-node?", node0))) then
    return get_form0(parent0(node0))
  else
    local _let_23_ = (client0["optional-call"]("get-form-modifier", node0) or {})
    local modifier = _let_23_["modifier"]
    local res = _let_23_
    if (not modifier or ("none" == modifier)) then
      return node0
    elseif ("parent" == modifier) then
      return get_form0(parent0(node0))
    elseif ("node" == modifier) then
      return res.node
    elseif ("raw" == modifier) then
      return res["node-table"]
    else
      a0.println("Warning: Conjure client returned an unknown get-form-modifier", res)
      return node0
    end
  end
end
_2amodule_2a["get-form"] = get_form0
do local _ = {get_form0, nil} end
return _2amodule_2a
