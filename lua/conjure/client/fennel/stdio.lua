-- [nfnl] Compiled from fnl/conjure/client/fennel/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local afs = autoload("conjure.aniseed.fs")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
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
local buf_suffix = ".fnl"
local comment_prefix = "; "
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local comment_node_3f = ts["lisp-comment-node?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local function format_message(msg)
  return str.split((msg.out or msg.err), "\n")
end
local function display_result(msg)
  local function _5_(_241)
    return not ("" == _241)
  end
  return log.append(a.filter(_5_, format_message(msg)))
end
local function eval_str(opts)
  local function _6_(repl)
    local function _7_(msgs)
      if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
        a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result."))
      else
      end
      local msgs0
      local function _9_(_241)
        return (".." ~= _241.out)
      end
      msgs0 = a.filter(_9_, msgs)
      if opts["on-result"] then
        opts["on-result"](str.join("\n", format_message(a.last(msgs0))))
      else
      end
      return a["run!"](display_result, msgs0)
    end
    return repl.send((opts.code .. "\n"), _7_, {["batch?"] = true})
  end
  return with_repl_or_warn(_6_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
local function eval_reload()
  local file_path = nvim.fn.expand("%")
  local relative_no_suf = nvim.fn.fnamemodify(file_path, ":.:r")
  local module_path = string.gsub(relative_no_suf, afs["path-sep"], ".")
  log.append({(comment_prefix .. ",reload " .. module_path)}, {["break?"] = true})
  return eval_str({action = "eval", origin = "reload", ["file-path"] = file_path, code = (",reload " .. module_path)})
end
local function doc_str(opts)
  local function _11_(_241)
    return (",doc " .. _241 .. "\n")
  end
  return eval_str(a.update(opts, "code", _11_))
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
    local function _14_()
      return display_repl_status("started")
    end
    local function _15_(err)
      return display_repl_status(err)
    end
    local function _16_(code, signal)
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
    local function _19_(msg)
      return display_result(msg)
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _14_, ["on-error"] = _15_, ["on-exit"] = _16_, ["on-stray-output"] = _19_}))
  end
end
local function on_load()
  return start()
end
local function on_exit()
  return stop()
end
local function on_filetype()
  mapping.buf("FnlStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("FnlStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("FnlEvalReload", cfg({"mapping", "eval_reload"}), eval_reload, {desc = "Use ,reload on the file"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, ["comment-node?"] = comment_node_3f, ["eval-str"] = eval_str, ["eval-file"] = eval_file, ["eval-reload"] = eval_reload, ["doc-str"] = doc_str, stop = stop, start = start, ["on-load"] = on_load, ["on-exit"] = on_exit, ["on-filetype"] = on_filetype}
