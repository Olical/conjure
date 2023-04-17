local _2afile_2a = "fnl/conjure/tree-sitter.fnl"
local _2amodule_name_2a = "conjure.tree-sitter"
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
local a, client, config, nvim, str, text = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local ts
do
  local ok_3f, x = nil, nil
  local function _1_()
    return require("nvim-treesitter.ts_utils")
  end
  ok_3f, x = pcall(_1_)
  if ok_3f then
    ts = x
  else
    ts = nil
  end
end
_2amodule_locals_2a["ts"] = ts
local function enabled_3f()
  local function _3_()
    local ok_3f, parser = pcall(vim.treesitter.get_parser)
    return (ok_3f and parser)
  end
  if (("table" == type(ts)) and config["get-in"]({"extract", "tree_sitter", "enabled"}) and _3_()) then
    return true
  else
    return false
  end
end
_2amodule_2a["enabled?"] = enabled_3f
local function parse_21()
  local ok_3f, parser = pcall(vim.treesitter.get_parser)
  if ok_3f then
    return parser:parse()
  else
    return nil
  end
end
_2amodule_2a["parse!"] = parse_21
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
_2amodule_2a["node->str"] = node__3estr
local function lisp_comment_node_3f(node)
  return text["starts-with"](node__3estr(node), "(comment")
end
_2amodule_2a["lisp-comment-node?"] = lisp_comment_node_3f
local function parent(node)
  if node then
    return node:parent()
  else
    return nil
  end
end
_2amodule_2a["parent"] = parent
local function document_3f(node)
  return not parent(node)
end
_2amodule_2a["document?"] = document_3f
local function range(node)
  if node then
    local sr, sc, er, ec = node:range()
    return {start = {a.inc(sr), sc}, ["end"] = {a.inc(er), a.dec(ec)}}
  else
    return nil
  end
end
_2amodule_2a["range"] = range
local function node__3etable(node)
  if (a.get(node, "range") and a.get(node, "content")) then
    return node
  elseif node then
    return {range = range(node), content = node__3estr(node)}
  else
    return nil
  end
end
_2amodule_2a["node->table"] = node__3etable
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
_2amodule_2a["get-root"] = get_root
local function leaf_3f(node)
  if node then
    return (0 == node:child_count())
  else
    return nil
  end
end
_2amodule_2a["leaf?"] = leaf_3f
local function sym_3f(node)
  if node then
    return (string.find(node:type(), "sym") or client["optional-call"]("symbol-node?", node))
  else
    return nil
  end
end
_2amodule_2a["sym?"] = sym_3f
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
_2amodule_2a["get-leaf"] = get_leaf
local function node_surrounded_by_form_pair_chars_3f(node, extra_pairs)
  local node_str = node__3estr(node)
  local first_and_last_chars = text["first-and-last-chars"](node_str)
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
    return (text["starts-with"](node_str, start) and text["ends-with"](node_str, _end))
  end
  return (a.some(_17_, config["get-in"]({"extract", "form_pairs"})) or a.some(_20_, extra_pairs) or false)
end
_2amodule_2a["node-surrounded-by-form-pair-chars?"] = node_surrounded_by_form_pair_chars_3f
local function node_prefixed_by_chars_3f(node, prefixes)
  local node_str = node__3estr(node)
  local function _21_(prefix)
    return text["starts-with"](node_str, prefix)
  end
  return (a.some(_21_, prefixes) or false)
end
_2amodule_2a["node-prefixed-by-chars?"] = node_prefixed_by_chars_3f
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
    local _let_23_ = (client["optional-call"]("get-form-modifier", node0) or {})
    local modifier = _let_23_["modifier"]
    local res = _let_23_
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
_2amodule_2a["get-form"] = get_form
return _2amodule_2a