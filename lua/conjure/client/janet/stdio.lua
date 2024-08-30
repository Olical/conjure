-- [nfnl] Compiled from fnl/conjure/client/janet/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
config.merge({client = {janet = {stdio = {mapping = {start = "cs", stop = "cS"}, command = "janet -n -s", prompt_pattern = "repl:[0-9]+:[^>]*> "}}}})
local cfg = config["get-in-fn"]({"client", "janet", "stdio"})
local state
local function _2_()
  return {repl = nil}
end
state = client["new-state"](_2_)
local buf_suffix = ".janet"
local comment_prefix = "# "
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local function unbatch(msgs)
  local function _4_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return {out = str.join("", a.map(_4_, msgs))}
end
local function format_message(msg)
  local function _5_(_241)
    return ("" ~= _241)
  end
  return a.filter(_5_, str.split(msg.out, "\n"))
end
local function prep_code(s)
  return (s .. "\n")
end
local function eval_str(opts)
  local function _6_(repl)
    local function _7_(msgs)
      local lines = format_message(unbatch(msgs))
      if opts["on-result"] then
        opts["on-result"](a.last(lines))
      else
      end
      return log.append(lines)
    end
    return repl.send(prep_code(opts.code), _7_, {["batch?"] = true})
  end
  return with_repl_or_warn(_6_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
local function doc_str(opts)
  local function _9_(_241)
    return ("(doc " .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _9_))
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
    local function _12_()
      return display_repl_status("started")
    end
    local function _13_(err)
      return display_repl_status(err)
    end
    local function _14_(code, signal)
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
    local function _17_(msg)
      return log.append(format_message(msg))
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _13_, ["on-exit"] = _14_, ["on-stray-output"] = _17_}))
  end
end
local function on_load()
  return start()
end
local function on_filetype()
  mapping.buf("JanetStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  return mapping.buf("JanetStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
end
local function on_exit()
  return stop()
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, unbatch = unbatch, ["eval-str"] = eval_str, ["eval-file"] = eval_file, ["doc-str"] = doc_str, stop = stop, start = start, ["on-load"] = on_load, ["on-filetype"] = on_filetype, ["on-exit"] = on_exit}
