local _0_0 = nil
do
  local name_23_0_ = "conjure.net"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core"}}
  return {require("conjure.aniseed.core")}
end
local _2_ = _1_(...)
local a = _2_[1]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local resolve = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function resolve0(host)
      local function _3_(_241)
        return ("inet" == a.get(_241, "family"))
      end
      return a.get(a.first(a.filter(_3_, vim.loop.getaddrinfo(host))), "addr")
    end
    v_23_0_0 = resolve0
    _0_0["resolve"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["resolve"] = v_23_0_
  resolve = v_23_0_
end
return nil