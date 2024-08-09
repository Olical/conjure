-- [nfnl] Compiled from fnl/conjure/client/hy/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.hy.stdio"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, client, config, extract, log, mapping, nvim, stdio, str, text, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["_"] = _
config.merge({client = {hy = {stdio = {eval = {raw_out = false}, command = "hy -iu -c=\"Ready!\"", prompt_pattern = "=> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {hy = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "hy", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
do local _ = {nil, nil} end
local state
local function _2_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_2_))
do end (_2amodule_locals_2a)["state"] = state
do local _ = {nil, nil} end
local buf_suffix = ".hy"
_2amodule_2a["buf-suffix"] = buf_suffix
do local _ = {nil, nil} end
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
do local _ = {nil, nil} end
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
do local _ = {nil, nil} end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
do local _ = {with_repl_or_warn, nil} end
local function display_result(msg)
  local prefix
  if (true == cfg({"eval", "raw_out"})) then
    prefix = ""
  else
    local function _4_()
      if msg.err then
        return "(err)"
      else
        return "(out)"
      end
    end
    prefix = (comment_prefix .. _4_() .. " ")
  end
  local function _6_(_241)
    return (prefix .. _241)
  end
  local function _7_(_241)
    return ("" ~= _241)
  end
  return log.append(a.map(_6_, a.filter(_7_, str.split((msg.err or msg.out), "\n"))))
end
_2amodule_locals_2a["display-result"] = display_result
do local _ = {display_result, nil} end
local function prep_code(s)
  return (s .. "\n")
end
_2amodule_locals_2a["prep-code"] = prep_code
do local _ = {prep_code, nil} end
local function eval_str(opts)
  local last_value = nil
  local function _8_(repl)
    local function _9_(msg)
      log.dbg("msg", msg)
      local msgs
      local function _10_(_241)
        return not ("" == _241)
      end
      msgs = a.filter(_10_, str.split((msg.err or msg.out), "\n"))
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
    return repl.send(prep_code(opts.code), _9_)
  end
  return with_repl_or_warn(_8_)
end
_2amodule_2a["eval-str"] = eval_str
do local _ = {eval_str, nil} end
local function eval_file(opts)
  return log.append({(comment_prefix .. "Not implemented")})
end
_2amodule_2a["eval-file"] = eval_file
do local _ = {eval_file, nil} end
local function doc_str(opts)
  local obj
  if ("." == string.sub(opts.code, 1, 1)) then
    obj = extract.prompt("Specify object or module: ")
  else
    obj = nil
  end
  local obj0 = ((obj or "") .. opts.code)
  local code = ("(if (in (mangle '" .. obj0 .. ") --macros--)\n                    (doc " .. obj0 .. ")\n                    (help " .. obj0 .. "))")
  local function _14_(repl)
    local function _15_(msg)
      local function _16_()
        if msg.err then
          return "(err) "
        else
          return "(doc) "
        end
      end
      return log.append(text["prefixed-lines"]((msg.err or msg.out), (comment_prefix .. _16_())))
    end
    return repl.send(prep_code(code), _15_)
  end
  return with_repl_or_warn(_14_)
end
_2amodule_2a["doc-str"] = doc_str
do local _ = {doc_str, nil} end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
do local _ = {display_repl_status, nil} end
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
do local _ = {stop, nil} end
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _19_()
      display_repl_status("started")
      local function _20_(repl)
        return repl.send(prep_code("(import sys) (setv sys.ps2 \"\") (del sys)"))
      end
      return with_repl_or_warn(_20_)
    end
    local function _21_(err)
      return display_repl_status(err)
    end
    local function _22_(code, signal)
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
    local function _25_(msg)
      return display_result(msg)
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _19_, ["on-error"] = _21_, ["on-exit"] = _22_, ["on-stray-output"] = _25_}))
  end
end
_2amodule_2a["start"] = start
do local _ = {start, nil} end
local function on_load()
  return start()
end
_2amodule_2a["on-load"] = on_load
do local _ = {on_load, nil} end
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit
do local _ = {on_exit, nil} end
local function interrupt()
  log.dbg("sending interrupt message", "")
  local function _27_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_27_)
end
_2amodule_2a["interrupt"] = interrupt
do local _ = {interrupt, nil} end
local function on_filetype()
  mapping.buf("HyStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("HyStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("HyInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the current evaluation"})
end
_2amodule_2a["on-filetype"] = on_filetype
do local _ = {on_filetype, nil} end
return _2amodule_2a
