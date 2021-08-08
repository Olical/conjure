local _2afile_2a = "fnl/conjure/client/fennel/stdio.fnl"
local _1_
do
  local name_4_auto = "conjure.client.fennel.stdio"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", stdio = "conjure.remote.stdio", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local client = _local_4_[2]
local config = _local_4_[3]
local log = _local_4_[4]
local mapping = _local_4_[5]
local nvim = _local_4_[6]
local stdio = _local_4_[7]
local str = _local_4_[8]
local text = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.fennel.stdio"
do local _ = ({nil, _1_, nil, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {fennel = {stdio = {command = "fennel", mapping = {eval_reload = "eF", start = "cs", stop = "cS"}, prompt_pattern = ">> "}}}})
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "fennel", "stdio"})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
local state
do
  local v_23_auto
  local function _8_()
    return {repl = nil}
  end
  v_23_auto = ((_1_)["aniseed/locals"].state or client["new-state"](_8_))
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local buf_suffix
do
  local v_23_auto
  do
    local v_25_auto = ".fnl"
    _1_["buf-suffix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-suffix"] = v_23_auto
  buf_suffix = v_23_auto
end
local comment_prefix
do
  local v_23_auto
  do
    local v_25_auto = "; "
    _1_["comment-prefix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-prefix"] = v_23_auto
  comment_prefix = v_23_auto
end
local with_repl_or_warn
do
  local v_23_auto
  local function with_repl_or_warn0(f, opts)
    local repl = state("repl")
    if repl then
      return f(repl)
    else
      return log.append({(comment_prefix .. "No REPL running")})
    end
  end
  v_23_auto = with_repl_or_warn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-repl-or-warn"] = v_23_auto
  with_repl_or_warn = v_23_auto
end
local format_message
do
  local v_23_auto
  local function format_message0(msg)
    return str.split((msg.out or msg.err), "\n")
  end
  v_23_auto = format_message0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["format-message"] = v_23_auto
  format_message = v_23_auto
end
local display_result
do
  local v_23_auto
  local function display_result0(msg)
    local function _10_(_241)
      return not ("" == _241)
    end
    return log.append(a.filter(_10_, format_message(msg)))
  end
  v_23_auto = display_result0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-result"] = v_23_auto
  display_result = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      local function _11_(repl)
        local function _12_(msgs)
          if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
            a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result."))
          end
          local msgs0
          local function _14_(_241)
            return (".." ~= (_241).out)
          end
          msgs0 = a.filter(_14_, msgs)
          if opts["on-result"] then
            opts["on-result"](str.join("\n", format_message(a.last(msgs0))))
          end
          return a["run!"](display_result, msgs0)
        end
        return repl.send((opts.code .. "\n"), _12_, {["batch?"] = true})
      end
      return with_repl_or_warn(_11_)
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local eval_file
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_file0(opts)
      return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local eval_reload
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_reload0()
      local file_path = nvim.fn.expand("%")
      local module_path = nvim.fn.fnamemodify(file_path, ":.:r")
      log.append({(comment_prefix .. ",reload " .. module_path)}, {["break?"] = true})
      return eval_str({["file-path"] = file_path, action = "eval", code = (",reload " .. module_path), origin = "reload"})
    end
    v_25_auto = eval_reload0
    _1_["eval-reload"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-reload"] = v_23_auto
  eval_reload = v_23_auto
end
local doc_str
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_str0(opts)
      local function _16_(_241)
        return ("(doc " .. _241 .. ")\n")
      end
      return eval_str(a.update(opts, "code", _16_))
    end
    v_25_auto = doc_str0
    _1_["doc-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local display_repl_status
do
  local v_23_auto
  local function display_repl_status0(status)
    local repl = state("repl")
    if repl then
      return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
    end
  end
  v_23_auto = display_repl_status0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-repl-status"] = v_23_auto
  display_repl_status = v_23_auto
end
local stop
do
  local v_23_auto
  do
    local v_25_auto
    local function stop0()
      local repl = state("repl")
      if repl then
        repl.destroy()
        display_repl_status("stopped")
        return a.assoc(state(), "repl", nil)
      end
    end
    v_25_auto = stop0
    _1_["stop"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["stop"] = v_23_auto
  stop = v_23_auto
end
local start
do
  local v_23_auto
  do
    local v_25_auto
    local function start0()
      if state("repl") then
        return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
      else
        local function _19_(err)
          return display_repl_status(err)
        end
        local function _20_(code, signal)
          if (("number" == type(code)) and (code > 0)) then
            log.append({(comment_prefix .. "process exited with code " .. code)})
          end
          if (("number" == type(signal)) and (signal > 0)) then
            log.append({(comment_prefix .. "process exited with signal " .. signal)})
          end
          return stop()
        end
        local function _23_(msg)
          return display_result(msg)
        end
        local function _24_()
          return display_repl_status("started")
        end
        return a.assoc(state(), "repl", stdio.start({["on-error"] = _19_, ["on-exit"] = _20_, ["on-stray-output"] = _23_, ["on-success"] = _24_, ["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"})}))
      end
    end
    v_25_auto = start0
    _1_["start"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["start"] = v_23_auto
  start = v_23_auto
end
local on_load
do
  local v_23_auto
  do
    local v_25_auto
    local function on_load0()
      return start()
    end
    v_25_auto = on_load0
    _1_["on-load"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-load"] = v_23_auto
  on_load = v_23_auto
end
local on_exit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_exit0()
      return stop()
    end
    v_25_auto = on_exit0
    _1_["on-exit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-exit"] = v_23_auto
  on_exit = v_23_auto
end
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
    local function on_filetype0()
      mapping.buf("n", "FnlStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
      mapping.buf("n", "FnlStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
      return mapping.buf("n", "FnlEvalReload", cfg({"mapping", "eval_reload"}), _2amodule_name_2a, "eval-reload")
    end
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
end
return nil