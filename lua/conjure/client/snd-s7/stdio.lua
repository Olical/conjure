local _2afile_2a = "fnl/conjure/client/snd-s7/stdio.fnl"
local _2amodule_name_2a = "conjure.client.snd-s7.stdio"
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
local a, client, config, log, mapping, nvim, stdio, str, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio-rt"), autoload("conjure.aniseed.string"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["_"] = _
config.merge({client = {["snd-s7"] = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}, command = "snd", prompt_pattern = "> "}}}})
local cfg = config["get-in-fn"]({"client", "snd-s7", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _1_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local buf_suffix = ".scm"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function format_message(msg)
  return str.split((msg.out or msg.err), "\n")
end
_2amodule_locals_2a["format-message"] = format_message
local function remove_blank_lines(msg)
  local function _3_(_241)
    return not ("" == _241)
  end
  return a.filter(_3_, format_message(msg))
end
_2amodule_locals_2a["remove-blank-lines"] = remove_blank_lines
local function display_result(msg)
  return log.append(remove_blank_lines(msg))
end
_2amodule_locals_2a["display-result"] = display_result
local function __3elist(s)
  if a.first(s) then
    return s
  else
    return {s}
  end
end
_2amodule_2a["->list"] = __3elist
local function eval_str(opts)
  local function _5_(repl)
    local function _6_(msgs)
      local msgs0 = __3elist(msgs)
      if opts["on-result"] then
        opts["on-result"](str.join("\n", remove_blank_lines(a.last(msgs0))))
      else
      end
      return a["run!"](display_result, msgs0)
    end
    return repl.send((opts.code .. "\n"), _6_, {["batch?"] = false})
  end
  return with_repl_or_warn(_5_)
end
_2amodule_2a["eval-str"] = eval_str
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
_2amodule_2a["eval-file"] = eval_file
local function interrupt()
  local function _8_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_8_)
end
_2amodule_2a["interrupt"] = interrupt
local function display_repl_status(status)
  return log.append({(comment_prefix .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
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
    local function _10_()
      return display_repl_status("started")
    end
    local function _11_(err)
      return display_repl_status(err)
    end
    local function _12_(code, signal)
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
    local function _15_(msg)
      return log.append(__fnl_global__format_2dmsg(msg))
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _10_, ["on-error"] = _11_, ["on-exit"] = _12_, ["on-stray-output"] = _15_}))
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
local function on_filetype()
  mapping.buf("SndStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("SndStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("SdnInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the REPL"})
end
_2amodule_2a["on-filetype"] = on_filetype
return _2amodule_2a