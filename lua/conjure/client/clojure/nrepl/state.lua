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
local function _2_(...)
  _0_0["aniseed/local-fns"] = {require = {["bencode-stream"] = "conjure.bencode-stream", client = "conjure.client"}}
  return {require("conjure.bencode-stream"), require("conjure.client")}
end
local _1_ = _2_(...)
local bencode_stream = _1_[1]
local client = _1_[2]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local get = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function _3_()
      return {["awaiting-process?"] = false, ["join-next"] = {key = nil}, ["message-queue"] = {}, bs = bencode_stream.new(), conn = nil}
    end
    v_0_0 = (_0_0.get or client["new-state"](_3_))
    _0_0["get"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get"] = v_0_
  get = v_0_
end
return nil