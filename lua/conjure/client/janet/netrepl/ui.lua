local _0_0 = nil
do
  local name_0_ = "conjure.client.janet.netrepl.ui"
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
  _0_0["aniseed/local-fns"] = {require = {client = "conjure.client", log = "conjure.log"}}
  return {require("conjure.client"), require("conjure.log")}
end
local _2_ = _1_(...)
local client = _2_[1]
local log = _2_[2]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local display = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display0(lines, opts)
      return client["with-filetype"]("janet", log.append, lines, opts)
    end
    v_0_0 = display0
    _0_0["display"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["display"] = v_0_
  display = v_0_
end
return nil