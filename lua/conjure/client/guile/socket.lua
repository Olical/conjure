-- [nfnl] Compiled from fnl/conjure/client/guile/socket.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.guile.socket"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, client, config, extract, log, mapping, nvim, socket, str, text, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.socket"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["socket"] = socket
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["_"] = _
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
config.merge({client = {guile = {socket = {pipename = nil}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {guile = {socket = {mapping = {connect = "cc", disconnect = "cd"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "guile", "socket"})
do end (_2amodule_locals_2a)["cfg"] = cfg
do local _ = {nil, nil} end
local state
local function _2_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_2_))
do end (_2amodule_locals_2a)["state"] = state
do local _ = {nil, nil} end
local buf_suffix = ".scm"
_2amodule_2a["buf-suffix"] = buf_suffix
do local _ = {nil, nil} end
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
do local _ = {nil, nil} end
local context_pattern = "%(define%-module%s+(%([%g%s]-%))"
_2amodule_2a["context-pattern"] = context_pattern
do local _ = {nil, nil} end
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
do local _ = {nil, nil} end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if (repl and ("connected" == repl.status)) then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
do local _ = {with_repl_or_warn, nil} end
local function format_message(msg)
  if msg.out then
    return text["split-lines"](msg.out)
  elseif msg.err then
    return text["prefixed-lines"](string.gsub(msg.err, "%s*Entering a new prompt%. .*]>%s*", ""), comment_prefix)
  else
    return {(comment_prefix .. "Empty result")}
  end
end
_2amodule_locals_2a["format-message"] = format_message
do local _ = {format_message, nil} end
local function display_result(msg)
  local function _5_(_241)
    return ("" ~= _241)
  end
  return log.append(a.filter(_5_, format_message(msg)))
end
_2amodule_locals_2a["display-result"] = display_result
do local _ = {display_result, nil} end
local function clean_input_code(code)
  local clean = str.trim(code)
  if not str["blank?"](clean) then
    return clean
  else
    return nil
  end
end
_2amodule_locals_2a["clean-input-code"] = clean_input_code
do local _ = {clean_input_code, nil} end
local function eval_str(opts)
  local function _7_(repl)
    local _8_ = (",m " .. (opts.context or "(guile-user)") .. "\n" .. opts.code)
    if (nil ~= _8_) then
      local _9_ = clean_input_code(_8_)
      if (nil ~= _9_) then
        local function _10_(msgs)
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
        return repl.send(_9_, _10_, {["batch?"] = true})
      else
        return _9_
      end
    else
      return _8_
    end
  end
  return with_repl_or_warn(_7_)
end
_2amodule_2a["eval-str"] = eval_str
do local _ = {eval_str, nil} end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
_2amodule_2a["eval-file"] = eval_file
do local _ = {eval_file, nil} end
local function doc_str(opts)
  local function _15_(_241)
    return ("(procedure-documentation " .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _15_))
end
_2amodule_2a["doc-str"] = doc_str
do local _ = {doc_str, nil} end
local function display_repl_status()
  local repl = state("repl")
  if repl then
    local function _16_()
      local pipename = a["get-in"](repl, {"opts", "pipename"})
      if pipename then
        return (pipename .. " ")
      else
        return ""
      end
    end
    local function _18_()
      local err = a.get(repl, "err")
      if err then
        return (" " .. err)
      else
        return ""
      end
    end
    return log.append({(comment_prefix .. _16_() .. "(" .. repl.status .. _18_() .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
do local _ = {display_repl_status, nil} end
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
_2amodule_2a["disconnect"] = disconnect
do local _ = {disconnect, nil} end
local function parse_guile_result(s)
  local prompt = s:find("scheme@%([%w%-%s]+%)> ")
  if prompt then
    local ind1, _0, result = s:find("%$%d+ = ([^\n]+)\n")
    local stray_output
    local function _22_()
      if result then
        return ind1
      else
        return prompt
      end
    end
    stray_output = s:sub(1, (_22_() - 1))
    if (#stray_output > 0) then
      log.append(text["prefixed-lines"](text["trim-last-newline"](stray_output), "; (out) "))
    else
    end
    return {["done?"] = true, result = result, ["error?"] = false}
  elseif s:find("scheme@%([%w%-%s]+%) %[%d+%]>") then
    return {["done?"] = true, ["error?"] = true, result = nil}
  else
    return {result = s, ["error?"] = false, ["done?"] = false}
  end
end
_2amodule_locals_2a["parse-guile-result"] = parse_guile_result
do local _ = {parse_guile_result, nil} end
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
_2amodule_2a["connect"] = connect
do local _ = {connect, nil} end
local function on_exit()
  return disconnect()
end
_2amodule_2a["on-exit"] = on_exit
do local _ = {on_exit, nil} end
local function on_filetype()
  local function _29_()
    return connect()
  end
  mapping.buf("GuileConnect", cfg({"mapping", "connect"}), _29_, {desc = "Connect to a REPL"})
  return mapping.buf("GuileDisconnect", cfg({"mapping", "disconnect"}), disconnect, {desc = "Disconnect from the REPL"})
end
_2amodule_2a["on-filetype"] = on_filetype
do local _ = {on_filetype, nil} end
return _2amodule_2a
