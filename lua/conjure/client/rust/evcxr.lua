local _2afile_2a = "fnl/conjure/client/rust/evcxr.fnl"
local _2amodule_name_2a = "conjure.client.rust.evcxr"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, client, config, log, nvim, promise, stdio, str = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.promise"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["promise"] = promise
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
local buf_suffix = ".rs"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "// "
_2amodule_2a["comment-prefix"] = comment_prefix
config.merge({client = {rust = {evcxr = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}, command = "evcxr", prompt_pattern = ">> "}}}})
local cfg = config["get-in-fn"]({"client", "rust", "evcxr"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _1_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return log.append({status})
  end
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
local function display_result(msg)
  local function _4_(_241)
    return (comment_prefix .. _241)
  end
  return log.append(a.map(_4_, msg))
end
_2amodule_locals_2a["display-result"] = display_result
local function format_msg(msg)
  local function _5_(_241)
    return not ("()" == _241)
  end
  local function _6_(_241)
    return not ("" == _241)
  end
  return a.filter(_5_, a.filter(_6_, str.split(msg, "\n")))
end
_2amodule_locals_2a["format-msg"] = format_msg
local function unbatch(msgs)
  local function _7_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_7_, msgs))
end
_2amodule_locals_2a["unbatch"] = unbatch
local function prep_code(s)
  return (s .. "\n")
end
_2amodule_locals_2a["prep-code"] = prep_code
local function stop()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
_2amodule_2a["stop"] = stop
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _9_()
      display_repl_status("started")
      local function _10_(repl)
        local function _11_(msgs)
          return display_result(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code(":help"), _11_, {["batch?"] = true})
      end
      return with_repl_or_warn(_10_)
    end
    local function _12_(err)
      log.append({"error"})
      return display_repl_status(err)
    end
    local function _13_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(comment_prefix .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(comment_prefix .. "process exited with signal " .. signal)})
      else
      end
      return stop()
    end
    local function _16_(msg)
      return display_result(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _9_, ["on-error"] = _12_, ["on-exit"] = _13_, ["on-stray-output"] = _16_}))
  end
end
_2amodule_2a["start"] = start
local function on_load()
  return start()
end
_2amodule_2a["on-load"] = on_load
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit
local function interrupt()
  local function _18_(repl)
    local uv = vim.loop
    return uv.kill(repl.pid, uv.constants.SIGINT)
  end
  return with_repl_or_warn(_18_)
end
_2amodule_2a["interrupt"] = interrupt
local function eval_str(opts)
  local function _19_(repl)
    local function _20_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _20_, {["batch?"] = true})
  end
  return with_repl_or_warn(_19_)
end
_2amodule_2a["eval-str"] = eval_str
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
_2amodule_2a["eval-file"] = eval_file
return _2amodule_2a