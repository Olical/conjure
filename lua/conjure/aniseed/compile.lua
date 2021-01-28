local _0_0 = nil
do
  local name_0_ = "conjure.aniseed.compile"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core"), require("conjure.aniseed.fennel"), require("conjure.aniseed.fs"), require("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", fennel = "conjure.aniseed.fennel", fs = "conjure.aniseed.fs", nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local fennel = _local_0_[2]
local fs = _local_0_[3]
local nvim = _local_0_[4]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.compile"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local macros_prefix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function macros_prefix0(code)
      local macros_module = "conjure.aniseed.macros"
      return ("(require-macros \"" .. macros_module .. "\")\n" .. code)
    end
    v_0_0 = macros_prefix0
    _0_0["macros-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["macros-prefix"] = v_0_
  macros_prefix = v_0_
end
local str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function str0(code, opts)
      local function _2_()
        return fennel.compileString(macros_prefix(code), a.merge({["compiler-env"] = _G}, opts))
      end
      return xpcall(_2_, fennel.traceback)
    end
    v_0_0 = str0
    _0_0["str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["str"] = v_0_
  str = v_0_
end
local file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function file0(src, dest, opts)
      if ((a["table?"](opts) and opts.force) or (nvim.fn.getftime(src) > nvim.fn.getftime(dest))) then
        local code = a.slurp(src)
        local _2_0, _3_0 = str(code, {filename = src})
        if ((_2_0 == false) and (nil ~= _3_0)) then
          local err = _3_0
          return nvim.err_writeln(err)
        elseif ((_2_0 == true) and (nil ~= _3_0)) then
          local result = _3_0
          fs.mkdirp(fs.basename(dest))
          return a.spit(dest, result)
        end
      end
    end
    v_0_0 = file0
    _0_0["file"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["file"] = v_0_
  file = v_0_
end
local glob = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function glob0(src_expr, src_dir, dest_dir, opts)
      local src_dir_len = a.inc(string.len(src_dir))
      local src_paths = nil
      local function _2_(path)
        return string.sub(path, src_dir_len)
      end
      src_paths = a.map(_2_, nvim.fn.globpath(src_dir, src_expr, true, true))
      for _, path in ipairs(src_paths) do
        if (a.get(opts, "include-macros-suffix?") or not string.match(path, "macros.fnl$")) then
          file((src_dir .. path), string.gsub((dest_dir .. path), ".fnl$", ".lua"), opts)
        end
      end
      return nil
    end
    v_0_0 = glob0
    _0_0["glob"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["glob"] = v_0_
  glob = v_0_
end
return nil
