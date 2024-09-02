-- [nfnl] Compiled from fnl/conjure/client/clojure/nrepl/debugger.fnl by https://github.com/Olical/nfnl, do not edit.
local autoload = require("nfnl.autoload")
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local elisp = autoload("conjure.remote.transport.elisp")
local extract = autoload("conjure.extract")
local log = autoload("conjure.log")
local server = autoload("conjure.client.clojure.nrepl.server")
local str = autoload("conjure.aniseed.string")
local text = autoload("conjure.text")
local state = {["last-request"] = nil}
local function init()
  log.append({"; Initialising CIDER debugger"}, {["break?"] = true})
  local function _1_(msg)
    log.append({"; CIDER debugger initialized"}, {["break?"] = true})
    return log.dbg("init-debugger response", msg)
  end
  server.send({op = "init-debugger"}, _1_)
  return nil
end
local function send(opts)
  local key = a["get-in"](state, {"last-request", "key"})
  if key then
    local function _2_(msg)
      log.dbg("debug-input response", msg)
      state["last-request"] = nil
      return nil
    end
    return server.send({op = "debug-input", input = a.get(opts, "input"), key = key}, _2_)
  else
    return log.append({"; Debugger is not awaiting input"}, {["break?"] = true})
  end
end
local function valid_inputs()
  local input_types = a["get-in"](state, {"last-request", "input-type"})
  local function _4_(input_type)
    return ("stacktrace" ~= input_type)
  end
  return a.filter(_4_, (input_types or {}))
end
local function render_inspect(inspect)
  local function _5_(v)
    if a["table?"](v) then
      local head = a.first(v)
      if ("newline" == head) then
        return "\n"
      elseif ("value" == head) then
        return a.second(v)
      else
        return nil
      end
    else
      return v
    end
  end
  return str.join(a.map(_5_, inspect))
end
local function handle_input_request(msg)
  state["last-request"] = msg
  log.append({"; CIDER debugger"}, {["break?"] = true})
  if not a["empty?"](msg.inspect) then
    log.append(text["prefixed-lines"](render_inspect(elisp.read(msg.inspect)), "; ", {}), {})
  else
  end
  if not a["nil?"](msg["debug-value"]) then
    log.append({a.str("; Evaluation result => ", msg["debug-value"])}, {})
  else
  end
  if a["empty?"](msg.prompt) then
    return log.append({"; Respond with :ConjureCljDebugInput [input]", ("; Inputs: " .. str.join(", ", valid_inputs()))}, {})
  else
    return send({input = extract.prompt(msg.prompt)})
  end
end
local function debug_input(opts)
  local function _11_(_241)
    return (opts.args == _241)
  end
  if a.some(_11_, valid_inputs()) then
    return send({input = (":" .. opts.args)})
  else
    return log.append({("; Valid inputs: " .. str.join(", ", valid_inputs()))})
  end
end
return {["debug-input"] = debug_input, ["handle-input-request"] = handle_input_request, init = init, ["render-inspect"] = render_inspect, send = send, state = state, ["valid-inputs"] = valid_inputs}
