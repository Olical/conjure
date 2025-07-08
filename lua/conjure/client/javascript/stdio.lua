-- [nfnl] fnl/conjure/client/javascript/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local dyn = autoload("conjure.dynamic")
local text = autoload("conjure.text")
config.merge({client = {javascript = {stdio = {command = "node --experimental-repl-await -i", ["prompt-pattern"] = "> ", ["delay-stderr-ms"] = 10}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {javascript = {stdio = {mapping = {start = "cs", stop = "cS", restart = "cr", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "javascript", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local buf_suffix = ".js"
local comment_prefix = "// "
local function form_node_3f(node)
  return (("function_declaration" == node:type()) or ("export_statement" == node:type()) or ("try_statement" == node:type()) or ("expression_statement" == node:type()) or ("lexical_declaration" == node:type()) or ("for_statement" == node:type()))
end
local function is_dots_3f(s)
  return (string.sub(s, 1, 3) == "...")
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_result(msg)
  local function _5_(_241)
    return ("(out) " .. _241)
  end
  return log.append(a.map(_5_, msg))
end
local patterns_replacements = {{"^%s*import%s+%{%s*([^}]+)%s+as%s+([^}]+)%s+%}%s+from%s+[\"'](%w+:?%w+)[\"']%s*;?%s?", "const {%1:%2} = require(\"%3\");"}, {"^%s*import%s+([^%s{]+)%s+from%s+([\"'])(.-)%2%s*;?%s?", "const %1 = require(\"%3\");"}, {"^%s*import%s+%*%s+as%s+([^%s]+)%s+from%s+([\"'])(.-)%2%s*;?%s?", "const %1 = require(\"%3\");"}, {"^%s*import%s+%{([^}]+)%}%s+from%s+([\"'])(.-)%2%s*;?%s?", "const {%1} = require(\"%3\");"}, {"^%s*import%s+([^%s{,]+)%s*,%s*%{([^}]+)%}%s+from%s+([\"'])(.-)%3%s*;?%s?", "const { default: %1, %2 } = require(\"%4\");"}, {"^%s*import%s+([\"'])(.-)%1%s*;?%s?", "require(\"%2\");"}}
local function replace_imports(s)
  if not text["starts-with"](s, "import") then
    return s
  else
    local initial_acc = {result = s, ["applied?"] = false}
    local final_acc
    local function _7_(acc, _6_)
      local pat = _6_[1]
      local repl = _6_[2]
      if acc["applied?"] then
        return acc
      else
        local r, c = string.gsub(acc.result, pat, repl)
        if (c > 0) then
          return {["applied?"] = true, result = r}
        else
          return acc
        end
      end
    end
    final_acc = a.reduce(_7_, initial_acc, patterns_replacements)
    return final_acc.result
  end
end
local function is_arrow_fn_3f(s)
  if ("string" ~= type(s)) then
  else
  end
  local ts = s:match("^%s*(.-)%s*$")
  local expr = (ts:match("=%s*(.*)") or ts)
  local parens = "^%s*%b()%s*=>"
  local ident = "^%s*[%a_$][%w_$]*%s*=>"
  if not (ts:find("=> ") or ts:find("%f[%w]function%f[%W]")) then
  else
  end
  if expr:match(parens) then
  else
  end
  if expr:match(ident) then
  else
  end
  return false
end
local function replace_arrows(s)
  if not is_arrow_fn_3f(s) then
    return s
  else
    local function _15_(name, before_args, args, body)
      local async_kw
      if before_args:find("async") then
        async_kw = "async "
      else
        async_kw = ""
      end
      local final_body
      if body:find("^%s*%{") then
        final_body = (" " .. body)
      else
        final_body = (" { return " .. body .. " }")
      end
      return (async_kw .. "function " .. name .. "(" .. args .. ")" .. final_body)
    end
    return s:gsub("const%s*([%w_]+)%s*=%s*(.-)%((.-)%)%s*=>%s*(.*)", _15_)
  end
end
local function prep_code(s)
  local consts = replace_arrows(s)
  local res
  local function _19_(_241)
    return replace_imports(str.trim(_241))
  end
  local function _20_(_241)
    return ("" ~= _241)
  end
  res = (str.join("\n", a.map(_19_, a.filter(_20_, str.split(consts, "\n")))) .. "\n")
  return res
end
local function replace_dots(s, with)
  return string.gsub(s, "%.%.%.%s?", with)
end
local function format_msg(msg)
  local function _21_(_241)
    return replace_dots(_241, "")
  end
  local function _22_(_241)
    return ("" ~= _241)
  end
  return a.map(_21_, a.filter(_22_, str.split(msg, "\n")))
end
local function get_console_output_msgs(msgs)
  local function _23_(_241)
    return (comment_prefix .. "(out) " .. _241)
  end
  return a.map(_23_, a.butlast(msgs))
end
local function get_expression_result(msgs)
  local result = a.last(msgs)
  if (a["nil?"](result) or is_dots_3f(result)) then
    return nil
  else
    return result
  end
end
local function unbatch(msgs)
  local function _25_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_25_, msgs))
end
local function eval_str(opts)
  local function _26_(repl)
    local function _27_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _27_, {["batch?"] = true})
  end
  return with_repl_or_warn(_26_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
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
local initialise_repl_code = ""
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _31_()
      local function _32_(repl)
        local function _33_(msgs)
          return display_result(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code(initialise_repl_code), _33_, {batch = true})
      end
      return display_repl_status("started", with_repl_or_warn(_32_))
    end
    local function _34_(err)
      return display_repl_status(err)
    end
    local function _35_(code, signal)
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
    local function _38_(msg)
      return log.dbg(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt-pattern"}), cmd = cfg({"command"}), ["delay-stderr-ms"] = cfg({"delay-stderr-ms"}), ["on-success"] = _31_, ["on-error"] = _34_, ["on-exit"] = _35_, ["on-stray-output"] = _38_}))
  end
end
local function warning_msg()
  local function _40_(_241)
    return log.append({_241})
  end
  return a.map(_40_, {"// WARNING! Node.js REPL limitations require transformations:", "// 1. ES6 'import' statements are converted to 'require(...)' calls.", "// 2. Arrow functions ('const fn = () => ...') are converted to 'function fn() ...' declarations to allow re-definition."})
end
local function on_load()
  if config["get-in"]({"client_on_load"}) then
    start()
    return warning_msg()
  else
    return log.append({"Not starting repl"})
  end
end
local function on_exit()
  return stop()
end
local function interrupt()
  local function _42_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_42_)
end
local function on_filetype()
  mapping.buf("JavascriptStart", cfg({"mapping", "start"}), start, {desc = "Start the Javascript REPL"})
  mapping.buf("JavascriptStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the Javascript REPL"})
  local function _43_()
    stop()
    return start()
  end
  mapping.buf("JavascriptRestart", cfg({"mapping", "restart"}), _43_, {desc = "Restart the Javascript REPL"})
  return mapping.buf("JavascriptInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the current evaluation"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, ["format-msg"] = format_msg, unbatch = unbatch, ["eval-str"] = eval_str, ["eval-file"] = eval_file, stop = stop, ["initialise-repl-code"] = initialise_repl_code, start = start, ["on-load"] = on_load, ["on-exit"] = on_exit, interrupt = interrupt, ["on-filetype"] = on_filetype}
