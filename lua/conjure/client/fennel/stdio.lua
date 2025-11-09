-- [nfnl] fnl/conjure/client/fennel/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local nfs = autoload("conjure.nfnl.fs")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local vim = _G.vim
local M = define("conjure.client.fennel.stdio")
M["buf-suffix"] = ".fnl"
M["comment-prefix"] = "; "
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
M["comment-node?"] = ts["lisp-comment-node?"]
config.merge({client = {fennel = {stdio = {command = "fennel", prompt_pattern = ">> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {fennel = {stdio = {mapping = {start = "cs", stop = "cS", eval_reload = "eF"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "fennel", "stdio"})
local or_3_ = M.state
if not or_3_ then
  local function _4_()
    return {repl = nil}
  end
  or_3_ = client["new-state"](_4_)
end
M.state = or_3_
local function with_repl_or_warn(f, _opts)
  local repl = M.state("repl")
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
  local function _6_(_241)
    return not ("" == _241)
  end
  return log.append(core.filter(_6_, format_message(msg)))
end
M["eval-str"] = function(opts)
  local function _7_(repl)
    local function _8_(msgs)
      if ((1 == core.count(msgs)) and ("" == core["get-in"](msgs, {1, "out"}))) then
        core["assoc-in"](msgs, {1, "out"}, (M["comment-prefix"] .. "Empty result."))
      else
      end
      local msgs0
      local function _10_(_241)
        return (".." ~= _241.out)
      end
      msgs0 = core.filter(_10_, msgs)
      if opts["on-result"] then
        opts["on-result"](str.join("\n", format_message(core.last(msgs0))))
      else
      end
      return core["run!"](display_result, msgs0)
    end
    return repl.send((opts.code .. "\n"), _8_, {["batch?"] = true})
  end
  return with_repl_or_warn(_7_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
M["eval-reload"] = function()
  local file_path = vim.fn.expand("%")
  local relative_no_suf = vim.fn.fnamemodify(file_path, ":.:r")
  local module_path = string.gsub(relative_no_suf, nfs["path-sep"](), ".")
  log.append({(M["comment-prefix"] .. ",reload " .. module_path)}, {["break?"] = true})
  return M["eval-str"]({action = "eval", origin = "reload", ["file-path"] = file_path, code = (",reload " .. module_path)})
end
M["doc-str"] = function(opts)
  local function _12_(_241)
    return (",doc " .. _241 .. "\n")
  end
  return M["eval-str"](core.update(opts, "code", _12_))
end
local function display_repl_status(status)
  local repl = M.state("repl")
  if repl then
    return log.append({(M["comment-prefix"] .. core["pr-str"](core["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
M.stop = function()
  local repl = M.state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return core.assoc(M.state(), "repl", nil)
  else
    return nil
  end
end
M.start = function()
  if M.state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _15_()
      return display_repl_status("started")
    end
    local function _16_(err)
      return display_repl_status(err)
    end
    local function _17_(code, signal)
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
    local function _20_(msg)
      return display_result(msg)
    end
    return core.assoc(M.state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _15_, ["on-error"] = _16_, ["on-exit"] = _17_, ["on-stray-output"] = _20_}))
  end
end
M["on-load"] = function()
  return M.start()
end
M["on-exit"] = function()
  return M.stop()
end
M["on-filetype"] = function()
  local function _22_()
    return M.start()
  end
  mapping.buf("FnlStart", cfg({"mapping", "start"}), _22_, {desc = "Start the REPL"})
  local function _23_()
    return M.stop()
  end
  mapping.buf("FnlStop", cfg({"mapping", "stop"}), _23_, {desc = "Stop the REPL"})
  local function _24_()
    return M["eval-reload"]()
  end
  return mapping.buf("FnlEvalReload", cfg({"mapping", "eval_reload"}), _24_, {desc = "Use ,reload on the file"})
end
return M
