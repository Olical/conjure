-- [nfnl] Compiled from fnl/conjure/client/racket/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local nvim = autoload("conjure.aniseed.nvim")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local bridge = autoload("conjure.bridge")
config.merge({client = {racket = {stdio = {command = "racket", prompt_pattern = "\n?[\"%w%-./_]*> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {racket = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "racket", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local buf_suffix = ".rkt"
local comment_prefix = "; "
local context_pattern = "%(%s*module%s+(.-)[%s){]"
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, _opts)
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
local function eval_str(opts)
  local function _7_(repl)
    local function _8_(msgs)
      if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
        a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result."))
      else
      end
      opts["on-result"](str.join("\n", a.mapcat(format_message, msgs)))
      return a["run!"](display_result, msgs)
    end
    return repl.send(prep_code(opts.code), _8_, {["batch?"] = true})
  end
  return with_repl_or_warn(_7_)
end
local function interrupt()
  local function _10_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_10_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", (",require-reloadable " .. opts["file-path"])))
end
local function doc_str(opts)
  local function _11_(_241)
    return (",doc " .. _241)
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
local function enter()
  local repl = state("repl")
  local path = vim.fn.expand("%:p")
  if (repl and not log["log-buf?"](path)) then
    local function _14_()
    end
    return repl.send(prep_code((",enter " .. path)), _14_)
  else
    return nil
  end
end
local function start()
  if state("repl") then
    return log.append({"; Can't start, REPL is already running.", ("; Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _16_()
      display_repl_status("started")
      return enter()
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
      return display_result(msg)
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _16_, ["on-error"] = _17_, ["on-exit"] = _18_, ["on-stray-output"] = _21_}))
  end
end
local function on_load()
  return start()
end
local function on_filetype()
  do
    nvim.ex.augroup("conjure-racket-stdio-bufenter")
    nvim.ex.autocmd_()
    nvim.ex.autocmd("BufEnter", ("*" .. buf_suffix), bridge["viml->lua"]("conjure.client.racket.stdio", "enter"))
    nvim.ex.augroup("END")
  end
  mapping.buf("RktStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("RktStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("RktInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the current evaluation"})
end
local function on_exit()
  return stop()
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["context-pattern"] = context_pattern, ["form-node?"] = form_node_3f, ["eval-str"] = eval_str, interrupt = interrupt, ["eval-file"] = eval_file, ["doc-str"] = doc_str, stop = stop, enter = enter, start = start, ["on-load"] = on_load, ["on-filetype"] = on_filetype, ["on-exit"] = on_exit}
