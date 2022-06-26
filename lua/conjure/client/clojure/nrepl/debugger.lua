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
local a, elisp, log, server = autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.elisp"), autoload("conjure.log"), autoload("conjure.client.clojure.nrepl.server")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["elisp"] = elisp
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["server"] = server
local dap
local function _1_(...)
  local ok_3f, dap0 = pcall(require, "dap")
  if ok_3f then
    return dap0
  else
    log.append({";; nvim-dap is required for debugging support https://github.com/mfussenegger/nvim-dap"}, {["break?"] = true})
    return nil
  end
end
dap = ((_2amodule_2a).dap or _1_(...))
do end (_2amodule_2a)["dap"] = dap
if dap then
  local function _3_(cb, config)
    if ("attach" == config.request) then
      return a.println("I think here's where we connect to Conjure's internal DAP server")
    else
      return nil
    end
  end
  dap.adapters.clojure = _3_
else
end
local function init()
  local function _6_(...)
    return a.println(...)
  end
  return server.send({op = "init-debugger"}, _6_)
end
_2amodule_2a["init"] = init
local function send(opts)
  local function _7_(...)
    return a.println(...)
  end
  return server.send({op = "debug-input", input = (":" .. a.get(opts, "input")), key = a.get(opts, "key")}, _7_)
end
_2amodule_2a["send"] = send
local function handle_input_request(msg)
  return a.println(msg)
end
_2amodule_2a["handle-input-request"] = handle_input_request
return _2amodule_2a