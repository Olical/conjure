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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", eval = "conjure.eval", extract = "conjure.extract", fennel = "conjure.aniseed.fennel", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
  return {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.client"), require("conjure.config"), require("conjure.eval"), require("conjure.extract"), require("conjure.aniseed.fennel"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text")}
end
local _2_ = _1_(...)
local a = _2_[1]
local text = _2_[10]
local bridge = _2_[2]
local client = _2_[3]
local config = _2_[4]
local eval = _2_[5]
local extract = _2_[6]
local fennel = _2_[7]
local nvim = _2_[8]
local str = _2_[9]
do local _ = ({nil, _0_0, nil})[2] end
local desc = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function desc0(buf_res, group_name, val)
      local wk_var = a["get-in"](config, {"which-key", "var"})
      if (buf_res and not buf_res["raw?"] and wk_var) then
        local orig = nvim.get_var(wk_var)
        local keys = text.chars(buf_res.unprefixed)
        a["assoc-in"](orig, keys, val)
        if (a.count(keys) > 1) then
          a["assoc-in"](orig, {a.first(keys), "name"}, ("+" .. group_name))
        end
        return nvim.set_var(wk_var, orig)
      end
    end
    v_23_0_0 = desc0
    _0_0["desc"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["desc"] = v_23_0_
  desc = v_23_0_
end
local buf = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function buf0(mode, keys, ...)
      if keys then
        local args = {...}
        local raw_3f = a["table?"](keys)
        local unprefixed = nil
        if raw_3f then
          unprefixed = a.first(keys)
        else
          unprefixed = keys
        end
        local prefixed = nil
        if raw_3f then
          prefixed = unprefixed
        else
          prefixed = (config.mappings.prefix .. unprefixed)
        end
        local _5_
        if (2 == a.count(args)) then
          _5_ = (":" .. bridge["viml->lua"](unpack(args)) .. "<cr>")
        else
          _5_ = unpack(args)
        end
        nvim.buf_set_keymap(0, mode, prefixed, _5_, {noremap = true, silent = true})
        return {["raw?"] = raw_3f, prefixed = prefixed, unprefixed = unprefixed}
      end
    end
    v_23_0_0 = buf0
    _0_0["buf"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf"] = v_23_0_
  buf = v_23_0_
end
local map_fn = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function map_fn0(mappings)
      local function _3_(mode, group, cfg__3eargs)
        local function _4_(_5_0)
          local _6_ = _5_0
          local cfg = _6_[1]
          local args = _6_[2]
          return desc(buf(mode, a.get(mappings, cfg), unpack(args)), group, cfg)
        end
        return a["run!"](_4_, a["kv-pairs"](cfg__3eargs))
      end
      return _3_
    end
    v_23_0_0 = map_fn0
    _0_0["map-fn"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["map-fn"] = v_23_0_
  map_fn = v_23_0_
end
local on_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_filetype0()
      do
        local map = map_fn(config.mappings)
        map("n", "eval", {["eval-buf"] = {"conjure.eval", "buf"}, ["eval-current-form"] = {"conjure.eval", "current-form"}, ["eval-file"] = {"conjure.eval", "file"}, ["eval-marked-form"] = {"conjure.eval", "marked-form"}, ["eval-motion"] = {":set opfunc=ConjureEvalMotion<cr>g@"}, ["eval-replace-form"] = {"conjure.eval", "replace-form"}, ["eval-root-form"] = {"conjure.eval", "root-form"}, ["eval-word"] = {"conjure.eval", "word"}})
        map("n", "util", {["def-word"] = {"conjure.eval", "def-word"}, ["doc-word"] = {"conjure.eval", "doc-word"}})
        map("v", "eval", {["eval-visual"] = {"conjure.eval", "selection"}})
        map("n", "log", {["log-close-visible"] = {"conjure.log", "close-visible"}, ["log-split"] = {"conjure.log", "split"}, ["log-tab"] = {"conjure.log", "tab"}, ["log-vsplit"] = {"conjure.log", "vsplit"}})
      end
      nvim.ex.setlocal("omnifunc=ConjureOmnifunc")
      return client["optional-call"]("on-filetype")
    end
    v_23_0_0 = on_filetype0
    _0_0["on-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_23_0_
  on_filetype = v_23_0_
end
local parse_config_target = nil
do
  local v_23_0_ = nil
  local function parse_config_target0(target)
    local client_path = str.split(target, "/")
    local _3_
    if (2 == a.count(client_path)) then
      _3_ = a.first(client_path)
    else
    _3_ = nil
    end
    return {client = _3_, path = str.split(a.last(client_path), "%.")}
  end
  v_23_0_ = parse_config_target0
  _0_0["aniseed/locals"]["parse-config-target"] = v_23_0_
  parse_config_target = v_23_0_
end
local config_command = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function config_command0(target, ...)
      local opts = parse_config_target(target)
      local current = config.get(opts)
      local val = str.join({...})
      if a["empty?"](val) then
        return a.println(target, "=", a["pr-str"](current))
      else
        return config.assoc(a.assoc(opts, "val", fennel.eval(val)))
      end
    end
    v_23_0_0 = config_command0
    _0_0["config-command"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["config-command"] = v_23_0_
  config_command = v_23_0_
end
local assoc_initial_config = nil
do
  local v_23_0_ = nil
  local function assoc_initial_config0()
    if nvim.g.conjure_config then
      local _3_0 = nvim.g.conjure_config
      if _3_0 then
        local _4_0 = nil
        local function _5_(_6_0)
          local _7_ = _6_0
          local target = _7_[1]
          local val = _7_[2]
          return a.merge(parse_config_target(target), {val = val})
        end
        _4_0 = a["map-indexed"](_5_, _3_0)
        if _4_0 then
          return a["run!"](config.assoc, _4_0)
        else
          return _4_0
        end
      else
        return _3_0
      end
    end
  end
  v_23_0_ = assoc_initial_config0
  _0_0["aniseed/locals"]["assoc-initial-config"] = v_23_0_
  assoc_initial_config = v_23_0_
end
local init = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function init0(filetypes)
      nvim.ex.augroup("conjure_init_filetypes")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
      nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.log", "close-hud", {}))
      nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.log", "close-hud", {}))
      nvim.ex.augroup("END")
      return assoc_initial_config()
    end
    v_23_0_0 = init0
    _0_0["init"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["init"] = v_23_0_
  init = v_23_0_
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
local omnifunc = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function omnifunc0(find_start_3f, base)
      if find_start_3f then
        local _3_ = nvim.win_get_cursor(0)
        local row = _3_[1]
        local col = _3_[2]
        local _4_ = nvim.buf_get_lines(0, a.dec(row), row, false)
        local line = _4_[1]
        return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
      else
        return eval["completions-sync"](base)
      end
    end
    v_23_0_0 = omnifunc0
    _0_0["omnifunc"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["omnifunc"] = v_23_0_
  omnifunc = v_23_0_
end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
nvim.ex.command_("-nargs=? -range ConjureEval", bridge["viml->lua"]("conjure.mapping", "eval-ranged-command", {args = "<line1>, <line2>, <q-args>"}))
nvim.ex.command_("-nargs=+ ConjureConfig", bridge["viml->lua"]("conjure.mapping", "config-command", {args = "<f-args>"}))
return nvim.ex.command_("ConjureSchool", bridge["viml->lua"]("conjure.school", "start", {}))