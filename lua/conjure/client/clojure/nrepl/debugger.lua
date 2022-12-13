local _2afile_2a = "fnl/conjure/client/clojure/nrepl/debugger.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.debugger"
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
local a, client, elisp, extract, log, server, str, text = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.remote.transport.elisp"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["elisp"] = elisp
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["server"] = server
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local state = ((_2amodule_2a).state or {["last-request"] = nil})
do end (_2amodule_2a)["state"] = state
local function init()
  log.append({"; Initialising CIDER debugger"}, {["break?"] = true})
  local function _1_(msg)
    log.append({"; CIDER debugger initialized"}, {["break?"] = true})
    return log.dbg("init-debugger response", msg)
  end
  server.send({op = "init-debugger"}, _1_)
  return nil
end
_2amodule_2a["init"] = init
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
_2amodule_2a["send"] = send
local function valid_inputs()
  local input_types = a["get-in"](state, {"last-request", "input-type"})
  local function _4_(input_type)
    return ("stacktrace" ~= input_type)
  end
  return a.filter(_4_, (input_types or {}))
end
_2amodule_2a["valid-inputs"] = valid_inputs
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
_2amodule_2a["render-inspect"] = render_inspect
local function handle_input_request(msg)
  state["last-request"] = msg
  log.append({"; CIDER debugger"}, {["break?"] = true})
  if not a["empty?"](msg.inspect) then
    log.append(text["prefixed-lines"](render_inspect(elisp.read(msg.inspect)), "; ", {}), {})
  else
  end
  if a["empty?"](msg.prompt) then
    return log.append({"; Respond with :ConjureCljDebugInput [input]", ("; Inputs: " .. str.join(", ", valid_inputs()))}, {})
  else
    return send({input = extract.prompt(msg.prompt)})
  end
end
_2amodule_2a["handle-input-request"] = handle_input_request
local function debug_input(opts)
  local function _10_(_241)
    return (opts.args == _241)
  end
  if a.some(_10_, valid_inputs()) then
    return send({input = (":" .. opts.args)})
  else
    return log.append({("; Valid inputs: " .. str.join(", ", valid_inputs()))})
  end
end
_2amodule_2a["debug-input"] = debug_input
return _2amodule_2a