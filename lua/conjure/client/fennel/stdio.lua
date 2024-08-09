-- [nfnl] Compiled from fnl/conjure/client/fennel/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.fennel.stdio"
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
local a, afs, client, config, log, mapping, nvim, stdio, str, text, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["afs"] = afs
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["_"] = _
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
config.merge({client = {fennel = {stdio = {command = "fennel", prompt_pattern = ">> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {fennel = {stdio = {mapping = {start = "cs", stop = "cS", eval_reload = "eF"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "fennel", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
do local _ = {nil, nil} end
local state
local function _2_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_2_))
do end (_2amodule_locals_2a)["state"] = state
do local _ = {nil, nil} end
local buf_suffix = ".fnl"
_2amodule_2a["buf-suffix"] = buf_suffix
do local _ = {nil, nil} end
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
do local _ = {nil, nil} end
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
do local _ = {nil, nil} end
local comment_node_3f = ts["lisp-comment-node?"]
_2amodule_2a["comment-node?"] = comment_node_3f
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
local function format_message(msg)
  return str.split((msg.out or msg.err), "\n")
end
_2amodule_locals_2a["format-message"] = format_message
do local _ = {format_message, nil} end
local function display_result(msg)
  local function _4_(_241)
    return not ("" == _241)
  end
  return log.append(a.filter(_4_, format_message(msg)))
end
_2amodule_locals_2a["display-result"] = display_result
do local _ = {display_result, nil} end
local function eval_str(opts)
  local function _5_(repl)
    local function _6_(msgs)
      if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
        a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result."))
      else
      end
      local msgs0
      local function _8_(_241)
        return (".." ~= (_241).out)
      end
      msgs0 = a.filter(_8_, msgs)
      if opts["on-result"] then
        opts["on-result"](str.join("\n", format_message(a.last(msgs0))))
      else
      end
      return a["run!"](display_result, msgs0)
    end
    return repl.send((opts.code .. "\n"), _6_, {["batch?"] = true})
  end
  return with_repl_or_warn(_5_)
end
_2amodule_2a["eval-str"] = eval_str
do local _ = {eval_str, nil} end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
_2amodule_2a["eval-file"] = eval_file
do local _ = {eval_file, nil} end
local function eval_reload()
  local file_path = nvim.fn.expand("%")
  local relative_no_suf = nvim.fn.fnamemodify(file_path, ":.:r")
  local module_path = string.gsub(relative_no_suf, afs["path-sep"], ".")
  log.append({(comment_prefix .. ",reload " .. module_path)}, {["break?"] = true})
  return eval_str({action = "eval", origin = "reload", ["file-path"] = file_path, code = (",reload " .. module_path)})
end
_2amodule_2a["eval-reload"] = eval_reload
do local _ = {eval_reload, nil} end
local function doc_str(opts)
  local function _10_(_241)
    return (",doc " .. _241 .. "\n")
  end
  return eval_str(a.update(opts, "code", _10_))
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
    local function _13_()
      return display_repl_status("started")
    end
    local function _14_(err)
      return display_repl_status(err)
    end
    local function _15_(code, signal)
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
    local function _18_(msg)
      return display_result(msg)
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _13_, ["on-error"] = _14_, ["on-exit"] = _15_, ["on-stray-output"] = _18_}))
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
local function on_filetype()
  mapping.buf("FnlStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("FnlStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("FnlEvalReload", cfg({"mapping", "eval_reload"}), eval_reload, {desc = "Use ,reload on the file"})
end
_2amodule_2a["on-filetype"] = on_filetype
do local _ = {on_filetype, nil} end
return _2amodule_2a
