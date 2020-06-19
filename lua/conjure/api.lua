local _0_0 = nil
do
  local name_23_0_ = "conjure.api"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", eval = "conjure.eval", log = "conjure.log"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.eval"), require("conjure.log")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local eval = _2_[3]
local log = _2_[4]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local eval_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_str0(opts)
      return eval["eval-str"](a.merge({origin = "api"}, opts))
    end
    v_23_0_0 = eval_str0
    _0_0["eval-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_23_0_
  eval_str = v_23_0_
end
local display = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display0(lines, opts)
      if not a.get(opts, "filetype") then
        error("opts.filetype must be set")
      end
      return client["with-filetype"](opts.filetype, log.append, lines, opts)
    end
    v_23_0_0 = display0
    _0_0["display"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display"] = v_23_0_
  display = v_23_0_
end
              -- (eval-str table: 0x4195a7e8) (display table: 0x40d5bee8 table: 0x40d5de28)
return nil