local _2afile_2a = "fnl/conjure/client/racket/stdio.fnl"
local _2amodule_name_2a = "conjure.client.racket.stdio"
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
local a, client, config, log, mapping, nvim, stdio, str, text, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
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
config.merge({client = {racket = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}, command = "racket", prompt_pattern = "\n?[\"%w%-./_]*> "}}}})
local cfg = config["get-in-fn"]({"client", "racket", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _1_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local buf_suffix = ".rkt"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
local context_pattern = "%(%s*module%s+(.-)[%s){]"
_2amodule_2a["context-pattern"] = context_pattern
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function format_message(msg)
  return str.split((msg.out or msg.err), "\n")
end
_2amodule_locals_2a["format-message"] = format_message
local function display_result(msg)
  local function _3_(_241)
    return not ("" == _241)
  end
  return log.append(a.filter(_3_, format_message(msg)))
end
_2amodule_locals_2a["display-result"] = display_result
local function prep_code(s)
  local lang_line_pat = "#lang [^%s]+"
  local code
  if s:match(lang_line_pat) then
    log.append({(comment_prefix .. "Dropping #lang, only supported in file evaluation.")})
    code = s:gsub(lang_line_pat, "")
  else
    code = s
  end
  return (code .. "\n(flush-output)")
end
_2amodule_locals_2a["prep-code"] = prep_code
local function eval_str(opts)
  local function _5_(repl)
    local function _6_(msgs)
      if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
        a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result."))
      else
      end
      opts["on-result"](str.join("\n", a.mapcat(format_message, msgs)))
      return a["run!"](display_result, msgs)
    end
    return repl.send(prep_code(opts.code), _6_, {["batch?"] = true})
  end
  return with_repl_or_warn(_5_)
end
_2amodule_2a["eval-str"] = eval_str
local function interrupt()
  local function _8_(repl)
    log.append({"; Sending interrupt signal."}, {["break?"] = true})
    return repl["send-signal"](2)
  end
  return with_repl_or_warn(_8_)
end
_2amodule_2a["interrupt"] = interrupt
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", (",require-reloadable " .. opts["file-path"])))
end
_2amodule_2a["eval-file"] = eval_file
local function doc_str(opts)
  local function _9_(_241)
    return (",doc " .. _241)
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
local function enter()
  local repl = state("repl")
  local path = nvim.fn.expand("%:p")
  if (repl and not log["log-buf?"](path)) then
    local function _12_()
    end
    return repl.send(prep_code((",enter " .. path)), _12_)
  else
    return nil
  end
end
_2amodule_2a["enter"] = enter
local function start()
  if state("repl") then
    return log.append({"; Can't start, REPL is already running.", ("; Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _14_()
      display_repl_status("started")
      return enter()
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
_2amodule_2a["start"] = start
local function on_load()
  return start()
end
_2amodule_2a["on-load"] = on_load
local function on_filetype()
  do
    nvim.ex.augroup("conjure-racket-stdio-bufenter")
    nvim.ex.autocmd_()
    nvim.ex.autocmd("BufEnter", ("*" .. buf_suffix), ("lua require('" .. _2amodule_name_2a .. "')['" .. "enter" .. "']()"))
    nvim.ex.augroup("END")
  end
  mapping.buf("RktStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("RktStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("RktInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the current evaluation"})
end
_2amodule_2a["on-filetype"] = on_filetype
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit
return _2amodule_2a