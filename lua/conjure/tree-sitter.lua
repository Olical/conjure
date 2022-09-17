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
    if (1 == nvim.fn.has("nvim-0.7")) then
      return vim.treesitter.query.get_node_text(node, nvim.get_current_buf())
    else
      return str.join("\n", vim.treesitter.query.get_node_text(node))
    end
  else
    return nil
  end
end
_2amodule_2a["node->str"] = node__3estr
local function comment_form_3f(node)
  return text["starts-with"](node__3estr(node), "(comment")
end
_2amodule_2a["comment-form?"] = comment_form_3f
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
local function get_root(node)
  parse_21()
  local node0 = (node or ts.get_node_at_cursor())
  local parent_node = parent(node0)
  if document_3f(node0) then
    return nil
  elseif document_3f(parent_node) then
    return node0
  elseif comment_form_3f(parent_node) then
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
local function get_leaf(node)
  parse_21()
  local node0 = (node or ts.get_node_at_cursor())
  if leaf_3f(node0) then
    return node0
  else
    return nil
  end
end
_2amodule_2a["get-leaf"] = get_leaf
local function node_surrounded_by_form_pair_chars_3f(node, extra_pairs)
  local node_str = node__3estr(node)
  local first_and_last_chars = text["first-and-last-chars"](node_str)
  local function _15_(_13_)
    local _arg_14_ = _13_
    local start = _arg_14_[1]
    local _end = _arg_14_[2]
    return (first_and_last_chars == (start .. _end))
  end
  local function _18_(_16_)
    local _arg_17_ = _16_
    local start = _arg_17_[1]
    local _end = _arg_17_[2]
    return (text["starts-with"](node_str, start) and text["ends-with"](node_str, _end))
  end
  return (a.some(_15_, config["get-in"]({"extract", "form_pairs"})) or a.some(_18_, extra_pairs) or false)
end
_2amodule_2a["node-surrounded-by-form-pair-chars?"] = node_surrounded_by_form_pair_chars_3f
local function get_form(node)
  parse_21()
  local node0 = (node or ts.get_node_at_cursor())
  if document_3f(node0) then
    return nil
  elseif (leaf_3f(node0) or (false == client["optional-call"]("form-node?", node0))) then
    return get_form(parent(node0))
  else
    return node0
  end
end
_2amodule_2a["get-form"] = get_form
return _2amodule_2a