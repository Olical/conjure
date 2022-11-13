local _2afile_2a = "fnl/conjure/client/julia/stdio.fnl"
local _2amodule_name_2a = "conjure.client.julia.stdio"
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
local a, client, config, extract, log, mapping, nvim, stdio, str, text, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["_"] = _
config.merge({client = {julia = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}, command = "julia --banner=no --color=no -i", prompt_pattern = ""}}}})
local cfg = config["get-in-fn"]({"client", "julia", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _1_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local buf_suffix = ".jl"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "# "
_2amodule_2a["comment-prefix"] = comment_prefix
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function prep_code(s)
  return (s .. "\nif(isnothing(ans)) display(nothing) end\n")
end
_2amodule_locals_2a["prep-code"] = prep_code
local function unbatch(msgs)
  local function _3_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_3_, msgs))
end
_2amodule_2a["unbatch"] = unbatch
local function format_msg(msg)
  local function _4_(_241)
    return ("" ~= _241)
  end
  return a.filter(_4_, str.split(string.gsub(msg, "(.?[%w\n])(nothing)", "%1"), "\n"))
end
_2amodule_2a["format-msg"] = format_msg
local function get_form_modifier(node)
  if (";" == ts["node->str"](node:next_sibling())) then
    return {modifier = "raw", ["node-table"] = {content = (ts["node->str"](node) .. ";"), range = a["update-in"](ts.range(node), {"end", 2}, a.inc)}}
  else
    return nil
  end
end
_2amodule_2a["get-form-modifier"] = get_form_modifier
local function eval_str(opts)
  local function _6_(repl)
    local function _7_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      log.append(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(string.gsub(opts.code, ";$", "; nothing;")), _7_, {["batch?"] = true})
  end
  return with_repl_or_warn(_6_)
end
_2amodule_2a["eval-str"] = eval_str
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
_2amodule_2a["eval-file"] = eval_file
local function doc_str(opts)
  local function _9_(_241)
    return ("Main.eval(REPL.helpmode(\"" .. _241 .. "\"))")
  end
  return eval_str(a.update(opts, "code", _9_))
end
_2amodule_2a["doc-str"] = doc_str
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
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
    local function _12_()
      display_repl_status("started")
      local function _13_(repl)
        local function _14_(msgs)
          return log.append(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code("using REPL"), _14_, {["batch?"] = true})
      end
      return with_repl_or_warn(_13_)
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
      return log.append(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _15_, ["on-exit"] = _16_, ["on-stray-output"] = _19_}))
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
local function interrupt()
  local function _21_(repl)
    local uv = vim.loop
    return uv.kill(repl.pid, uv.constants.SIGINT)
  end
  return with_repl_or_warn(_21_)
end
_2amodule_2a["interrupt"] = interrupt
local function on_filetype()
  mapping.buf("JuliaStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("JuliaStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("JuliaInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the evaluation"})
end
_2amodule_2a["on-filetype"] = on_filetype
return _2amodule_2a