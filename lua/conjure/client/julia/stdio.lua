-- [nfnl] Compiled from fnl/conjure/client/julia/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local extract = autoload("conjure.extract")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
config.merge({client = {julia = {stdio = {command = "julia --banner=no --color=no -i", prompt_pattern = ""}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {julia = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "julia", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local buf_suffix = ".jl"
local comment_prefix = "# "
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function prep_code(s)
  return (s .. "\nif(isnothing(ans)) display(nothing) end\n")
end
local function unbatch(msgs)
  local function _5_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_5_, msgs))
end
local function format_msg(msg)
  local function _6_(_241)
    return ("" ~= _241)
  end
  return a.filter(_6_, str.split(string.gsub(msg, "(.?[%w\n])(nothing)", "%1"), "\n"))
end
local function get_form_modifier(node)
  if (";" == ts["node->str"](node:next_sibling())) then
    return {modifier = "raw", ["node-table"] = {content = (ts["node->str"](node) .. ";"), range = a["update-in"](ts.range(node), {"end", 2}, a.inc)}}
  else
    return nil
  end
end
local function eval_str(opts)
  local function _8_(repl)
    local function _9_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      log.append(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(string.gsub(opts.code, ";$", "; nothing;")), _9_, {["batch?"] = true})
  end
  return with_repl_or_warn(_8_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
local function doc_str(opts)
  local function _11_(_241)
    return ("Main.eval(REPL.helpmode(\"" .. _241 .. "\"))")
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
      display_repl_status("started")
      local function _15_(repl)
        local function _16_(msgs)
          return log.append(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code("using REPL"), _16_, {["batch?"] = true})
      end
      return with_repl_or_warn(_15_)
    end
    local function _17_(err)
      return display_repl_status(err)
    end
    local function _18_(code, signal)
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
    local function _21_(msg)
      return log.append(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _14_, ["on-error"] = _17_, ["on-exit"] = _18_, ["on-stray-output"] = _21_}))
  end
end
local function on_load()
  return start()
end
local function on_exit()
  return stop()
end
local function interrupt()
  local function _23_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_23_)
end
local function on_filetype()
  mapping.buf("JuliaStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("JuliaStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("JuliaInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the evaluation"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, unbatch = unbatch, ["format-msg"] = format_msg, ["get-form-modifier"] = get_form_modifier, ["eval-str"] = eval_str, ["eval-file"] = eval_file, ["doc-str"] = doc_str, stop = stop, start = start, ["on-load"] = on_load, ["on-exit"] = on_exit, interrupt = interrupt, ["on-filetype"] = on_filetype}
