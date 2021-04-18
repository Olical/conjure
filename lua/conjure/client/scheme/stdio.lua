local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.scheme.stdio"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.remote.stdio"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local client = _local_0_[2]
local config = _local_0_[3]
local log = _local_0_[4]
local mapping = _local_0_[5]
local nvim = _local_0_[6]
local stdio = _local_0_[7]
local str = _local_0_[8]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.scheme.stdio"
do local _ = ({nil, _0_0, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {scheme = {stdio = {command = "mit-scheme", mapping = {start = "cs", stop = "cS"}, prompt_pattern = "[%]e][=r]r?o?r?> "}}}})
local cfg = config["get-in-fn"]({"client", "scheme", "stdio"})
local state
local function _1_()
  return {repl = nil}
end
state = client["new-state"](_1_)
local buf_suffix
do
  local v_0_ = ".scm"
  _0_0["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix
do
  local v_0_ = "; "
  _0_0["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local unbatch
do
  local v_0_
  local function unbatch0(msgs)
    local function _2_(_241)
      return (a.get(_241, "out") or a.get(_241, "err"))
    end
    return {out = str.join("", a.map(_2_, msgs))}
  end
  v_0_ = unbatch0
  _0_0["unbatch"] = v_0_
  unbatch = v_0_
end
local format_msg
do
  local v_0_
  local function format_msg0(msg)
    local function _2_(_241)
      if string.match(_241, "^;Value: ") then
        return string.gsub(_241, "^;Value: ", "")
      else
        return (comment_prefix .. "(out) " .. _241)
      end
    end
    return a.map(_2_, str.split(string.gsub(string.gsub(a.get(msg, "out"), "^%s*", ""), "%s+%d+%s*$", ""), "\n"))
  end
  v_0_ = format_msg0
  _0_0["format-msg"] = v_0_
  format_msg = v_0_
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    local function _2_(repl)
      local function _3_(msgs)
        local msgs0 = format_msg(unbatch(msgs))
        opts["on-result"](a.last(msgs0))
        return log.append(msgs0)
      end
      return repl.send((opts.code .. "\n"), _3_, {["batch?"] = true})
    end
    return with_repl_or_warn(_2_)
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local eval_file
do
  local v_0_
  local function eval_file0(opts)
    return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local function display_repl_status(status)
  return log.append({(comment_prefix .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
local stop
do
  local v_0_
  local function stop0()
    local repl = state("repl")
    if repl then
      repl.destroy()
      display_repl_status("stopped")
      return a.assoc(state(), "repl", nil)
    end
  end
  v_0_ = stop0
  _0_0["stop"] = v_0_
  stop = v_0_
end
local start
do
  local v_0_
  local function start0()
    if state("repl") then
      return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
    else
      local function _2_(err)
        return display_repl_status(err)
      end
      local function _3_(code, signal)
        if (("number" == type(code)) and (code > 0)) then
          log.append({(comment_prefix .. "process exited with code " .. code)})
        end
        if (("number" == type(signal)) and (signal > 0)) then
          log.append({(comment_prefix .. "process exited with signal " .. signal)})
        end
        return stop()
      end
      local function _4_(msg)
        return log.append(format_msg(msg))
      end
      local function _5_()
        return display_repl_status("started")
      end
      return a.assoc(state(), "repl", stdio.start({["on-error"] = _2_, ["on-exit"] = _3_, ["on-stray-output"] = _4_, ["on-success"] = _5_, ["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"})}))
    end
  end
  v_0_ = start0
  _0_0["start"] = v_0_
  start = v_0_
end
local on_load
do
  local v_0_
  local function on_load0()
    return start()
  end
  v_0_ = on_load0
  _0_0["on-load"] = v_0_
  on_load = v_0_
end
local on_filetype
do
  local v_0_
  local function on_filetype0()
    mapping.buf("n", "SchemeStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
    return mapping.buf("n", "SchemeStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
  end
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_exit
do
  local v_0_
  local function on_exit0()
    return stop()
  end
  v_0_ = on_exit0
  _0_0["on-exit"] = v_0_
  on_exit = v_0_
end
return nil