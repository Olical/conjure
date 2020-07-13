local _0_0 = nil
do
  local name_0_ = "conjure.net"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core"}}
  return {require("conjure.aniseed.core")}
end
local _2_ = _1_(...)
local a = _2_[1]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local resolve = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function resolve0(host)
      local function _3_(_241)
        return ("inet" == a.get(_241, "family"))
      end
      return a.get(a.first(a.filter(_3_, vim.loop.getaddrinfo(host))), "addr")
    end
    v_0_0 = resolve0
    _0_0["resolve"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["resolve"] = v_0_
  resolve = v_0_
end
return nil