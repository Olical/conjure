local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.config"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local nvim = _local_0_[2]
local str = _local_0_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.config"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local function ks__3evar(ks)
  return ("conjure#" .. str.join("#", ks))
end
local get_in
do
  local v_0_
  local function get_in0(ks)
    local v = a.get(nvim.g, ks__3evar(ks))
    if (a["table?"](v) and a.get(v, vim.type_idx) and a.get(v, vim.val_idx)) then
      return a.get(v, vim.val_idx)
    else
      return v
    end
  end
  v_0_ = get_in0
  _0_0["get-in"] = v_0_
  get_in = v_0_
end
local filetypes
do
  local v_0_
  local function filetypes0()
    return get_in({"filetypes"})
  end
  v_0_ = filetypes0
  _0_0["filetypes"] = v_0_
  filetypes = v_0_
end
local get_in_fn
do
  local v_0_
  local function get_in_fn0(prefix_ks)
    local function _1_(ks)
      return get_in(a.concat(prefix_ks, ks))
    end
    return _1_
  end
  v_0_ = get_in_fn0
  _0_0["get-in-fn"] = v_0_
  get_in_fn = v_0_
end
local assoc_in
do
  local v_0_
  local function assoc_in0(ks, v)
    a.assoc(nvim.g, ks__3evar(ks), v)
    return v
  end
  v_0_ = assoc_in0
  _0_0["assoc-in"] = v_0_
  assoc_in = v_0_
end
local merge
do
  local v_0_
  local function merge0(tbl, opts, ks)
    local ks0 = (ks or {})
    local opts0 = (opts or {})
    local function _2_(_1_0)
      local _arg_0_ = _1_0
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
  v_0_ = merge0
  _0_0["merge"] = v_0_
  merge = v_0_
end
return merge({completion = {fallback = "syntaxcomplete#Complete", omnifunc = "ConjureOmnifunc"}, debug = false, eval = {comment_prefix = nil, inline_results = true, result_register = "c"}, extract = {context_header_lines = 24, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}, tree_sitter = {enabled = false}}, filetype = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", hy = "conjure.client.hy.stdio", janet = "conjure.client.janet.netrepl", racket = "conjure.client.racket.stdio", scheme = "conjure.client.scheme.stdio"}, filetype_suffixes = {racket = {"rkt"}, scheme = {"scm"}}, filetypes = {"clojure", "fennel", "janet", "hy", "racket", "scheme"}, highlight = {enabled = false, group = "IncSearch", timeout = 500}, log = {botright = false, break_length = 80, fold = {enabled = false, lines = 10, marker = {["end"] = "}%~~~", start = "~~~%{"}}, hud = {anchor = "NE", enabled = true, height = 0.3, overlap_padding = 0.1, passive_close_delay = 0, width = 0.42}, strip_ansi_escape_sequences_line_limit = 100, trim = {at = 10000, to = 6000}, wrap = false}, mapping = {def_word = "gd", doc_word = {"K"}, eval_buf = "eb", eval_comment_current_form = "ece", eval_comment_root_form = "ecr", eval_comment_word = "ecw", eval_current_form = "ee", eval_file = "ef", eval_marked_form = "em", eval_motion = "E", eval_replace_form = "e!", eval_root_form = "er", eval_visual = "E", eval_word = "ew", log_close_visible = "lq", log_reset_hard = "lR", log_reset_soft = "lr", log_split = "ls", log_tab = "lt", log_vsplit = "lv", prefix = "<localleader>"}, path_subs = nil, preview = {sample_limit = 0.3}, relative_file_root = nil})