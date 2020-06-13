local _0_0 = nil
do
  local name_23_0_ = "conjure.client.clojure.nrepl.config"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {}
  return {}
end
local _2_ = _1_(...)
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local connection = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["default-host"] = "localhost", ["port-files"] = {".nrepl-port", ".shadow-cljs/nrepl.port"}}
    _0_0["connection"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connection"] = v_23_0_
  connection = v_23_0_
end
local eval = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["auto-require?"] = true, ["pretty-print?"] = true}
    _0_0["eval"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval"] = v_23_0_
  eval = v_23_0_
end
local debug_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = false
    _0_0["debug?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["debug?"] = v_23_0_
  debug_3f = v_23_0_
end
local interrupt = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["sample-limit"] = 0.29999999999999999}
    _0_0["interrupt"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["interrupt"] = v_23_0_
  interrupt = v_23_0_
end
local refresh = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {after = nil, before = nil, dirs = nil}
    _0_0["refresh"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["refresh"] = v_23_0_
  refresh = v_23_0_
end
local mappings = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["connect-port-file"] = "cf", ["last-exception"] = "ve", ["refresh-all"] = "ra", ["refresh-changed"] = "rr", ["refresh-clear"] = "rc", ["result-1"] = "v1", ["result-2"] = "v2", ["result-3"] = "v3", ["run-all-tests"] = "ta", ["run-alternate-ns-tests"] = "tN", ["run-current-ns-tests"] = "tn", ["run-current-test"] = "tc", ["session-clone"] = "sc", ["session-close"] = "sq", ["session-close-all"] = "sQ", ["session-fresh"] = "sf", ["session-list"] = "sl", ["session-next"] = "sn", ["session-prev"] = "sp", ["session-select"] = "ss", ["session-type"] = "st", ["view-source"] = "vs", disconnect = "cd", interrupt = "ei"}
    _0_0["mappings"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["mappings"] = v_23_0_
  mappings = v_23_0_
end
return nil