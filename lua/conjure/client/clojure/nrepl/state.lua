local _2afile_2a = "fnl/conjure/client/clojure/nrepl/state.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.state"
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
local client = autoload("conjure.client")
do end (_2amodule_locals_2a)["client"] = client
local get
local function _1_()
  return {conn = nil, ["auto-repl-port"] = nil, ["auto-repl-proc"] = nil, ["join-next"] = {key = nil}}
end
get = ((_2amodule_2a).get or client["new-state"](_1_))
do end (_2amodule_2a)["get"] = get
return _2amodule_2a