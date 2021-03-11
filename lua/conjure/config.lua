local _0_0 = nil
do
  local name_0_ = "conjure.config"
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
    return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local nvim = _local_0_[2]
local str = _local_0_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.config"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local ks__3evar = nil
do
  local v_0_ = nil
  local function ks__3evar0(ks)
    return ("conjure#" .. str.join("#", ks))
  end
  v_0_ = ks__3evar0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["ks->var"] = v_0_
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get-in"] = v_0_
  get_in = v_0_
end
local filetypes = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function filetypes0()
      return get_in({"filetypes"})
    end
    v_0_0 = filetypes0
    _0_0["filetypes"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["filetypes"] = v_0_
  filetypes = v_0_
end
local get_in_fn = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_in_fn0(prefix_ks)
      local function _2_(ks)
        return get_in(a.concat(prefix_ks, ks))
      end
      return _2_
    end
    v_0_0 = get_in_fn0
    _0_0["get-in-fn"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get-in-fn"] = v_0_
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["assoc-in"] = v_0_
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
      local function _2_(_3_0)
        local _arg_0_ = _3_0
        local k = _arg_0_[1]
        local v = _arg_0_[2]
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
      a["run!"](_2_, a["kv-pairs"](tbl))
      return nil
    end
    v_0_0 = merge0
    _0_0["merge"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["merge"] = v_0_
  merge = v_0_
end
return merge({completion = {fallback = "syntaxcomplete#Complete", omnifunc = "ConjureOmnifunc"}, debug = false, eval = {comment_prefix = nil, inline_results = true, result_register = "c"}, extract = {context_header_lines = 24, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}, tree_sitter = {enabled = false}}, filetype = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", guile = "conjure.client.guile.socket", hy = "conjure.client.hy.stdio", janet = "conjure.client.janet.netrepl", racket = "conjure.client.racket.stdio", scheme = "conjure.client.mit-scheme.stdio"}, filetype_suffixes = {racket = {"rkt"}, scheme = {"scm"}}, filetypes = {"clojure", "fennel", "janet", "racket", "hy", "guile", "scheme"}, log = {botright = false, break_length = 80, fold = {enabled = false, lines = 10, marker = {["end"] = "}%~~~", start = "~~~%{"}}, hud = {anchor = "NE", enabled = true, height = 0.3, overlap_padding = 0.1, passive_close_delay = 0, width = 0.42}, strip_ansi_escape_sequences_line_limit = 100, trim = {at = 10000, to = 6000}, wrap = false}, mapping = {def_word = "gd", doc_word = {"K"}, eval_buf = "eb", eval_comment_current_form = "ece", eval_comment_root_form = "ecr", eval_comment_word = "ecw", eval_current_form = "ee", eval_file = "ef", eval_marked_form = "em", eval_motion = "E", eval_replace_form = "e!", eval_root_form = "er", eval_visual = "E", eval_word = "ew", log_close_visible = "lq", log_reset_hard = "lR", log_reset_soft = "lr", log_split = "ls", log_tab = "lt", log_vsplit = "lv", prefix = "<localleader>"}, path_subs = nil, preview = {sample_limit = 0.3}, relative_file_root = nil})