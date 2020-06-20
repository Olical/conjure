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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", config = "conjure.config2", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.config2"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local config = _2_[2]
local nvim = _2_[3]
local str = _2_[4]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local old__3enew_key = nil
do
  local v_23_0_ = nil
  local function old__3enew_key0(k)
    return string.gsub(string.gsub(string.gsub(string.gsub(k, "^mappings$", "mapping"), "^clients", "filetype_client"), "%?$", ""), "-", "_")
  end
  v_23_0_ = old__3enew_key0
  _0_0["aniseed/locals"]["old->new-key"] = v_23_0_
  old__3enew_key = v_23_0_
end
local old__3enew_client_ks = nil
do
  local v_23_0_ = nil
  local function old__3enew_client_ks0(client)
    if client then
      return a.concat({"client"}, str.split(client, "%."))
    end
  end
  v_23_0_ = old__3enew_client_ks0
  _0_0["aniseed/locals"]["old->new-client-ks"] = v_23_0_
  old__3enew_client_ks = v_23_0_
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
      print("DEPRECATED: Get config through g:conjure#..., this approach will stop working soon.")
      local client_ks = old__3enew_client_ks(client)
      local ks = a.map(old__3enew_key, path)
      return config["get-in"](a.concat(client_ks, ks))
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
      print("DEPRECATED: Set config through g:conjure#..., this approach will stop working soon.")
      local client_ks = old__3enew_client_ks(client)
      local ks = a.map(old__3enew_key, path)
      return config["assoc-in"](a.concat(client_ks, ks), val)
    end
    v_23_0_0 = assoc0
    _0_0["assoc"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["assoc"] = v_23_0_
  assoc = v_23_0_
end
return nil