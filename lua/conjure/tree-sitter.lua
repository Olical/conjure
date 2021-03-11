local _0_0 = nil
do
  local name_0_ = "conjure.tree-sitter"
  local module_0_ = nil
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local client = _local_0_[2]
local config = _local_0_[3]
local str = _local_0_[4]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.tree-sitter"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local ts = nil
do
  local v_0_ = nil
  do
    local ok_3f, x = nil, nil
    local function _2_()
      return require("nvim-treesitter.ts_utils")
    end
    ok_3f, x = pcall(_2_)
    if ok_3f then
      v_0_ = x
    else
    v_0_ = nil
    end
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["ts"] = v_0_
  ts = v_0_
end
local enabled_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function enabled_3f0()
      local function _2_()
        local ok_3f, _ = pcall(vim.treesitter.get_parser)
        return ok_3f
      end
      return (("table" == type(ts)) and config["get-in"]({"extract", "tree_sitter", "enabled"}) and _2_())
    end
    v_0_0 = enabled_3f0
    _0_0["enabled?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["enabled?"] = v_0_
  enabled_3f = v_0_
end
local node__3estr = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function node__3estr0(node)
      if node then
        return str.join("\n", ts.get_node_text(node))
      end
    end
    v_0_0 = node__3estr0
    _0_0["node->str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["node->str"] = v_0_
  node__3estr = v_0_
end
local parent = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function parent0(node)
      if node then
        return node:parent()
      end
    end
    v_0_0 = parent0
    _0_0["parent"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["parent"] = v_0_
  parent = v_0_
end
local document_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function document_3f0(node)
      return not parent(node)
    end
    v_0_0 = document_3f0
    _0_0["document?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["document?"] = v_0_
  document_3f = v_0_
end
local range = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function range0(node)
      if node then
        local sr, sc, er, ec = node:range()
        return {["end"] = {a.inc(er), a.dec(ec)}, start = {a.inc(sr), sc}}
      end
    end
    v_0_0 = range0
    _0_0["range"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["range"] = v_0_
  range = v_0_
end
local get_root = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    v_0_0 = get_root0
    _0_0["get-root"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get-root"] = v_0_
  get_root = v_0_
end
local leaf_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function leaf_3f0(node)
      if node then
        return (0 == node:child_count())
      end
    end
    v_0_0 = leaf_3f0
    _0_0["leaf?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["leaf?"] = v_0_
  leaf_3f = v_0_
end
local get_leaf = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_leaf0(node)
      local node0 = (node or ts.get_node_at_cursor())
      if leaf_3f(node0) then
        return node0
      end
    end
    v_0_0 = get_leaf0
    _0_0["get-leaf"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get-leaf"] = v_0_
  get_leaf = v_0_
end
local get_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    v_0_0 = get_form0
    _0_0["get-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get-form"] = v_0_
  get_form = v_0_
end
return nil