local _0_0 = nil
do
  local name_23_0_ = "conjure.config2"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local nvim = _2_[2]
local str = _2_[3]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local ks__3evar = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function ks__3evar0(ks)
      return ("conjure_" .. str.join("_", ks))
    end
    v_23_0_0 = ks__3evar0
    _0_0["ks->var"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["ks->var"] = v_23_0_
  ks__3evar = v_23_0_
end
local get_in = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function get_in0(ks)
      local v = a.get(nvim.g, ks__3evar(ks))
      if (a["table?"](v) and a.get(v, vim.type_idx) and a.get(v, vim.val_idx)) then
        return a.get(v, vim.val_idx)
      else
        return v
      end
    end
    v_23_0_0 = get_in0
    _0_0["get-in"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["get-in"] = v_23_0_
  get_in = v_23_0_
end
local assoc_in = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function assoc_in0(ks, v)
      a.assoc(nvim.g, ks__3evar(ks), v)
      return v
    end
    v_23_0_0 = assoc_in0
    _0_0["assoc-in"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["assoc-in"] = v_23_0_
  assoc_in = v_23_0_
end
local merge = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function merge0(tbl, opts, ks)
      local ks0 = (ks or {})
      local opts0 = (opts or {})
      local function _3_(_4_0)
        local _5_ = _4_0
        local k = _5_[1]
        local v = _5_[2]
        local ks1 = a.concat(ks0, {k})
        local current = get_in(ks1)
        if (a["table?"](v) and not a.get(v, 1)) then
          return merge0(v, opts0, ks1)
        else
          if (a["nil?"](current) or opts0["overwrite?"]) then
            return assoc_in(ks1, v)
          end
        end
      end
      a["run!"](_3_, a["kv-pairs"](tbl))
      return nil
    end
    v_23_0_0 = merge0
    _0_0["merge"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["merge"] = v_23_0_
  merge = v_23_0_
end
local init = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function init0()
      assoc_in({"client"}, {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", janet = "conjure.client.janet.netrepl"})
      return merge({debug = false, eval = {["result-register"] = "c"}, extract = {["context-header-lines"] = 24, ["form-pairs"] = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}}, log = {["break-length"] = 80, ["strip-ansi-escape-sequences-line-limit"] = 100, botright = false, hud = {["passive-close-delay"] = 0, enabled = true, height = 0.29999999999999999, width = 0.41999999999999998}, trim = {at = 10000, to = 6000}}, mapping = {["def-word"] = {"gd"}, ["doc-word"] = {"K"}, ["eval-buf"] = "eb", ["eval-current-form"] = "ee", ["eval-file"] = "ef", ["eval-marked-form"] = "em", ["eval-motion"] = "E", ["eval-replace-form"] = "e!", ["eval-root-form"] = "er", ["eval-visual"] = "E", ["eval-word"] = "ew", ["log-close-visible"] = "lq", ["log-split"] = "ls", ["log-tab"] = "lt", ["log-vsplit"] = "lv", prefix = "<localleader>"}, preview = {["sample-limit"] = 0.29999999999999999}})
    end
    v_23_0_0 = init0
    _0_0["init"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["init"] = v_23_0_
  init = v_23_0_
end
return nil