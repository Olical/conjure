-- [nfnl] fnl/conjure/client/guile/socket.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local a = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local socket = autoload("conjure.remote.socket")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local ts = autoload("conjure.tree-sitter")
local cmpl = autoload("conjure.client.guile.completions")
local util = autoload("conjure.util")
local M = define("conjure.client.guile.socket")
config.merge({client = {guile = {socket = {pipename = nil, host_port = nil, enable_completions = true}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {guile = {socket = {mapping = {connect = "cc", disconnect = "cd"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "guile", "socket"})
local state
local function _3_()
  return {repl = nil, ["known-contexts"] = {}}
end
state = client["new-state"](_3_)
M["buf-suffix"] = ".scm"
M["comment-prefix"] = "; "
local base_module = "(guile)"
local default_context = "(guile-user)"
M["valid-str?"] = function(code)
  return ts["valid-str?"]("scheme", code)
end
local function normalize_context(arg)
  local tokens = str.split(arg, "%s+")
  local context = ("(" .. str.join(" ", tokens) .. ")")
  return context
end
local function strip_comments(f)
  return string.gsub(f, ";.-\n", "")
end
M.context = function(f)
  local stripped = strip_comments((f .. "\n"))
  local define_args = string.match(stripped, "%(define%-module%s+%(%s*([%g%s]-)%s*%)")
  if define_args then
    return normalize_context(define_args)
  else
    return nil
  end
end
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, _opts)
  local repl = state("repl")
  if (repl and ("connected" == repl.status)) then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running")})
  end
end
local function format_message(msg)
  if msg.out then
    return text["split-lines"](msg.out)
  elseif msg.err then
    return text["prefixed-lines"](string.gsub(msg.err, "%s*Entering a new prompt%. .*]>%s*", ""), M["comment-prefix"])
  else
    return {(M["comment-prefix"] .. "Empty result")}
  end
end
local function display_result(msg)
  local function _7_(_241)
    return ("" ~= _241)
  end
  return log.append(a.filter(_7_, format_message(msg)))
end
local function clean_input_code(code)
  local clean = str.trim(code)
  if not str["blank?"](clean) then
    return clean
  else
    return nil
  end
end
local function completions_enabled_3f()
  return cfg({"enable_completions"})
end
local function build_switch_module_command(context)
  return (",m " .. context)
end
local function init_module(repl, context)
  log.dbg(("Initializing module for context " .. context))
  local function _9_(_)
  end
  repl.send((build_switch_module_command(context) .. "\n,import " .. base_module), _9_)
  if completions_enabled_3f() then
    local function _10_(_)
    end
    return repl.send(cmpl["guile-repl-completion-code"], _10_)
  else
    return nil
  end
end
local function ensure_module_initialized(repl, context)
  if not a["get-in"](state(), {"known-contexts", context}) then
    init_module(repl, context)
    return a["assoc-in"](state(), {"known-contexts", context}, true)
  else
    return nil
  end
end
M["eval-str"] = function(opts)
  local function _13_(repl)
    if M["valid-str?"](opts.code) then
      local context = (opts.context or default_context)
      ensure_module_initialized(repl, context)
      local tmp_3_ = (build_switch_module_command(context) .. "\n" .. opts.code)
      if (nil ~= tmp_3_) then
        local tmp_3_0 = clean_input_code(tmp_3_)
        if (nil ~= tmp_3_0) then
          local function _14_(msgs)
            if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
              a["assoc-in"](msgs, {1, "out"}, (M["comment-prefix"] .. "Empty result"))
            else
            end
            if opts["on-result"] then
              opts["on-result"](str.join("\n", format_message(a.last(msgs))))
            else
            end
            if not opts["passive?"] then
              return a["run!"](display_result, msgs)
            else
              return nil
            end
          end
          return repl.send(tmp_3_0, _14_, {["batch?"] = true})
        else
          return nil
        end
      else
        return nil
      end
    else
      return log.append({(M["comment-prefix"] .. "eval error: could not parse form")})
    end
  end
  return with_repl_or_warn(_13_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
M["doc-str"] = function(opts)
  local function _21_(_241)
    return (",d " .. _241)
  end
  return M["eval-str"](a.update(opts, "code", _21_))
end
local function display_repl_status()
  local repl = state("repl")
  log.dbg(a.str("client.guile.socket: repl=", repl))
  if repl then
    local _22_
    do
      local pipename = a["get-in"](repl, {"opts", "pipename"})
      local host_port = a["get-in"](repl, {"opts", "host_port"})
      if pipename then
        _22_ = (pipename .. " ")
      elseif host_port then
        _22_ = (host_port .. " ")
      else
        _22_ = "no pipename & no host-port"
      end
    end
    local _24_
    do
      local err = a.get(repl, "err")
      if err then
        _24_ = (" " .. err)
      else
        _24_ = ""
      end
    end
    return log.append({(M["comment-prefix"] .. _22_ .. "(" .. repl.status .. _24_ .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
M.disconnect = function()
  do
    local repl = state("repl")
    if repl then
      repl.destroy()
      a.assoc(repl, "status", "disconnected")
      display_repl_status()
      a.assoc(state(), "repl", nil)
    else
    end
  end
  return a.assoc(state(), "known-contexts", {})
end
M["parse-guile-result"] = function(s, stray_output_fn)
  local find_prompt
  local function _28_(s0)
    return s0:find("scheme@%([%w%-%s]+%)> ")
  end
  find_prompt = _28_
  local prompt = find_prompt(s)
  if prompt then
    local s_no_prompt = s:sub(0, (prompt - 1))
    local lines
    local function _29_(line)
      if string.match(line, "^(.-)%s*%$%d+ = .*$") then
        local before = string.match(line, "^(.-)%s*%$%d+ = .*$")
        local after = string.match(line, "^.-%s*(%$%d+ = .*)$")
        return {before, after}
      else
        return {line}
      end
    end
    lines = a.mapcat(_29_, text["split-lines"](s_no_prompt))
    local stray_output_lines = {}
    local results = {}
    for _n, line in ipairs(lines) do
      local result = string.match(line, "^%$%d+ = (.*)$")
      if result then
        table.insert(results, result)
      else
        if ("" ~= line) then
          table.insert(stray_output_lines, (M["comment-prefix"] .. "(out) " .. line))
        else
        end
      end
    end
    if (#stray_output_lines > 0) then
      stray_output_fn(stray_output_lines)
    else
    end
    local _34_
    if (1 == #results) then
      _34_ = a.first(results)
    elseif (#results > 1) then
      _34_ = ("(values " .. str.join(" ", results) .. ")")
    else
      _34_ = nil
    end
    return {["done?"] = true, result = _34_, ["error?"] = false}
  elseif s:find("scheme@%([%w%-%s]+%) %[%d+%]>") then
    return {["done?"] = true, ["error?"] = true, result = nil}
  else
    return {result = s, ["done?"] = false, ["error?"] = false}
  end
end
M.connect = function(_opts)
  M.disconnect()
  local pipename = cfg({"pipename"})
  local cfg_host_port = cfg({"host_port"})
  local host_port
  if cfg_host_port then
    local _let_37_ = vim.split(cfg_host_port, ":")
    local host = _let_37_[1]
    local port = _let_37_[2]
    log.dbg(a.str("client.guile.socket: host=", host))
    log.dbg(a.str("client.guile.socket: port=", port))
    if (not host and not port) then
      host_port = "localhost:37146"
    elseif (not host and tonumber(port)) then
      host_port = a.str("localhost:", port)
    elseif (host and not port) then
      if tonumber(host) then
        host_port = a.str("localhost:", host)
      else
        host_port = a.str(host, ":37146")
      end
    else
      host_port = cfg_host_port
    end
  else
    host_port = nil
  end
  log.dbg(a.str("client.guile.socket: pipename=", pipename))
  log.dbg(a.str("client.guile.socket: host-port=", cfg_host_port))
  local function _41_(_241)
    return M["parse-guile-result"](_241, log.append)
  end
  local function _42_()
    if completions_enabled_3f() then
      cmpl["get-static-completions"]()
    else
    end
    return display_repl_status()
  end
  local function _44_(msg, repl)
    display_result(msg)
    local function _45_()
    end
    return repl.send(",q\n", _45_)
  end
  return a.assoc(state(), "repl", socket.start({["parse-output"] = _41_, pipename = pipename, ["host-port"] = host_port, ["on-success"] = _42_, ["on-error"] = _44_, ["on-failure"] = M.disconnect, ["on-close"] = M.disconnect, ["on-stray-output"] = display_result}))
end
local function connected_3f()
  if state("repl") then
    return true
  else
    return false
  end
end
local function busy_3f()
  return (connected_3f() and state("repl").current)
end
M["on-exit"] = function()
  return M.disconnect()
end
M["on-filetype"] = function()
  local function _47_()
    return M.connect()
  end
  mapping.buf("GuileConnect", cfg({"mapping", "connect"}), _47_, {desc = "Connect to a REPL"})
  local function _48_()
    return M.disconnect()
  end
  return mapping.buf("GuileDisconnect", cfg({"mapping", "disconnect"}), _48_, {desc = "Disconnect from the REPL"})
end
local function generate_completions(opts)
  local prefix = (opts.prefix or "")
  local static_suggestions = cmpl["get-static-completions"](prefix)
  if (connected_3f() and not busy_3f()) then
    local code = cmpl["build-completion-request"](opts.prefix)
    local result_fn
    local function _49_(results)
      local cmpl_list = cmpl["format-results"](results)
      local all_cmpl = a.concat(static_suggestions, cmpl_list)
      local distinct_cmpl = util["ordered-distinct"](all_cmpl)
      return opts.cb(distinct_cmpl)
    end
    result_fn = _49_
    a.assoc(opts, "code", code)
    a.assoc(opts, "on-result", result_fn)
    a.assoc(opts, "passive?", true)
    return M["eval-str"](opts)
  else
    return opts.cb(static_suggestions)
  end
end
M.completions = function(opts)
  if completions_enabled_3f() then
    return generate_completions(opts)
  else
    return opts.cb({})
  end
end
return M
