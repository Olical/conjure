-- [nfnl] Compiled from fnl/conjure/client/guile/socket.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local extract = autoload("conjure.extract")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local socket = autoload("conjure.remote.socket")
local str = autoload("conjure.aniseed.string")
local text = autoload("conjure.text")
local ts = autoload("conjure.tree-sitter")
config.merge({client = {guile = {socket = {pipename = nil}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {guile = {socket = {mapping = {connect = "cc", disconnect = "cd"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "guile", "socket"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local buf_suffix = ".scm"
local comment_prefix = "; "
local context_pattern = "%(define%-module%s+(%([%g%s]-%))"
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
  local function _6_(_241)
    return ("" ~= _241)
  end
  return log.append(a.filter(_6_, format_message(msg)))
end
local function clean_input_code(code)
  local clean = str.trim(code)
  if not str["blank?"](clean) then
    return clean
  else
    return nil
  end
end
local function eval_str(opts)
  local function _8_(repl)
    local tmp_3_auto = (",m " .. (opts.context or "(guile-user)") .. "\n" .. opts.code)
    if (nil ~= tmp_3_auto) then
      local tmp_3_auto0 = clean_input_code(tmp_3_auto)
      if (nil ~= tmp_3_auto0) then
        local function _9_(msgs)
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
        return repl.send(tmp_3_auto0, _9_, {["batch?"] = true})
      else
        return nil
      end
    else
      return nil
    end
  end
  return with_repl_or_warn(_8_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function doc_str(opts)
  local function _14_(_241)
    return ("(procedure-documentation " .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _14_))
end
local function display_repl_status()
  local repl = state("repl")
  if repl then
    local _15_
    do
      local pipename = a["get-in"](repl, {"opts", "pipename"})
      if pipename then
        _15_ = (pipename .. " ")
      else
        _15_ = ""
      end
    end
    local _17_
    do
      local err = a.get(repl, "err")
      if err then
        _17_ = (" " .. err)
      else
        _17_ = ""
      end
    end
    return log.append({(comment_prefix .. _15_ .. "(" .. repl.status .. _17_ .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
local function disconnect()
  local repl = state("repl")
  if repl then
    repl.destroy()
    a.assoc(repl, "status", "disconnected")
    display_repl_status()
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
local function parse_guile_result(s)
  local prompt = s:find("scheme@%([%w%-%s]+%)> ")
  if prompt then
    local ind1, _, result = s:find("%$%d+ = ([^\n]+)\n")
    local stray_output
    local _21_
    if result then
      _21_ = ind1
    else
      _21_ = prompt
    end
    stray_output = s:sub(1, (_21_ - 1))
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
  local pipename = (cfg({"pipename"}) or a.get(opts, "port"))
  if ("string" ~= type(pipename)) then
    return log.append({(comment_prefix .. "g:conjure#client#guile#socket#pipename is not specified"), (comment_prefix .. "Please set it to the name of your Guile REPL pipe or pass it to :ConjureConnect [pipename]")})
  else
    local function _25_()
      return display_repl_status()
    end
    local function _26_(msg, repl)
      display_result(msg)
      local function _27_()
      end
      return repl.send(",q\n", _27_)
    end
    return a.assoc(state(), "repl", socket.start({["parse-output"] = parse_guile_result, pipename = pipename, ["on-success"] = _25_, ["on-error"] = _26_, ["on-failure"] = disconnect, ["on-close"] = disconnect, ["on-stray-output"] = display_result}))
  end
end
local function on_exit()
  return disconnect()
end
local function on_filetype()
  local function _29_()
    return connect()
  end
  mapping.buf("GuileConnect", cfg({"mapping", "connect"}), _29_, {desc = "Connect to a REPL"})
  return mapping.buf("GuileDisconnect", cfg({"mapping", "disconnect"}), disconnect, {desc = "Disconnect from the REPL"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, connect = connect, ["context-pattern"] = context_pattern, disconnect = disconnect, ["doc-str"] = doc_str, ["eval-file"] = eval_file, ["eval-str"] = eval_str, ["form-node?"] = form_node_3f, ["on-exit"] = on_exit, ["on-filetype"] = on_filetype}
