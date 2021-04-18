local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.tree-sitter"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local client = _local_0_[2]
local config = _local_0_[3]
local str = _local_0_[4]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.tree-sitter"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
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
local enabled_3f
do
  local v_0_
  local function enabled_3f0()
    local function _1_()
      local ok_3f, _ = pcall(vim.treesitter.get_parser)
      return ok_3f
    end
    return (("table" == type(ts)) and config["get-in"]({"extract", "tree_sitter", "enabled"}) and _1_())
  end
  v_0_ = enabled_3f0
  _0_0["enabled?"] = v_0_
  enabled_3f = v_0_
end
local node__3estr
do
  local v_0_
  local function node__3estr0(node)
    if node then
      return str.join("\n", ts.get_node_text(node))
    end
  end
  v_0_ = node__3estr0
  _0_0["node->str"] = v_0_
  node__3estr = v_0_
end
local parent
do
  local v_0_
  local function parent0(node)
    if node then
      return node:parent()
    end
  end
  v_0_ = parent0
  _0_0["parent"] = v_0_
  parent = v_0_
end
local document_3f
do
  local v_0_
  local function document_3f0(node)
    return not parent(node)
  end
  v_0_ = document_3f0
  _0_0["document?"] = v_0_
  document_3f = v_0_
end
local range
do
  local v_0_
  local function range0(node)
    if node then
      local sr, sc, er, ec = node:range()
      return {["end"] = {a.inc(er), a.dec(ec)}, start = {a.inc(sr), sc}}
    end
  end
  v_0_ = range0
  _0_0["range"] = v_0_
  range = v_0_
end
local get_root
do
  local v_0_
  local function get_root0(node)
    local node0 = (node or ts.get_node_at_cursor())
    local p1 = parent(node0)
    local p2 = parent(p1)
    if (p1 and p2) then
      return get_root0(p1)
    else
      return node0
    end
  end
  v_0_ = get_root0
  _0_0["get-root"] = v_0_
  get_root = v_0_
end
local leaf_3f
do
  local v_0_
  local function leaf_3f0(node)
    if node then
      return (0 == node:child_count())
    end
  end
  v_0_ = leaf_3f0
  _0_0["leaf?"] = v_0_
  leaf_3f = v_0_
end
local get_leaf
do
  local v_0_
  local function get_leaf0(node)
    local node0 = (node or ts.get_node_at_cursor())
    if leaf_3f(node0) then
      return node0
    end
  end
  v_0_ = get_leaf0
  _0_0["get-leaf"] = v_0_
  get_leaf = v_0_
end
local get_form
do
  local v_0_
  local function get_form0(node)
    local node0 = (node or ts.get_node_at_cursor())
    if (document_3f(node0) or (false == client["optional-call"]("form-node?", node0))) then
      return nil
    elseif leaf_3f(node0) then
      return get_form0(parent(node0))
    else
      return node0
    end
  end
  v_0_ = get_form0
  _0_0["get-form"] = v_0_
  get_form = v_0_
end
return nil