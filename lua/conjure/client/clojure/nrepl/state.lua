local _0_0 = nil
do
  local name_0_ = "conjure.client.clojure.nrepl.state"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {["bencode-stream"] = "conjure.bencode-stream"}}
  return {require("conjure.bencode-stream")}
end
local _2_ = _1_(...)
local bencode_stream = _2_[1]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local conn = nil
do
  local v_0_ = nil
  do
    local v_0_0 = (_0_0.conn or nil)
    _0_0["conn"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["conn"] = v_0_
  conn = v_0_
end
local bs = nil
do
  local v_0_ = nil
  do
    local v_0_0 = (_0_0.bs or bencode_stream.new())
    _0_0["bs"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["bs"] = v_0_
  bs = v_0_
end
local message_queue = nil
do
  local v_0_ = nil
  do
    local v_0_0 = (_0_0["message-queue"] or {})
    _0_0["message-queue"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["message-queue"] = v_0_
  message_queue = v_0_
end
local awaiting_process_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = (_0_0["awaiting-process?"] or false)
    _0_0["awaiting-process?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["awaiting-process?"] = v_0_
  awaiting_process_3f = v_0_
end
return nil