local _2afile_2a = "fnl/aniseed/compile.fnl"
local _0_
do
  local name_0_ = "conjure.aniseed.compile"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", fennel = "conjure.aniseed.fennel", fs = "conjure.aniseed.fs", nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local fennel = _local_0_[2]
local fs = _local_0_[3]
local nvim = _local_0_[4]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.aniseed.compile"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local macros_prefix
do
  local v_0_
  do
    local v_0_0
    local function macros_prefix0(code, opts)
      local macros_module = "conjure.aniseed.macros"
      local filename
      do
        local _3_ = a.get(opts, "filename")
        if _3_ then
          filename = string.gsub(_3_, (nvim.fn.getcwd() .. fs["path-sep"]), "")
        else
          filename = _3_
        end
      end
      local _4_
      if filename then
        _4_ = ("\"" .. string.gsub(filename, "\\", "\\\\") .. "\"")
      else
        _4_ = "nil"
      end
      return ("(local *file* " .. _4_ .. ")" .. "(require-macros \"" .. macros_module .. "\")\n" .. code)
    end
    v_0_0 = macros_prefix0
    _0_["macros-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["macros-prefix"] = v_0_
  macros_prefix = v_0_
end
local str
do
  local v_0_
  do
    local v_0_0
    local function str0(code, opts)
      local fnl = fennel.impl()
      local function _3_()
        return fnl.compileString(macros_prefix(code, opts), a.merge({allowedGlobals = false}, opts))
      end
      return xpcall(_3_, fnl.traceback)
    end
    v_0_0 = str0
    _0_["str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["str"] = v_0_
  str = v_0_
end
local file
do
  local v_0_
  do
    local v_0_0
    local function file0(src, dest)
      local code = a.slurp(src)
      local _3_, _4_ = str(code, {filename = src})
      if ((_3_ == false) and (nil ~= _4_)) then
        local err = _4_
        return nvim.err_writeln(err)
      elseif ((_3_ == true) and (nil ~= _4_)) then
        local result = _4_
        fs.mkdirp(fs.basename(dest))
        return a.spit(dest, result)
      end
    end
    v_0_0 = file0
    _0_["file"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["file"] = v_0_
  file = v_0_
end
local glob
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = glob0
    _0_["glob"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["glob"] = v_0_
  glob = v_0_
end
return nil
