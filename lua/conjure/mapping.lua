local _0_0 = nil
do
  local name_23_0_ = "conjure.mapping"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bridge = "conjure.bridge", config = "conjure.config", eval = "conjure.eval", extract = "conjure.extract", lang = "conjure.lang", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.config"), require("conjure.eval"), require("conjure.extract"), require("conjure.lang"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local bridge = _2_[2]
local config = _2_[3]
local eval = _2_[4]
local extract = _2_[5]
local lang = _2_[6]
local nvim = _2_[7]
local str = _2_[8]
do local _ = ({nil, _0_0, nil})[2] end
local buf = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function buf0(mode, keys, ...)
      local args = {...}
      local _3_
      if a["string?"](keys) then
        _3_ = (config.mappings.prefix .. keys)
      else
        _3_ = a.first(keys)
      end
      local _5_
      if (2 == a.count(args)) then
        _5_ = (":" .. bridge["viml->lua"](unpack(args)) .. "<cr>")
      else
        _5_ = unpack(args)
      end
      return nvim.buf_set_keymap(0, mode, _3_, _5_, {noremap = true, silent = true})
    end
    v_23_0_0 = buf0
    _0_0["buf"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf"] = v_23_0_
  buf = v_23_0_
end
local on_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_filetype0()
      buf("n", config.mappings["eval-motion"], ":set opfunc=ConjureEvalMotion<cr>g@")
      buf("n", config.mappings["log-split"], "conjure.log", "split")
      buf("n", config.mappings["log-vsplit"], "conjure.log", "vsplit")
      buf("n", config.mappings["log-tab"], "conjure.log", "tab")
      buf("n", config.mappings["eval-current-form"], "conjure.eval", "current-form")
      buf("n", config.mappings["eval-root-form"], "conjure.eval", "root-form")
      buf("n", config.mappings["eval-marked-form"], "conjure.eval", "marked-form")
      buf("n", config.mappings["eval-word"], "conjure.eval", "word")
      buf("n", config.mappings["eval-file"], "conjure.eval", "file")
      buf("n", config.mappings["eval-buf"], "conjure.eval", "buf")
      buf("v", config.mappings["eval-visual"], "conjure.eval", "selection")
      buf("n", config.mappings["close-hud"], "conjure.log", "close-hud")
      buf("n", config.mappings["doc-word"], "conjure.eval", "doc-word")
      buf("n", config.mappings["def-word"], "conjure.eval", "def-word")
      nvim.ex.autocmd("CursorMoved", "<buffer>", bridge["viml->lua"]("conjure.log", "close-hud", {}))
      nvim.ex.autocmd("CursorMovedI", "<buffer>", bridge["viml->lua"]("conjure.log", "close-hud", {}))
      return lang.call("on-filetype")
    end
    v_23_0_0 = on_filetype0
    _0_0["on-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_23_0_
  on_filetype = v_23_0_
end
local setup_filetypes = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function setup_filetypes0(filetypes)
      nvim.ex.augroup("conjure_init_filetypes")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
      return nvim.ex.augroup("END")
    end
    v_23_0_0 = setup_filetypes0
    _0_0["setup-filetypes"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["setup-filetypes"] = v_23_0_
  setup_filetypes = v_23_0_
end
local eval_ranged_command = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_ranged_command0(start, _end, code)
      if ("" == code) then
        return eval.range(a.dec(start), _end)
      else
        return eval.command(code)
      end
    end
    v_23_0_0 = eval_ranged_command0
    _0_0["eval-ranged-command"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-ranged-command"] = v_23_0_
  eval_ranged_command = v_23_0_
end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
return nvim.ex.command_("-nargs=? -range ConjureEval", bridge["viml->lua"]("conjure.mapping", "eval-ranged-command", {args = "<line1>, <line2>, <q-args>"}))