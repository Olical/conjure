-- [nfnl] fnl/conjure/client/fennel/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local afs = autoload("conjure.nfnl.fs")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.fennel.stdio", {["buf-suffix"] = ".fnl", ["comment-prefix"] = "; ", ["form-node?"] = ts["node-surrounded-by-form-pair-chars?"], ["comment-node?"] = ts["lisp-comment-node?"]})
config.merge({client = {fennel = {stdio = {command = "fennel", prompt_pattern = ">> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {fennel = {stdio = {mapping = {start = "cs", stop = "cS", eval_reload = "eF"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "fennel", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running")})
  end
end
local function format_message(msg)
  return str.split((msg.out or msg.err), "\n")
end
local function display_result(msg)
  local function _5_(_241)
    return not ("" == _241)
  end
  return log.append(core.filter(_5_, format_message(msg)))
end
M["eval-str"] = function(opts)
  local function _6_(repl)
    local function _7_(msgs)
      if ((1 == core.count(msgs)) and ("" == core["get-in"](msgs, {1, "out"}))) then
        core["assoc-in"](msgs, {1, "out"}, (M["comment-prefix"] .. "Empty result."))
      else
      end
      local msgs0
      local function _9_(_241)
        return (".." ~= _241.out)
      end
      msgs0 = core.filter(_9_, msgs)
      if opts["on-result"] then
        opts["on-result"](str.join("\n", format_message(core.last(msgs0))))
      else
      end
      return core["run!"](display_result, msgs0)
    end
    return repl.send((opts.code .. "\n"), _7_, {["batch?"] = true})
  end
  return with_repl_or_warn(_6_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
M["eval-reload"] = function()
  local file_path = vim.fn.expand("%")
  local relative_no_suf = vim.fn.fnamemodify(file_path, ":.:r")
  local module_path = string.gsub(relative_no_suf, afs["path-sep"], ".")
  log.append({(M["comment-prefix"] .. ",reload " .. module_path)}, {["break?"] = true})
  return M["eval-str"]({action = "eval", origin = "reload", ["file-path"] = file_path, code = (",reload " .. module_path)})
end
M["doc-str"] = function(opts)
  local function _11_(_241)
    return (",doc " .. _241 .. "\n")
  end
  return M["eval-str"](core.update(opts, "code", _11_))
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
    local function _14_()
      return display_repl_status("started")
    end
    local function _15_(err)
      return display_repl_status(err)
    end
    local function _16_(code, signal)
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
    local function _19_(msg)
      return display_result(msg)
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _14_, ["on-error"] = _15_, ["on-exit"] = _16_, ["on-stray-output"] = _19_}))
  end
end
M["on-load"] = function()
  return M.start()
end
M["on-exit"] = function()
  return M.stop()
end
M["on-filetype"] = function()
  local function _21_()
    return M.start()
  end
  mapping.buf("FnlStart", cfg({"mapping", "start"}), _21_, {desc = "Start the REPL"})
  local function _22_()
    return M.stop()
  end
  mapping.buf("FnlStop", cfg({"mapping", "stop"}), _22_, {desc = "Stop the REPL"})
  local function _23_()
    return M["eval-reload"]()
  end
  return mapping.buf("FnlEvalReload", cfg({"mapping", "eval_reload"}), _23_, {desc = "Use ,reload on the file"})
end
return M
