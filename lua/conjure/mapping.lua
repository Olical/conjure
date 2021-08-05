local _2afile_2a = "fnl/conjure/mapping.fnl"
local _0_
do
  local name_0_ = "conjure.mapping"
  local module_0_
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
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, autoload = {a = "conjure.aniseed.core", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", eval = "conjure.eval", extract = "conjure.extract", log = "conjure.log", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local bridge = _local_0_[2]
local client = _local_0_[3]
local config = _local_0_[4]
local eval = _local_0_[5]
local extract = _local_0_[6]
local log = _local_0_[7]
local nvim = _local_0_[8]
local str = _local_0_[9]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.mapping"
do local _ = ({nil, _0_, nil, {{nil}, nil, nil, nil}})[2] end
local cfg
do
  local v_0_
  local function cfg0(k)
    return config["get-in"]({"mapping", k})
  end
  v_0_ = cfg0
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["cfg"] = v_0_
  cfg = v_0_
end
local vim_repeat
do
  local v_0_
  local function vim_repeat0(mapping)
    return ("repeat#set(\"" .. nvim.fn.escape(mapping, "\"") .. "\", 1)")
  end
  v_0_ = vim_repeat0
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["vim-repeat"] = v_0_
  vim_repeat = v_0_
end
local buf
do
  local v_0_
  do
    local v_0_0
    local function buf0(mode_or_opts, cmd_suffix, keys, ...)
      if keys then
        local function _3_(...)
          if ("table" == type(mode_or_opts)) then
            return {a.get(mode_or_opts, "mode"), mode_or_opts}
          else
            return {mode_or_opts, {}}
          end
        end
        local _let_0_ = _3_(...)
        local mode = _let_0_[1]
        local opts = _let_0_[2]
        local args = {...}
        local mapping
        if a["string?"](keys) then
          mapping = (cfg("prefix") .. keys)
        else
          mapping = a.first(keys)
        end
        local cmd = (cmd_suffix and ("Conjure" .. cmd_suffix))
        if cmd then
          nvim.ex.command_(("-range " .. cmd), bridge["viml->lua"](unpack(args)))
        end
        local _6_
        if cmd then
          local function _7_(...)
            if (false ~= a.get(opts, "repeat?")) then
              return (":silent! call " .. vim_repeat(mapping) .. "<cr>")
            else
              return ""
            end
          end
          _6_ = (":" .. cmd .. "<cr>" .. _7_(...))
        else
          _6_ = unpack(args)
        end
        return nvim.buf_set_keymap(0, mode, mapping, _6_, {noremap = true, silent = true})
      end
    end
    v_0_0 = buf0
    _0_["buf"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["buf"] = v_0_
  buf = v_0_
end
local eval_marked_form
do
  local v_0_
  do
    local v_0_0
    local function eval_marked_form0()
      local mark = eval["marked-form"]()
      local mapping
      local function _3_(m)
        return ((":ConjureEvalMarkedForm<CR>" == m.rhs) and m.lhs)
      end
      mapping = a.some(_3_, nvim.buf_get_keymap(0, "n"))
      if (mark and mapping) then
        return nvim.ex.silent_("call", vim_repeat((mapping .. mark)))
      end
    end
    v_0_0 = eval_marked_form0
    _0_["eval-marked-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["eval-marked-form"] = v_0_
  eval_marked_form = v_0_
end
local on_filetype
do
  local v_0_
  do
    local v_0_0
    local function on_filetype0()
      buf("n", "LogSplit", cfg("log_split"), "conjure.log", "split")
      buf("n", "LogVSplit", cfg("log_vsplit"), "conjure.log", "vsplit")
      buf("n", "LogTab", cfg("log_tab"), "conjure.log", "tab")
      buf("n", "LogCloseVisible", cfg("log_close_visible"), "conjure.log", "close-visible")
      buf("n", "LogResetSoft", cfg("log_reset_soft"), "conjure.log", "reset-soft")
      buf("n", "LogResetHard", cfg("log_reset_hard"), "conjure.log", "reset-hard")
      do
        local cfg_smart
        local function _3_(ft)
          return (ft == nvim.bo.filetype)
        end
        if a.some(_3_, config["filetypes-non-lisp"]()) then
          local function _4_(k)
            return config["get-in"]({"mapping", "non_lisp", k})
          end
          cfg_smart = _4_
        else
          cfg_smart = cfg
        end
        buf("n", nil, cfg_smart("eval_motion"), ":set opfunc=ConjureEvalMotion<cr>g@")
        buf("n", "EvalCurrentForm", cfg_smart("eval_current_form"), "conjure.eval", "current-form")
        buf("n", "EvalCommentCurrentForm", cfg_smart("eval_comment_current_form"), "conjure.eval", "comment-current-form")
        buf("n", "EvalRootForm", cfg_smart("eval_root_form"), "conjure.eval", "root-form")
        buf("n", "EvalCommentRootForm", cfg_smart("eval_comment_root_form"), "conjure.eval", "comment-root-form")
        buf("n", "EvalWord", cfg_smart("eval_word"), "conjure.eval", "word")
        buf("n", "EvalCommentWord", cfg_smart("eval_comment_word"), "conjure.eval", "comment-word")
        buf("n", "EvalReplaceForm", cfg_smart("eval_replace_form"), "conjure.eval", "replace-form")
        buf({["repeat?"] = false, mode = "n"}, "EvalMarkedForm", cfg_smart("eval_marked_form"), "conjure.mapping", "eval-marked-form")
        buf("n", "EvalFile", cfg_smart("eval_file"), "conjure.eval", "file")
        buf("n", "EvalBuf", cfg_smart("eval_buf"), "conjure.eval", "buf")
        buf("v", "EvalVisual", cfg_smart("eval_visual"), "conjure.eval", "selection")
        buf("n", "DocWord", cfg_smart("doc_word"), "conjure.eval", "doc-word")
        buf("n", "DefWord", cfg_smart("def_word"), "conjure.eval", "def-word")
      end
      do
        local fn_name = config["get-in"]({"completion", "omnifunc"})
        if fn_name then
          nvim.ex.setlocal(("omnifunc=" .. fn_name))
        end
      end
      return client["optional-call"]("on-filetype")
    end
    v_0_0 = on_filetype0
    _0_["on-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_exit
do
  local v_0_
  do
    local v_0_0
    local function on_exit0()
      local function _3_()
        return client["optional-call"]("on-exit")
      end
      return client["each-loaded-client"](_3_)
    end
    v_0_0 = on_exit0
    _0_["on-exit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-exit"] = v_0_
  on_exit = v_0_
end
local on_quit
do
  local v_0_
  do
    local v_0_0
    local function on_quit0()
      return log["close-hud"]()
    end
    v_0_0 = on_quit0
    _0_["on-quit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-quit"] = v_0_
  on_quit = v_0_
end
local init
do
  local v_0_
  do
    local v_0_0
    local function init0(filetypes)
      nvim.ex.augroup("conjure_init_filetypes")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
      nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
      nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
      nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
      nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
      nvim.ex.autocmd("VimLeavePre", "*", bridge["viml->lua"]("conjure.log", "clear-close-hud-passive-timer", {}))
      nvim.ex.autocmd("ExitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-exit" .. "']()"))
      nvim.ex.autocmd("QuitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-quit" .. "']()"))
      return nvim.ex.augroup("END")
    end
    v_0_0 = init0
    _0_["init"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["init"] = v_0_
  init = v_0_
end
local eval_ranged_command
do
  local v_0_
  do
    local v_0_0
    local function eval_ranged_command0(start, _end, code)
      if ("" == code) then
        return eval.range(a.dec(start), _end)
      else
        return eval.command(code)
      end
    end
    v_0_0 = eval_ranged_command0
    _0_["eval-ranged-command"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["eval-ranged-command"] = v_0_
  eval_ranged_command = v_0_
end
local connect_command
do
  local v_0_
  do
    local v_0_0
    local function connect_command0(...)
      local args = {...}
      local function _3_(...)
        if (1 == a.count(args)) then
          return {port = a.first(args)}
        else
          return {host = a.first(args), port = a.second(args)}
        end
      end
      return client.call("connect", _3_(...))
    end
    v_0_0 = connect_command0
    _0_["connect-command"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["connect-command"] = v_0_
  connect_command = v_0_
end
local client_state_command
do
  local v_0_
  do
    local v_0_0
    local function client_state_command0(state_key)
      if state_key then
        return client["set-state-key!"](state_key)
      else
        return a.println(client["state-key"]())
      end
    end
    v_0_0 = client_state_command0
    _0_["client-state-command"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["client-state-command"] = v_0_
  client_state_command = v_0_
end
local omnifunc
do
  local v_0_
  do
    local v_0_0
    local function omnifunc0(find_start_3f, base)
      if find_start_3f then
        local _let_0_ = nvim.win_get_cursor(0)
        local row = _let_0_[1]
        local col = _let_0_[2]
        local _let_1_ = nvim.buf_get_lines(0, a.dec(row), row, false)
        local line = _let_1_[1]
        return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
      else
        return eval["completions-sync"](base)
      end
    end
    v_0_0 = omnifunc0
    _0_["omnifunc"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["omnifunc"] = v_0_
  omnifunc = v_0_
end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
nvim.ex.command_("-nargs=? -range ConjureEval", bridge["viml->lua"]("conjure.mapping", "eval-ranged-command", {args = "<line1>, <line2>, <q-args>"}))
nvim.ex.command_("-nargs=* -range -complete=file ConjureConnect", bridge["viml->lua"]("conjure.mapping", "connect-command", {args = "<f-args>"}))
nvim.ex.command_("-nargs=* ConjureClientState", bridge["viml->lua"]("conjure.mapping", "client-state-command", {args = "<f-args>"}))
return nvim.ex.command_("ConjureSchool", bridge["viml->lua"]("conjure.school", "start", {}))