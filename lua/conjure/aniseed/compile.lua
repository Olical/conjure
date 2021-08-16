local _2afile_2a = "fnl/aniseed/compile.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.compile"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", fennel = "conjure.aniseed.fennel", fs = "conjure.aniseed.fs", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local fennel = _local_4_[2]
local fs = _local_4_[3]
local nvim = _local_4_[4]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.compile"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local macros_prefix
do
  local v_23_auto
  do
    local v_25_auto
    local function macros_prefix0(code, opts)
      local macros_module = "conjure.aniseed.macros"
      local filename
      do
        local _8_ = a.get(opts, "filename")
        if _8_ then
          filename = string.gsub(_8_, (nvim.fn.getcwd() .. fs["path-sep"]), "")
        else
          filename = _8_
        end
      end
      local _10_
      if filename then
        _10_ = ("\"" .. string.gsub(filename, "\\", "\\\\") .. "\"")
      else
        _10_ = "nil"
      end
      return ("(local *file* " .. _10_ .. ")" .. "(require-macros \"" .. macros_module .. "\")\n" .. (code or ""))
    end
    v_25_auto = macros_prefix0
    _1_["macros-prefix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["macros-prefix"] = v_23_auto
  macros_prefix = v_23_auto
end
local str
do
  local v_23_auto
  do
    local v_25_auto
    local function str0(code, opts)
      local fnl = fennel.impl()
      local function _12_()
        return fnl.compileString(macros_prefix(code, opts), a.merge({allowedGlobals = false, compilerEnv = _G}, opts))
      end
      return xpcall(_12_, fnl.traceback)
    end
    v_25_auto = str0
    _1_["str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["str"] = v_23_auto
  str = v_23_auto
end
local file
do
  local v_23_auto
  do
    local v_25_auto
    local function file0(src, dest)
      local code = a.slurp(src)
      local _13_, _14_ = str(code, {filename = src})
      if ((_13_ == false) and (nil ~= _14_)) then
        local err = _14_
        return nvim.err_writeln(err)
      elseif ((_13_ == true) and (nil ~= _14_)) then
        local result = _14_
        fs.mkdirp(fs.basename(dest))
        return a.spit(dest, result)
      end
    end
    v_25_auto = file0
    _1_["file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["file"] = v_23_auto
  file = v_23_auto
end
local glob
do
  local v_23_auto
  do
    local v_25_auto
    local function glob0(src_expr, src_dir, dest_dir)
      for _, path in ipairs(fs.relglob(src_dir, src_expr)) do
        if fs["macro-file-path?"](path) then
          a.spit((dest_dir .. path), a.slurp((src_dir .. path)))
        else
          file((src_dir .. path), string.gsub((dest_dir .. path), ".fnl$", ".lua"))
        end
      end
      return nil
    end
    v_25_auto = glob0
    _1_["glob"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["glob"] = v_23_auto
  glob = v_23_auto
end
return nil
