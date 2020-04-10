local _0_0 = nil
do
  local name_23_0_ = "conjure.config"
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
do local _ = ({nil, _0_0, nil})[2] end
local langs = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {clojure = "conjure.lang.clojure-nrepl", fennel = "conjure.lang.fennel-aniseed"}
    _0_0["langs"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["langs"] = v_23_0_
  langs = v_23_0_
end
local mappings = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["close-hud"] = "q", ["def-word"] = {"gd"}, ["doc-word"] = {"K"}, ["eval-buf"] = "eb", ["eval-current-form"] = "ee", ["eval-file"] = "ef", ["eval-marked-form"] = "em", ["eval-motion"] = "E", ["eval-root-form"] = "er", ["eval-visual"] = "E", ["eval-word"] = "ew", ["log-split"] = "ls", ["log-tab"] = "lt", ["log-vsplit"] = "lv", prefix = "<localleader>"}
    _0_0["mappings"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["mappings"] = v_23_0_
  mappings = v_23_0_
end
local log = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["break-length"] = 0.41999999999999998, hud = {["enabled?"] = true, height = 0.29999999999999999, width = 0.41999999999999998}, trim = {at = 10000, to = 7000}}
    _0_0["log"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["log"] = v_23_0_
  log = v_23_0_
end
local extract = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["context-header-lines"] = 24}
    _0_0["extract"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["extract"] = v_23_0_
  extract = v_23_0_
end
local preview = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["sample-limit"] = 0.29999999999999999}
    _0_0["preview"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["preview"] = v_23_0_
  preview = v_23_0_
end
local filetypes = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function filetypes0()
      return a.keys(langs)
    end
    v_23_0_0 = filetypes0
    _0_0["filetypes"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["filetypes"] = v_23_0_
  filetypes = v_23_0_
end
local filetype__3emodule_name = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function filetype__3emodule_name0(filetype)
      return langs[filetype]
    end
    v_23_0_0 = filetype__3emodule_name0
    _0_0["filetype->module-name"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["filetype->module-name"] = v_23_0_
  filetype__3emodule_name = v_23_0_
end
return nil