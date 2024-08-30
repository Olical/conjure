-- [nfnl] Compiled from fnl/conjure/client/hy/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local extract = autoload("conjure.extract")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
config.merge({client = {hy = {stdio = {eval = {raw_out = false}, command = "hy -iu -c=\"Ready!\"", prompt_pattern = "=> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {hy = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "hy", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local buf_suffix = ".hy"
local comment_prefix = "; "
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_result(msg)
  local prefix
  if (true == cfg({"eval", "raw_out"})) then
    prefix = ""
  else
    local _5_
    if msg.err then
      _5_ = "(err)"
    else
      _5_ = "(out)"
    end
    prefix = (comment_prefix .. _5_ .. " ")
  end
  local function _8_(_241)
    return (prefix .. _241)
  end
  local function _9_(_241)
    return ("" ~= _241)
  end
  return log.append(a.map(_8_, a.filter(_9_, str.split((msg.err or msg.out), "\n"))))
end
local function prep_code(s)
  return (s .. "\n")
end
local function eval_str(opts)
  local last_value = nil
  local function _10_(repl)
    local function _11_(msg)
      log.dbg("msg", msg)
      local msgs
      local function _12_(_241)
        return not ("" == _241)
      end
      msgs = a.filter(_12_, str.split((msg.err or msg.out), "\n"))
      last_value = (a.last(msgs) or last_value)
      display_result(msg)
      if msg["done?"] then
        log.append({""})
        if opts["on-result"] then
          return opts["on-result"](last_value)
        else
          return nil
        end
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _11_)
  end
  return with_repl_or_warn(_10_)
end
local function eval_file(opts)
  return log.append({(comment_prefix .. "Not implemented")})
end
local function doc_str(opts)
  local obj
  if ("." == string.sub(opts.code, 1, 1)) then
    obj = extract.prompt("Specify object or module: ")
  else
    obj = nil
  end
  local obj0 = ((obj or "") .. opts.code)
  local code = ("(if (in (mangle '" .. obj0 .. ") --macros--)\n                    (doc " .. obj0 .. ")\n                    (help " .. obj0 .. "))")
  local function _16_(repl)
    local function _17_(msg)
      local _18_
      if msg.err then
        _18_ = "(err) "
      else
        _18_ = "(doc) "
      end
      return log.append(text["prefixed-lines"]((msg.err or msg.out), (comment_prefix .. _18_)))
    end
    return repl.send(prep_code(code), _17_)
  end
  return with_repl_or_warn(_16_)
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
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
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _22_()
      display_repl_status("started")
      local function _23_(repl)
        return repl.send(prep_code("(import sys) (setv sys.ps2 \"\") (del sys)"))
      end
      return with_repl_or_warn(_23_)
    end
    local function _24_(err)
      return display_repl_status(err)
    end
    local function _25_(code, signal)
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
    local function _28_(msg)
      return display_result(msg)
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _22_, ["on-error"] = _24_, ["on-exit"] = _25_, ["on-stray-output"] = _28_}))
  end
end
local function on_load()
  return start()
end
local function on_exit()
  return stop()
end
local function interrupt()
  log.dbg("sending interrupt message", "")
  local function _30_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_30_)
end
local function on_filetype()
  mapping.buf("HyStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("HyStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("HyInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the current evaluation"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, ["eval-str"] = eval_str, ["eval-file"] = eval_file, ["doc-str"] = doc_str, stop = stop, start = start, ["on-load"] = on_load, ["on-exit"] = on_exit, interrupt = interrupt, ["on-filetype"] = on_filetype}
