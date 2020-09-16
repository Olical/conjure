local _0_0 = nil
do
  local name_0_ = "conjure.config"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _1_ = _2_(...)
local a = _1_[1]
local nvim = _1_[2]
local str = _1_[3]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local ks__3evar = nil
do
  local v_0_ = nil
  local function ks__3evar0(ks)
    return ("conjure#" .. str.join("#", ks))
  end
  v_0_ = ks__3evar0
  _0_0["aniseed/locals"]["ks->var"] = v_0_
  ks__3evar = v_0_
end
local get_in = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_in0(ks)
      local v = a.get(nvim.g, ks__3evar(ks))
      if (a["table?"](v) and a.get(v, vim.type_idx) and a.get(v, vim.val_idx)) then
        return a.get(v, vim.val_idx)
      else
        return v
      end
    end
    v_0_0 = get_in0
    _0_0["get-in"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-in"] = v_0_
  get_in = v_0_
end
local filetypes = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function filetypes0()
      return a.keys(get_in({"filetype_client"}))
    end
    v_0_0 = filetypes0
    _0_0["filetypes"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["filetypes"] = v_0_
  filetypes = v_0_
end
local get_in_fn = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_in_fn0(prefix_ks)
      local function _3_(ks)
        return get_in(a.concat(prefix_ks, ks))
      end
      return _3_
    end
    v_0_0 = get_in_fn0
    _0_0["get-in-fn"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-in-fn"] = v_0_
  get_in_fn = v_0_
end
local assoc_in = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function assoc_in0(ks, v)
      a.assoc(nvim.g, ks__3evar(ks), v)
      return v
    end
    v_0_0 = assoc_in0
    _0_0["assoc-in"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["assoc-in"] = v_0_
  assoc_in = v_0_
end
local merge = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    v_0_0 = merge0
    _0_0["merge"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["merge"] = v_0_
  merge = v_0_
end
assoc_in({"filetype_client"}, {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", janet = "conjure.client.janet.netrepl"})
return merge({completion = {fallback = "syntaxcomplete#Complete", omnifunc = "ConjureOmnifunc"}, debug = false, eval = {result_register = "c"}, extract = {context_header_lines = 24, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}}, log = {botright = false, break_length = 80, hud = {enabled = true, height = 0.29999999999999999, passive_close_delay = 0, width = 0.41999999999999998}, strip_ansi_escape_sequences_line_limit = 100, trim = {at = 10000, to = 6000}, wrap = false}, mapping = {def_word = "gd", doc_word = {"K"}, eval_buf = "eb", eval_current_form = "ee", eval_file = "ef", eval_marked_form = "em", eval_motion = "E", eval_replace_form = "e!", eval_root_form = "er", eval_visual = "E", eval_word = "ew", log_close_visible = "lq", log_split = "ls", log_tab = "lt", log_vsplit = "lv", prefix = "<localleader>"}, preview = {sample_limit = 0.29999999999999999}, relative_file_root = nil})