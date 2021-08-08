local _2afile_2a = "fnl/conjure/config.fnl"
local _1_
do
  local name_4_auto = "conjure.config"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nvim = _local_4_[2]
local str = _local_4_[3]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.config"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local ks__3evar
do
  local v_23_auto
  local function ks__3evar0(ks)
    return ("conjure#" .. str.join("#", ks))
  end
  v_23_auto = ks__3evar0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["ks->var"] = v_23_auto
  ks__3evar = v_23_auto
end
local get_in
do
  local v_23_auto
  do
    local v_25_auto
    local function get_in0(ks)
      local v = a.get(nvim.g, ks__3evar(ks))
      if (a["table?"](v) and a.get(v, vim.type_idx) and a.get(v, vim.val_idx)) then
        return a.get(v, vim.val_idx)
      else
        return v
      end
    end
    v_25_auto = get_in0
    _1_["get-in"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get-in"] = v_23_auto
  get_in = v_23_auto
end
local filetypes
do
  local v_23_auto
  do
    local v_25_auto
    local function filetypes0()
      return get_in({"filetypes"})
    end
    v_25_auto = filetypes0
    _1_["filetypes"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["filetypes"] = v_23_auto
  filetypes = v_23_auto
end
local get_in_fn
do
  local v_23_auto
  do
    local v_25_auto
    local function get_in_fn0(prefix_ks)
      local function _9_(ks)
        return get_in(a.concat(prefix_ks, ks))
      end
      return _9_
    end
    v_25_auto = get_in_fn0
    _1_["get-in-fn"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get-in-fn"] = v_23_auto
  get_in_fn = v_23_auto
end
local assoc_in
do
  local v_23_auto
  do
    local v_25_auto
    local function assoc_in0(ks, v)
      a.assoc(nvim.g, ks__3evar(ks), v)
      return v
    end
    v_25_auto = assoc_in0
    _1_["assoc-in"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["assoc-in"] = v_23_auto
  assoc_in = v_23_auto
end
local merge
do
  local v_23_auto
  do
    local v_25_auto
    local function merge0(tbl, opts, ks)
      local ks0 = (ks or {})
      local opts0 = (opts or {})
      local function _12_(_10_)
        local _arg_11_ = _10_
        local k = _arg_11_[1]
        local v = _arg_11_[2]
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
      a["run!"](_12_, a["kv-pairs"](tbl))
      return nil
    end
    v_25_auto = merge0
    _1_["merge"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["merge"] = v_23_auto
  merge = v_23_auto
end
return merge({completion = {fallback = "syntaxcomplete#Complete", omnifunc = "ConjureOmnifunc"}, debug = false, eval = {comment_prefix = nil, gsubs = {}, inline_results = true, result_register = "c"}, extract = {context_header_lines = 24, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}, tree_sitter = {enabled = false}}, filetype = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", hy = "conjure.client.hy.stdio", janet = "conjure.client.janet.netrepl", racket = "conjure.client.racket.stdio", scheme = "conjure.client.scheme.stdio"}, filetype_suffixes = {racket = {"rkt"}, scheme = {"scm"}}, filetypes = {"clojure", "fennel", "janet", "hy", "racket", "scheme"}, highlight = {enabled = false, group = "IncSearch", timeout = 500}, log = {botright = false, break_length = 80, fold = {enabled = false, lines = 10, marker = {["end"] = "}%~~~", start = "~~~%{"}}, hud = {anchor = "NE", border = "single", enabled = true, height = 0.3, overlap_padding = 0.1, passive_close_delay = 0, width = 0.42}, strip_ansi_escape_sequences_line_limit = 1000, trim = {at = 10000, to = 6000}, wrap = false}, mapping = {def_word = "gd", doc_word = {"K"}, eval_buf = "eb", eval_comment_current_form = "ece", eval_comment_root_form = "ecr", eval_comment_word = "ecw", eval_current_form = "ee", eval_file = "ef", eval_marked_form = "em", eval_motion = "E", eval_replace_form = "e!", eval_root_form = "er", eval_visual = "E", eval_word = "ew", log_close_visible = "lq", log_reset_hard = "lR", log_reset_soft = "lr", log_split = "ls", log_tab = "lt", log_vsplit = "lv", prefix = "<localleader>"}, path_subs = nil, preview = {sample_limit = 0.3}, relative_file_root = nil})