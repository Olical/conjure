-- [nfnl] fnl/conjure/client/javascript/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local text = autoload("conjure.text")
local M = define("conjure.client.javascript.stdio")
local function filetype()
  return vim.bo.filetype
end
local repl_type
if ("javascript" == filetype()) then
  repl_type = "js"
elseif ("typescript" == filetype()) then
  repl_type = "ts"
else
  repl_type = nil
end
local function get_repl_cmd()
  if ("js" == repl_type) then
    return "node -i"
  elseif ("ts" == repl_type) then
    return "ts-node -i"
  else
    return nil
  end
end
config.merge({client = {javascript = {stdio = {command = get_repl_cmd(), args = "NODE_OPTIONS='--experimental-repl-await'", ["prompt-pattern"] = "> ", show_stray_out = false}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {javascript = {stdio = {mapping = {start = "cs", stop = "cS", restart = "cr", interrupt = "ei", stray = "ts"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "javascript", "stdio"})
M["buf-suffix"] = ".js"
local state
local function _5_()
  return {repl = nil}
end
state = client["new-state"](_5_)
M["comment-prefix"] = "// "
M["form-node?"] = function(node)
  return (("function_declaration" == node:type()) or ("export_statement" == node:type()) or ("try_statement" == node:type()) or ("expression_statement" == node:type()) or ("import_statement" == node:type()) or ("class_declaration" == node:type()) or ("type_alias_declaration" == node:type()) or ("enum_declaration" == node:type()) or ("lexical_declaration" == node:type()) or ("for_statement" == node:type()) or ("for_in_statement" == node:type()))
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running"), (M["comment-prefix"] .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_result(msg)
  return log.append(msg)
end
local function get_absolute_path(f)
  return ("\"" .. vim.fn.fnamemodify((vim.fn.expand("%:p:h") .. "/" .. f), ":p") .. "\"")
end
local function replace_imports_path(s)
  if string.find(s, "import") then
    local function _7_(m)
      if text["starts-with"](m, ".") then
        return get_absolute_path(m)
      else
        return ("\"" .. m .. "\"")
      end
    end
    return string.gsub(s, "[\"'](.-)[\"']", _7_)
  else
    return s
  end
end
local patterns_replacements = {{"^%s*import%s+%*%s+as%s+([^%s]+)%s+from%s+([\"'])(.-)%2%s*", "const %1 = require(\"%3\")"}, {"^%s*import%s+%{%s*([^}]+)%s+as%s+([^}]+)%s+%}%s+from%s+[\"'](.-)%3%s*", "const {%1:%2} = require(\"%3\");"}, {"^%s*import%s+([^%s{]+)%s+from%s+([\"'])(.-)%2%s*", "const %1 = require(\"%3\")"}, {"^%s*import%s+%{([^}]+)%}%s+from%s+([\"'])(.-)%2%s*", "const {%1} = require(\"%3\")"}, {"^%s*import%s+([^%s{,]+)%s*,%s*%{([^}]+)%}%s+from%s+([\"'])(.-)%3%s*", "const { default: %1, %2 } = require(\"%4\")"}, {"^%s*import%s+([\"'])(.-)%1%s*", "require(\"%2\");"}}
local function replace_imports(s)
  if (text["starts-with"](s, "import") and not text["starts-with"](s, "import type")) then
    local initial_acc = {result = s, ["applied?"] = false}
    local final_acc
    local function _11_(acc, _10_)
      local pat = _10_[1]
      local repl = _10_[2]
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
    final_acc = a.reduce(_11_, initial_acc, patterns_replacements)
    return final_acc.result
  else
    return s
  end
end
local function is_arrow_fn_3f(code)
  if (text["starts-with"](code, "let") or text["starts-with"](code, "const")) then
    local pat
    if string.find(code, "async") then
      pat = ".*=%s*async%s+%(.*%)%s*:+.*=>"
    else
      pat = ".*=%s*%(.*%)%s*:?.*=>"
    end
    if string.match(code, pat) then
      return true
    else
      return false
    end
  else
    return nil
  end
end
local function remove_comments(s)
  local sub, _ = string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "%/%/.-\n", ""), "%/%*.-%*%/", ""), "^%/%/.*", ""), "^%/.*", ""), "^%s*%*.*", ""), "^%s*%/%*+.*", "")
  return sub
end
local function replace_arrows(s)
  if not is_arrow_fn_3f(s) then
    return s
  else
    local decl
    if text["starts-with"](s, "const") then
      decl = "const"
    elseif text["starts-with"](s, "let") then
      decl = "let"
    else
      decl = nil
    end
    local pattern = (decl .. "%s*([%w_]+)%s*=%s*(.-)%((.-)%)%s*(.-)%s*=>%s*(.*)")
    local replace_fn
    local function _19_(name, before_args, args, after_args, body)
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
      return (async_kw .. "function " .. name .. "(" .. args .. ")" .. after_args .. final_body)
    end
    replace_fn = _19_
    local replace, _ = s:gsub(pattern, replace_fn)
    return replace
  end
end
local function prep_code_expr(e)
  return replace_arrows(replace_imports(replace_imports_path(string.gsub(remove_comments(e), "\n+", " "))))
end
local function prep_code_file(f)
  return str.join("\n", a.map(prep_code_expr, str.split(f, "\n")))
end
local function prep_code(s)
  return (prep_code_expr(s) .. "\n")
end
local function replace_dots(s, with)
  local s0, _count = string.gsub(s, "%.%.%.%s?", with)
  return s0
end
M["format-msg"] = function(msg)
  local function _23_(_241)
    return replace_dots(_241, "")
  end
  local function _24_(_241)
    return ("" ~= _241)
  end
  return a.map(_23_, a.filter(_24_, str.split(msg, "\n")))
end
local function sanitize_msg(msg, field)
  local function _25_(_241)
    return ("(" .. field .. ") " .. _241 .. "\n")
  end
  local function _26_(...)
    return not str["blank?"](...)
  end
  local function _27_(_241)
    return replace_dots(_241, "")
  end
  return str.join("", a.map(_25_, a.filter(_26_, a.map(_27_, str.split(a.get(msg, field), "\n")))))
end
local function prepare_out(msg)
  if a.get(msg, "out") then
    return sanitize_msg(msg, "out")
  elseif a.get(msg, "err") then
    return sanitize_msg(msg, "err")
  else
    return nil
  end
end
M.unbatch = function(msgs)
  return str.join("", a.map(prepare_out, msgs))
end
local function delete_file(f)
  local cmd
  if (0 == vim.fn.has("macunix")) then
    cmd = "del"
  else
    cmd = "rm"
  end
  if (1 == vim.fn.filereadable(f)) then
    return os.execute((cmd .. " " .. f))
  else
    return nil
  end
end
local function stray_out()
  return config.merge({client = {javascript = {stdio = {show_stray_out = not cfg({"show_stray_out"})}}}}, {["overwrite?"] = true})
end
local function restart()
  M.stop()
  return M.start()
end
M["eval-str"] = function(opts)
  local function _31_(repl)
    local function _32_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _32_, {["batch?"] = true})
  end
  return with_repl_or_warn(_31_)
end
M["eval-file"] = function(opts)
  local function _34_(repl)
    local c = prep_code_file(a.slurp(opts["file-path"]))
    local tmp_name = (opts["file-path"] .. "_tmp")
    local _tmp = a.spit(tmp_name, c)
    log.dbg({"EVAL TEMP FILE: ", tmp_name})
    repl.send((".load " .. tmp_name .. "\n"))
    local function _35_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return delete_file(tmp_name)
  end
  return with_repl_or_warn(_34_)
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(M["comment-prefix"] .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
M.stop = function()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M["initialise-repl-code"] = ""
M.start = function()
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _39_()
      display_repl_status("started")
      local function _40_(repl)
        local function _41_(msgs)
          return display_result(M["format-msg"](M.unbatch(msgs)))
        end
        return repl.send(prep_code(M["initialise-repl-code"]), _41_, {batch = true})
      end
      return with_repl_or_warn(_40_)
    end
    local function _42_(err)
      return display_repl_status(err)
    end
    local function _43_(code, signal)
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
    local function _46_(msg)
      if cfg({"show_stray_out"}) then
        return display_result(M["format-msg"](M.unbatch({msg})))
      else
        return nil
      end
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt-pattern"}), cmd = cfg({"command"}), ["delay-stderr-ms"] = cfg({"delay-stderr-ms"}), ["on-success"] = _39_, ["on-error"] = _42_, ["on-exit"] = _43_, ["on-stray-output"] = _46_}))
  end
end
local function warning_msg()
  local function _49_(_241)
    return log.append({_241})
  end
  return a.map(_49_, {"// WARNING! Node.js REPL limitations require transformations:", "// 1. ES6 'import' statements are converted to 'require(...)' calls.", "// 2. Arrow functions ('const fn = () => ...') are converted to 'function fn() ...' declarations to allow re-definition."})
end
M["on-load"] = function()
  if config["get-in"]({"client_on_load"}) then
    M.start()
    return warning_msg()
  else
    return log.append({"Not starting repl"})
  end
end
M["on-exit"] = function()
  return M.stop()
end
M.interrupt = function()
  local function _51_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_51_)
end
M["on-filetype"] = function()
  mapping.buf("JavascriptStart", cfg({"mapping", "start"}), M.start, {desc = "Start the Javascript REPL"})
  mapping.buf("JavascriptStop", cfg({"mapping", "stop"}), M.stop, {desc = "Stop the Javascript REPL"})
  mapping.buf("JavascriptRestart", cfg({"mapping", "restart"}), restart, {desc = "Restart the Javascript REPL"})
  mapping.buf("JavascriptInterrupt", cfg({"mapping", "interrupt"}), M.interrupt, {desc = "Interrupt the current evaluation"})
  return mapping.buf("JavascriptStray", cfg({"mapping", "stray"}), stray_out, {desc = "Toggle stray out"})
end
return M
