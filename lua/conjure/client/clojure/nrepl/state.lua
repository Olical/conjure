local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.clojure.nrepl.state"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.client")}
local client = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.state"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local get
do
  local v_0_
  local function _1_()
    return {["join-next"] = {key = nil}, conn = nil}
  end
  v_0_ = client["new-state"](_1_)
  _0_0["get"] = v_0_
  get = v_0_
end
return nil