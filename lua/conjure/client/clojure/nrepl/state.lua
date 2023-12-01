-- [nfnl] Compiled from fnl/conjure/client/clojure/nrepl/state.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.clojure.nrepl.state"
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
local client = autoload("conjure.client")
do end (_2amodule_locals_2a)["client"] = client
do local _ = {nil, nil, nil, nil, nil, nil} end
local get
local function _1_()
  return {conn = nil, ["auto-repl-port"] = nil, ["auto-repl-proc"] = nil, ["join-next"] = {key = nil}}
end
get = ((_2amodule_2a).get or client["new-state"](_1_))
do end (_2amodule_2a)["get"] = get
do local _ = {nil, nil} end
return _2amodule_2a
