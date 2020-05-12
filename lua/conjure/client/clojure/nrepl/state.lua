local _0_0 = nil
do
  local name_23_0_ = "conjure.client.clojure.nrepl.state"
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
  _0_0["aniseed/local-fns"] = {require = {["bencode-stream"] = "conjure.bencode-stream"}}
  return {require("conjure.bencode-stream")}
end
local _2_ = _1_(...)
local bencode_stream = _2_[1]
do local _ = ({nil, _0_0, nil})[2] end
local conn = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = (_0_0.conn or nil)
    _0_0["conn"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["conn"] = v_23_0_
  conn = v_23_0_
end
local bs = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = (_0_0.bs or bencode_stream.new())
    _0_0["bs"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["bs"] = v_23_0_
  bs = v_23_0_
end
local message_queue = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = (_0_0["message-queue"] or {})
    _0_0["message-queue"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["message-queue"] = v_23_0_
  message_queue = v_23_0_
end
return nil