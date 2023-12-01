-- [nfnl] Compiled from fnl/conjure/client/scheme/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.scheme.stdio"
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
local a, client, config, log, mapping, nvim, stdio, str, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.tree-sitter"), nil
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
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
config.merge({client = {scheme = {stdio = {command = "mit-scheme", prompt_pattern = "[%]e][=r]r?o?r?> ", value_prefix_pattern = "^;Value: "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {scheme = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "scheme", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
do local _ = {nil, nil} end
local state
local function _2_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_2_))
do end (_2amodule_locals_2a)["state"] = state
do local _ = {nil, nil} end
local buf_suffix = ".scm"
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
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
do local _ = {with_repl_or_warn, nil} end
local function unbatch(msgs)
  local function _4_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return {out = str.join("", a.map(_4_, msgs))}
end
_2amodule_2a["unbatch"] = unbatch
do local _ = {unbatch, nil} end
local function format_msg(msg)
  local function _5_(_241)
    return not str["blank?"](_241)
  end
  local function _6_(line)
    if not cfg({"value_prefix_pattern"}) then
      return line
    elseif string.match(line, cfg({"value_prefix_pattern"})) then
      return string.gsub(line, cfg({"value_prefix_pattern"}), "")
    else
      return (comment_prefix .. "(out) " .. line)
    end
  end
  return a.filter(_5_, a.map(_6_, str.split(string.gsub(string.gsub(a.get(msg, "out"), "^%s*", ""), "%s+%d+%s*$", ""), "\n")))
end
_2amodule_2a["format-msg"] = format_msg
do local _ = {format_msg, nil} end
local function eval_str(opts)
  local function _8_(repl)
    local function _9_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      opts["on-result"](a.last(msgs0))
      return log.append(msgs0)
    end
    return repl.send((opts.code .. "\n"), _9_, {["batch?"] = true})
  end
  return with_repl_or_warn(_8_)
end
_2amodule_2a["eval-str"] = eval_str
do local _ = {eval_str, nil} end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
_2amodule_2a["eval-file"] = eval_file
do local _ = {eval_file, nil} end
local function display_repl_status(status)
  return log.append({(comment_prefix .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
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
    local function _11_()
      return display_repl_status("started")
    end
    local function _12_(err)
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
      return log.append(format_msg(msg))
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _11_, ["on-error"] = _12_, ["on-exit"] = _13_, ["on-stray-output"] = _16_}))
  end
end
_2amodule_2a["start"] = start
do local _ = {start, nil} end
local function interrupt()
  local function _18_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_18_)
end
_2amodule_2a["interrupt"] = interrupt
do local _ = {interrupt, nil} end
local function on_load()
  return start()
end
_2amodule_2a["on-load"] = on_load
do local _ = {on_load, nil} end
local function on_filetype()
  mapping.buf("SchemeStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("SchemeStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("SchemeInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the REPL"})
end
_2amodule_2a["on-filetype"] = on_filetype
do local _ = {on_filetype, nil} end
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit
do local _ = {on_exit, nil} end
return _2amodule_2a
