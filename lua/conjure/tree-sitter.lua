local _2afile_2a = "fnl/conjure/tree-sitter.fnl"
local _1_
do
  local name_4_auto = "conjure.tree-sitter"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local client = _local_4_[2]
local config = _local_4_[3]
local str = _local_4_[4]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.tree-sitter"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local ts
do
  local v_23_auto
  do
    local ok_3f, x = nil, nil
    local function _8_()
      return require("nvim-treesitter.ts_utils")
    end
    ok_3f, x = pcall(_8_)
    if ok_3f then
      v_23_auto = x
    else
    v_23_auto = nil
    end
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["ts"] = v_23_auto
  ts = v_23_auto
end
local enabled_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function enabled_3f0()
      local function _10_()
        local ok_3f, _ = pcall(vim.treesitter.get_parser)
        return ok_3f
      end
      return (("table" == type(ts)) and config["get-in"]({"extract", "tree_sitter", "enabled"}) and _10_())
    end
    v_25_auto = enabled_3f0
    _1_["enabled?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["enabled?"] = v_23_auto
  enabled_3f = v_23_auto
end
local node__3estr
do
  local v_23_auto
  do
    local v_25_auto
    local function node__3estr0(node)
      if node then
        return str.join("\n", ts.get_node_text(node))
      end
    end
    v_25_auto = node__3estr0
    _1_["node->str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["node->str"] = v_23_auto
  node__3estr = v_23_auto
end
local parent
do
  local v_23_auto
  do
    local v_25_auto
    local function parent0(node)
      if node then
        return node:parent()
      end
    end
    v_25_auto = parent0
    _1_["parent"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["parent"] = v_23_auto
  parent = v_23_auto
end
local document_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function document_3f0(node)
      return not parent(node)
    end
    v_25_auto = document_3f0
    _1_["document?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["document?"] = v_23_auto
  document_3f = v_23_auto
end
local range
do
  local v_23_auto
  do
    local v_25_auto
    local function range0(node)
      if node then
        local sr, sc, er, ec = node:range()
        return {["end"] = {a.inc(er), a.dec(ec)}, start = {a.inc(sr), sc}}
      end
    end
    v_25_auto = range0
    _1_["range"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["range"] = v_23_auto
  range = v_23_auto
end
local get_root
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = get_root0
    _1_["get-root"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get-root"] = v_23_auto
  get_root = v_23_auto
end
local leaf_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function leaf_3f0(node)
      if node then
        return (0 == node:child_count())
      end
    end
    v_25_auto = leaf_3f0
    _1_["leaf?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["leaf?"] = v_23_auto
  leaf_3f = v_23_auto
end
local get_leaf
do
  local v_23_auto
  do
    local v_25_auto
    local function get_leaf0(node)
      local node0 = (node or ts.get_node_at_cursor())
      if leaf_3f(node0) then
        return node0
      end
    end
    v_25_auto = get_leaf0
    _1_["get-leaf"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get-leaf"] = v_23_auto
  get_leaf = v_23_auto
end
local get_form
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = get_form0
    _1_["get-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get-form"] = v_23_auto
  get_form = v_23_auto
end
return nil