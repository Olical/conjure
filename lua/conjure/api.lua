local _0_0 = nil
do
  local name_0_ = "conjure.api"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", eval = "conjure.eval", log = "conjure.log"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.eval"), require("conjure.log")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local eval = _2_[3]
local log = _2_[4]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local with_filetype = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function with_filetype0(ft, f, ...)
      return client["with-filetype"](ft, f, ...)
    end
    v_0_0 = with_filetype0
    _0_0["with_filetype"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["with_filetype"] = v_0_
  with_filetype = v_0_
end
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
      return eval["eval-str"](a.merge({origin = "api"}, opts))
    end
    v_0_0 = eval_str0
    _0_0["eval_str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval_str"] = v_0_
  eval_str = v_0_
end
local display = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display0(lines, opts)
      return log.append(lines, opts)
    end
    v_0_0 = display0
    _0_0["display"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["display"] = v_0_
  display = v_0_
end
return nil