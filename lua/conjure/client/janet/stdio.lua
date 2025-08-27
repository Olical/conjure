-- [nfnl] fnl/conjure/client/janet/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.janet.stdio")
config.merge({client = {janet = {stdio = {mapping = {start = "cs", stop = "cS"}, command = "janet -n -s", prompt_pattern = "repl:[0-9]+:[^>]*> "}}}})
local cfg = config["get-in-fn"]({"client", "janet", "stdio"})
local state
local function _2_()
  return {repl = nil}
end
state = client["new-state"](_2_)
M["buf-suffix"] = ".janet"
M["comment-prefix"] = "# "
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running")})
  end
end
M.unbatch = function(msgs)
  local function _4_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return {out = str.join("", core.map(_4_, msgs))}
end
local function format_message(msg)
  local function _5_(_241)
    return ("" ~= _241)
  end
  return core.filter(_5_, str.split(msg.out, "\n"))
end
local function prep_code(s)
  return (s .. "\n")
end
M["eval-str"] = function(opts)
  local function _6_(repl)
    local function _7_(msgs)
      local lines = format_message(M.unbatch(msgs))
      if opts["on-result"] then
        opts["on-result"](core.last(lines))
      else
      end
      return log.append(lines)
    end
    return repl.send(prep_code(opts.code), _7_, {["batch?"] = true})
  end
  return with_repl_or_warn(_6_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
M["doc-str"] = function(opts)
  local function _9_(_241)
    return ("(doc " .. _241 .. ")")
  end
  return M["eval-str"](core.update(opts, "code", _9_))
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(M["comment-prefix"] .. core["pr-str"](core["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
M.stop = function()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return core.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M.start = function()
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _12_()
      return display_repl_status("started")
    end
    local function _13_(err)
      return display_repl_status(err)
    end
    local function _14_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with signal " .. signal)})
      else
      end
      return M.stop()
    end
    local function _17_(msg)
      return log.append(format_message(msg))
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _13_, ["on-exit"] = _14_, ["on-stray-output"] = _17_}))
  end
end
M["on-load"] = function()
  return M.start()
end
M["on-filetype"] = function()
  local function _19_()
    return M.start()
  end
  mapping.buf("JanetStart", cfg({"mapping", "start"}), _19_, {desc = "Start the REPL"})
  local function _20_()
    return M.stop()
  end
  return mapping.buf("JanetStop", cfg({"mapping", "stop"}), _20_, {desc = "Stop the REPL"})
end
M["on-exit"] = function()
  return M.stop()
end
return M
