-- [nfnl] fnl/conjure/client/guile/socket.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local socket = autoload("conjure.remote.socket")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local ts = autoload("conjure.tree-sitter")
config.merge({client = {guile = {socket = {pipename = nil, ["host-port"] = nil}}}})
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
local buf_suffix = ".scm"
local comment_prefix = "; "
local base_module = "(guile)"
local default_context = "(guile-user)"
local function normalize_context(arg)
  local tokens = str.split(arg, "%s+")
  local context = ("(" .. str.join(" ", tokens) .. ")")
  return context
end
local function strip_comments(f)
  return string.gsub(f, ";.-\n", "")
end
local function context(f)
  local stripped = strip_comments((f .. "\n"))
  local define_args = string.match(stripped, "%(define%-module%s+%(%s*([%g%s]-)%s*%)")
  if define_args then
    return normalize_context(define_args)
  else
    return nil
  end
end
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if (repl and ("connected" == repl.status)) then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local function format_message(msg)
  if msg.out then
    return text["split-lines"](msg.out)
  elseif msg.err then
    return text["prefixed-lines"](string.gsub(msg.err, "%s*Entering a new prompt%. .*]>%s*", ""), comment_prefix)
  else
    return {(comment_prefix .. "Empty result")}
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
local function build_switch_module_command(context0)
  return (",m " .. context0)
end
local function init_module(repl, context0)
  log.dbg(("Initializing module for context " .. context0))
  local function _9_(_)
  end
  return repl.send((build_switch_module_command(context0) .. "\n,import " .. base_module), _9_)
end
local function ensure_module_initialized(repl, context0)
  if not a["get-in"](state(), {"known-contexts", context0}) then
    init_module(repl, context0)
    return a["assoc-in"](state(), {"known-contexts", context0}, true)
  else
    return nil
  end
end
local function eval_str(opts)
  local function _11_(repl)
    local context0 = (opts.context or default_context)
    ensure_module_initialized(repl, context0)
    local tmp_3_ = (build_switch_module_command(context0) .. "\n" .. opts.code)
    if (nil ~= tmp_3_) then
      local tmp_3_0 = clean_input_code(tmp_3_)
      if (nil ~= tmp_3_0) then
        local function _12_(msgs)
          if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
            a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result"))
          else
          end
          if opts["on-result"] then
            opts["on-result"](str.join("\n", format_message(a.last(msgs))))
          else
          end
          return a["run!"](display_result, msgs)
        end
        return repl.send(tmp_3_0, _12_, {["batch?"] = true})
      else
        return nil
      end
    else
      return nil
    end
  end
  return with_repl_or_warn(_11_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function doc_str(opts)
  local function _17_(_241)
    return ("(procedure-documentation " .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _17_))
end
local function display_repl_status()
  local repl = state("repl")
  log.dbg(a.str("client.guile.socket: repl=", repl))
  if repl then
    local _18_
    do
      local pipename = a["get-in"](repl, {"opts", "pipename"})
      local host_port = a["get-in"](repl, {"opts", "host-port"})
      if pipename then
        _18_ = (pipename .. " ")
      elseif host_port then
        _18_ = (host_port .. " ")
      else
        _18_ = "no pipename & no host-port"
      end
    end
    local _20_
    do
      local err = a.get(repl, "err")
      if err then
        _20_ = (" " .. err)
      else
        _20_ = ""
      end
    end
    return log.append({(comment_prefix .. _18_ .. "(" .. repl.status .. _20_ .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
local function disconnect()
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
local function parse_guile_result(s)
  local prompt = s:find("scheme@%([%w%-%s]+%)> ")
  if prompt then
    local ind1, _, result = s:find("%$%d+ = ([^\n]+)\n")
    local stray_output
    local _24_
    if result then
      _24_ = ind1
    else
      _24_ = prompt
    end
    stray_output = s:sub(1, (_24_ - 1))
    if (#stray_output > 0) then
      log.append(text["prefixed-lines"](text["trim-last-newline"](stray_output), "; (out) "))
    else
    end
    return {["done?"] = true, result = result, ["error?"] = false}
  elseif s:find("scheme@%([%w%-%s]+%) %[%d+%]>") then
    return {["done?"] = true, ["error?"] = true, result = nil}
  else
    return {result = s, ["done?"] = false, ["error?"] = false}
  end
end
local function connect(opts)
  disconnect()
  local pipename = cfg({"pipename"})
  local cfg_host_port = cfg({"host-port"})
  local host_port
  if cfg_host_port then
    local _let_28_ = vim.split(cfg_host_port, ":")
    local host = _let_28_[1]
    local port = _let_28_[2]
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
  local function _32_()
    return display_repl_status()
  end
  local function _33_(msg, repl)
    display_result(msg)
    local function _34_()
    end
    return repl.send(",q\n", _34_)
  end
  return a.assoc(state(), "repl", socket.start({["parse-output"] = parse_guile_result, pipename = pipename, ["host-port"] = host_port, ["on-success"] = _32_, ["on-error"] = _33_, ["on-failure"] = disconnect, ["on-close"] = disconnect, ["on-stray-output"] = display_result}))
end
local function on_exit()
  return disconnect()
end
local function on_filetype()
  local function _35_()
    return connect()
  end
  mapping.buf("GuileConnect", cfg({"mapping", "connect"}), _35_, {desc = "Connect to a REPL"})
  return mapping.buf("GuileDisconnect", cfg({"mapping", "disconnect"}), disconnect, {desc = "Disconnect from the REPL"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, connect = connect, context = context, disconnect = disconnect, ["doc-str"] = doc_str, ["eval-file"] = eval_file, ["eval-str"] = eval_str, ["form-node?"] = form_node_3f, ["on-exit"] = on_exit, ["on-filetype"] = on_filetype}
