-- [nfnl] fnl/conjure/client/scheme/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local cmpl = autoload("conjure.client.scheme.completions")
local M = define("conjure.client.scheme.stdio")
local M0 = define("conjure.client.scheme.stdio")
config.merge({client = {scheme = {stdio = {command = "mit-scheme", prompt_pattern = "[%]e][=r]r?o?r?> ", value_prefix_pattern = "^;Value: ", enable_completions = true}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {scheme = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "scheme", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local function completions_enabled_3f()
  return cfg({"enable_completions"})
end
M0["buf-suffix"] = ".scm"
M0["comment-prefix"] = "; "
M0["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
M0["valid-str?"] = function(code)
  return ts["valid-str?"]("scheme", code)
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M0["comment-prefix"] .. "No REPL running")})
  end
end
M0.unbatch = function(msgs)
  local function _5_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return {out = str.join("", a.map(_5_, msgs))}
end
M0["format-msg"] = function(msg)
  local function _6_(_241)
    return not str["blank?"](_241)
  end
  local function _7_(line)
    if not cfg({"value_prefix_pattern"}) then
      return line
    elseif string.match(line, cfg({"value_prefix_pattern"})) then
      return string.gsub(line, cfg({"value_prefix_pattern"}), "")
    else
      return (M0["comment-prefix"] .. "(out) " .. line)
    end
  end
  return a.filter(_6_, a.map(_7_, str.split(string.gsub(string.gsub(a.get(msg, "out"), "^%s*", ""), "%s+%d+%s*$", ""), "\n")))
end
M0["eval-str"] = function(opts)
  local function _9_(repl)
    if M0["valid-str?"](opts.code) then
      local function _10_(msgs)
        local msgs0 = M0["format-msg"](M0.unbatch(msgs))
        opts["on-result"](a.last(msgs0))
        return log.append(msgs0)
      end
      return repl.send((opts.code .. "\n"), _10_, {["batch?"] = true})
    else
      return log.append({(M0["comment-prefix"] .. "eval error: could not parse form")})
    end
  end
  return with_repl_or_warn(_9_)
end
M0["eval-file"] = function(opts)
  return M0["eval-str"](a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function display_repl_status(status)
  return log.append({(M0["comment-prefix"] .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
M0.stop = function()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M0.start = function()
  if state("repl") then
    return log.append({(M0["comment-prefix"] .. "Can't start, REPL is already running."), (M0["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _13_()
      if completions_enabled_3f() then
        cmpl["get-completions"]()
      else
      end
      return display_repl_status("started")
    end
    local function _15_(err)
      return display_repl_status(err)
    end
    local function _16_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(M0["comment-prefix"] .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(M0["comment-prefix"] .. "process exited with signal " .. signal)})
      else
      end
      return M0.stop()
    end
    local function _19_(msg)
      return log.append(M0["format-msg"](msg))
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _13_, ["on-error"] = _15_, ["on-exit"] = _16_, ["on-stray-output"] = _19_}))
  end
end
M0.interrupt = function()
  local function _21_(repl)
    log.append({(M0["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_21_)
end
M0["on-load"] = function()
  return M0.start()
end
M0["on-filetype"] = function()
  mapping.buf("SchemeStart", cfg({"mapping", "start"}), M0.start, {desc = "Start the REPL"})
  mapping.buf("SchemeStop", cfg({"mapping", "stop"}), M0.stop, {desc = "Stop the REPL"})
  return mapping.buf("SchemeInterrupt", cfg({"mapping", "interrupt"}), M0.interrupt, {desc = "Interrupt the REPL"})
end
M0["on-exit"] = function()
  return M0.stop()
end
M0.completions = function(opts)
  if completions_enabled_3f() then
    local prefix = (opts.prefix or "")
    local suggestions = cmpl["get-completions"](prefix)
    return opts.cb(suggestions)
  else
    return opts.cb({})
  end
end
return M0
