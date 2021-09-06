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
local a, client, config, str = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["str"] = str
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
    local ok_3f, _ = pcall(vim.treesitter.get_parser)
    return ok_3f
  end
  return (("table" == type(ts)) and config["get-in"]({"extract", "tree_sitter", "enabled"}) and _3_())
end
_2amodule_2a["enabled?"] = enabled_3f
local function node__3estr(node)
  if node then
    return str.join("\n", ts.get_node_text(node))
  end
end
_2amodule_2a["node->str"] = node__3estr
local function parent(node)
  if node then
    return node:parent()
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
  end
end
_2amodule_2a["range"] = range
local function get_root(node)
  local node0 = (node or ts.get_node_at_cursor())
  local p1 = parent(node0)
  local p2 = parent(p1)
  if (p1 and p2) then
    return get_root(p1)
  else
    return node0
  end
end
_2amodule_2a["get-root"] = get_root
local function leaf_3f(node)
  if node then
    return (0 == node:child_count())
  end
end
_2amodule_2a["leaf?"] = leaf_3f
local function get_leaf(node)
  local node0 = (node or ts.get_node_at_cursor())
  if leaf_3f(node0) then
    return node0
  end
end
_2amodule_2a["get-leaf"] = get_leaf
local function get_form(node)
  local node0 = (node or ts.get_node_at_cursor())
  if (document_3f(node0) or (false == client["optional-call"]("form-node?", node0))) then
    return nil
  elseif leaf_3f(node0) then
    return get_form(parent(node0))
  else
    return node0
  end
end
_2amodule_2a["get-form"] = get_form