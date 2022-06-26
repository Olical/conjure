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
local a, elisp, server = autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.elisp"), autoload("conjure.client.clojure.nrepl.server")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["elisp"] = elisp
_2amodule_locals_2a["server"] = server
local function init()
  local function _1_(...)
    return a.println(...)
  end
  return server.send({op = "init-debugger"}, _1_)
end
_2amodule_2a["init"] = init
local function send(opts)
  local function _2_(...)
    return a.println(...)
  end
  return server.send({op = "debug-input", input = (":" .. a.get(opts, "input")), key = a.get(opts, "key")}, _2_)
end
_2amodule_2a["send"] = send
local function handle_input_request(msg)
  return a.println(msg)
end
_2amodule_2a["handle-input-request"] = handle_input_request
return _2amodule_2a