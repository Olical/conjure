local _0_0 = nil
do
  local name_23_0_ = "conjure.lang"
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
  _0_0["aniseed/local-fns"] = {require = {config = "conjure.config", fennel = "conjure.aniseed.fennel", nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.config"), require("conjure.aniseed.fennel"), require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local config = _2_[1]
local fennel = _2_[2]
local nvim = _2_[3]
do local _ = ({nil, _0_0, nil})[2] end
local safe_require = nil
do
  local v_23_0_ = nil
  local function safe_require0(name)
    local ok_3f, result = nil, nil
    local function _3_()
      return require(name)
    end
    ok_3f, result = xpcall(_3_, fennel.traceback)
    if ok_3f then
      return result
    else
      return error(result)
    end
  end
  v_23_0_ = safe_require0
  _0_0["aniseed/locals"]["safe-require"] = v_23_0_
  safe_require = v_23_0_
end
local overrides = nil
do
  local v_23_0_ = (_0_0["aniseed/locals"].overrides or {})
  _0_0["aniseed/locals"]["overrides"] = v_23_0_
  overrides = v_23_0_
end
local with_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function with_filetype0(ft, f, ...)
      overrides.filetype = ft
      do
        local ok_3f, result = pcall(f, ...)
        overrides.filetype = nil
        if ok_3f then
          return result
        else
          return error(result)
        end
      end
    end
    v_23_0_0 = with_filetype0
    _0_0["with-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["with-filetype"] = v_23_0_
  with_filetype = v_23_0_
end
local current = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function current0()
      local ft = (overrides.filetype or nvim.bo.filetype)
      local mod_name = config["filetype->module-name"](ft)
      if mod_name then
        return safe_require(mod_name)
      else
        return error(("No Conjure language for filetype: '" .. ft .. "'"))
      end
    end
    v_23_0_0 = current0
    _0_0["current"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["current"] = v_23_0_
  current = v_23_0_
end
local get = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function get0(k)
      local _3_0 = current()
      if _3_0 then
        return _3_0[k]
      else
        return _3_0
      end
    end
    v_23_0_0 = get0
    _0_0["get"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["get"] = v_23_0_
  get = v_23_0_
end
local call = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function call0(fn_name, ...)
      local f = get(fn_name)
      if f then
        return f(...)
      end
    end
    v_23_0_0 = call0
    _0_0["call"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["call"] = v_23_0_
  call = v_23_0_
end
return nil