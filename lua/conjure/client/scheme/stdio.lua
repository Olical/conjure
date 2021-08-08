local _2afile_2a = "fnl/conjure/client/scheme/stdio.fnl"
local _1_
do
  local name_4_auto = "conjure.client.scheme.stdio"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", stdio = "conjure.remote.stdio", str = "conjure.aniseed.string"}}
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
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.scheme.stdio"
do local _ = ({nil, _1_, nil, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {scheme = {stdio = {command = "mit-scheme", mapping = {start = "cs", stop = "cS"}, prompt_pattern = "[%]e][=r]r?o?r?> "}}}})
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "scheme", "stdio"})
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
    local v_25_auto = ".scm"
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
local unbatch
do
  local v_23_auto
  do
    local v_25_auto
    local function unbatch0(msgs)
      local function _10_(_241)
        return (a.get(_241, "out") or a.get(_241, "err"))
      end
      return {out = str.join("", a.map(_10_, msgs))}
    end
    v_25_auto = unbatch0
    _1_["unbatch"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["unbatch"] = v_23_auto
  unbatch = v_23_auto
end
local format_msg
do
  local v_23_auto
  do
    local v_25_auto
    local function format_msg0(msg)
      local function _11_(_241)
        if string.match(_241, "^;Value: ") then
          return string.gsub(_241, "^;Value: ", "")
        else
          return (comment_prefix .. "(out) " .. _241)
        end
      end
      return a.map(_11_, str.split(string.gsub(string.gsub(a.get(msg, "out"), "^%s*", ""), "%s+%d+%s*$", ""), "\n"))
    end
    v_25_auto = format_msg0
    _1_["format-msg"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["format-msg"] = v_23_auto
  format_msg = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      local function _13_(repl)
        local function _14_(msgs)
          local msgs0 = format_msg(unbatch(msgs))
          opts["on-result"](a.last(msgs0))
          return log.append(msgs0)
        end
        return repl.send((opts.code .. "\n"), _14_, {["batch?"] = true})
      end
      return with_repl_or_warn(_13_)
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
      return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local display_repl_status
do
  local v_23_auto
  local function display_repl_status0(status)
    return log.append({(comment_prefix .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
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
        local function _16_(err)
          return display_repl_status(err)
        end
        local function _17_(code, signal)
          if (("number" == type(code)) and (code > 0)) then
            log.append({(comment_prefix .. "process exited with code " .. code)})
          end
          if (("number" == type(signal)) and (signal > 0)) then
            log.append({(comment_prefix .. "process exited with signal " .. signal)})
          end
          return stop()
        end
        local function _20_(msg)
          return log.append(format_msg(msg))
        end
        local function _21_()
          return display_repl_status("started")
        end
        return a.assoc(state(), "repl", stdio.start({["on-error"] = _16_, ["on-exit"] = _17_, ["on-stray-output"] = _20_, ["on-success"] = _21_, ["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"})}))
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
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
    local function on_filetype0()
      mapping.buf("n", "SchemeStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
      return mapping.buf("n", "SchemeStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
    end
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
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
return nil