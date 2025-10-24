-- [nfnl] fnl/conjure/client/clojure/nrepl/debugger.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local elisp = autoload("conjure.remote.transport.elisp")
local extract = autoload("conjure.extract")
local log = autoload("conjure.log")
local server = autoload("conjure.client.clojure.nrepl.server")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local M = define("conjure.client.clojure.nrepl.debugger")
M.state = {["last-request"] = nil}
M.init = function()
  log.append({"; Initialising CIDER debugger"}, {["break?"] = true})
  local function _2_(msg)
    log.append({"; CIDER debugger initialized"}, {["break?"] = true})
    return log.dbg("init-debugger response", msg)
  end
  server.send({op = "init-debugger"}, _2_)
  return nil
end
M.send = function(opts)
  local key = core["get-in"](M.state, {"last-request", "key"})
  if key then
    local function _3_(msg)
      log.dbg("debug-input response", msg)
      M.state["last-request"] = nil
      return nil
    end
    return server.send({op = "debug-input", input = core.get(opts, "input"), key = key}, _3_)
  else
    return log.append({"; Debugger is not awaiting input"}, {["break?"] = true})
  end
end
M["valid-inputs"] = function()
  local input_types = core["get-in"](M.state, {"last-request", "input-type"})
  local function _5_(input_type)
    return ("stacktrace" ~= input_type)
  end
  return core.filter(_5_, (input_types or {}))
end
M["render-inspect"] = function(inspect)
  local function _6_(v)
    if core["table?"](v) then
      local head = core.first(v)
      if ("newline" == head) then
        return "\n"
      elseif ("value" == head) then
        return core.second(v)
      else
        return nil
      end
    else
      return v
    end
  end
  return str.join(core.map(_6_, inspect))
end
M["handle-input-request"] = function(msg)
  M.state["last-request"] = msg
  log.append({"; CIDER debugger"}, {["break?"] = true})
  if not core["empty?"](msg.inspect) then
    log.append(text["prefixed-lines"](M["render-inspect"](elisp.read(msg.inspect)), "; ", {}), {})
  else
  end
  if not core["nil?"](msg["debug-value"]) then
    log.append({core.str("; Evaluation result => ", msg["debug-value"])}, {})
  else
  end
  if core["empty?"](msg.prompt) then
    return log.append({"; Respond with :ConjureCljDebugInput [input]", ("; Inputs: " .. str.join(", ", M["valid-inputs"]()))}, {})
  else
    return M.send({input = extract.prompt(msg.prompt)})
  end
end
M["debug-input"] = function(opts)
  local function _12_(_241)
    return (opts.args == _241)
  end
  if core.some(_12_, M["valid-inputs"]()) then
    return M.send({input = (":" .. opts.args)})
  else
    return log.append({("; Valid inputs: " .. str.join(", ", M["valid-inputs"]()))})
  end
end
return M
