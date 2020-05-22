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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local nvim = _2_[2]
local str = _2_[3]
do local _ = ({nil, _0_0, nil})[2] end
local debug_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = false
    _0_0["debug?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["debug?"] = v_23_0_
  debug_3f = v_23_0_
end
local clients = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", janet = "conjure.client.janet.netrepl"}
    _0_0["clients"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["clients"] = v_23_0_
  clients = v_23_0_
end
local eval = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["result-register"] = "c"}
    _0_0["eval"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval"] = v_23_0_
  eval = v_23_0_
end
local mappings = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["def-word"] = {"gd"}, ["doc-word"] = {"K"}, ["eval-buf"] = "eb", ["eval-current-form"] = "ee", ["eval-file"] = "ef", ["eval-marked-form"] = "em", ["eval-motion"] = "E", ["eval-replace-form"] = "e!", ["eval-root-form"] = "er", ["eval-visual"] = "E", ["eval-word"] = "ew", ["log-close-visible"] = "lq", ["log-split"] = "ls", ["log-tab"] = "lt", ["log-vsplit"] = "lv", prefix = "<localleader>"}
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
    local v_23_0_0 = {["break-length"] = 80, hud = {["enabled?"] = true, height = 0.29999999999999999, width = 0.41999999999999998}, trim = {at = 10000, to = 6000}}
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
    local v_23_0_0 = {["context-header-lines"] = 24, ["form-pairs"] = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}}
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
      return a.keys(clients)
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
      return clients[filetype]
    end
    v_23_0_0 = filetype__3emodule_name0
    _0_0["filetype->module-name"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["filetype->module-name"] = v_23_0_
  filetype__3emodule_name = v_23_0_
end
local require_client = nil
do
  local v_23_0_ = nil
  local function require_client0(suffix)
    local attempts = {("conjure.client." .. suffix), suffix}
    local function _3_(name)
      local ok_3f, mod_or_err = nil, nil
      local function _4_()
        return require(name)
      end
      ok_3f, mod_or_err = pcall(_4_)
      if ok_3f then
        return mod_or_err
      end
    end
    return (a.some(_3_, attempts) or error(("No Conjure client found, attempted: " .. str.join(", ", attempts))))
  end
  v_23_0_ = require_client0
  _0_0["aniseed/locals"]["require-client"] = v_23_0_
  require_client = v_23_0_
end
local get = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function get0(_3_0)
      local _4_ = _3_0
      local client = _4_["client"]
      local path = _4_["path"]
      local _5_
      if client then
        _5_ = a.get(require_client(client), "config")
      else
        _5_ = require("conjure.config")
      end
      return a["get-in"](_5_, path)
    end
    v_23_0_0 = get0
    _0_0["get"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["get"] = v_23_0_
  get = v_23_0_
end
local assoc = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function assoc0(_3_0)
      local _4_ = _3_0
      local client = _4_["client"]
      local path = _4_["path"]
      local val = _4_["val"]
      local _5_
      if client then
        _5_ = a.get(require_client(client), "config")
      else
        _5_ = require("conjure.config")
      end
      return a["assoc-in"](_5_, path, val)
    end
    v_23_0_0 = assoc0
    _0_0["assoc"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["assoc"] = v_23_0_
  assoc = v_23_0_
end
local env = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function env0(k)
      local v = nvim.fn.getenv(k)
      if (a["string?"](v) and not a["empty?"](v)) then
        return v
      end
    end
    v_23_0_0 = env0
    _0_0["env"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["env"] = v_23_0_
  env = v_23_0_
end
return nil