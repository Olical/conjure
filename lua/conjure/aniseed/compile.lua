local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.aniseed.compile"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.fennel"), require("conjure.aniseed.fs"), require("conjure.aniseed.nvim")}
local a = _local_0_[1]
local fennel = _local_0_[2]
local fs = _local_0_[3]
local nvim = _local_0_[4]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.compile"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local macros_prefix
do
  local v_0_
  local function macros_prefix0(code)
    local macros_module = "conjure.aniseed.macros"
    return ("(require-macros \"" .. macros_module .. "\")\n" .. code)
  end
  v_0_ = macros_prefix0
  _0_0["macros-prefix"] = v_0_
  macros_prefix = v_0_
end
local str
do
  local v_0_
  local function str0(code, opts)
    local function _1_()
      return fennel.compileString(macros_prefix(code), a.merge({["compiler-env"] = _G}, opts))
    end
    return xpcall(_1_, fennel.traceback)
  end
  v_0_ = str0
  _0_0["str"] = v_0_
  str = v_0_
end
local file
do
  local v_0_
  local function file0(src, dest, opts)
    if ((a["table?"](opts) and opts.force) or (nvim.fn.getftime(src) > nvim.fn.getftime(dest))) then
      local code = a.slurp(src)
      local _1_0, _2_0 = str(code, {filename = src})
      if ((_1_0 == false) and (nil ~= _2_0)) then
        local err = _2_0
        return nvim.err_writeln(err)
      elseif ((_1_0 == true) and (nil ~= _2_0)) then
        local result = _2_0
        fs.mkdirp(fs.basename(dest))
        return a.spit(dest, result)
      end
    end
  end
  v_0_ = file0
  _0_0["file"] = v_0_
  file = v_0_
end
local glob
do
  local v_0_
  local function glob0(src_expr, src_dir, dest_dir, opts)
    local src_dir_len = a.inc(string.len(src_dir))
    local src_paths
    local function _1_(path)
      return string.sub(path, src_dir_len)
    end
    src_paths = a.map(_1_, nvim.fn.globpath(src_dir, src_expr, true, true))
    for _, path in ipairs(src_paths) do
      if (a.get(opts, "include-macros-suffix?") or not string.match(path, "macros.fnl$")) then
        file((src_dir .. path), string.gsub((dest_dir .. path), ".fnl$", ".lua"), opts)
      end
    end
    return nil
  end
  v_0_ = glob0
  _0_0["glob"] = v_0_
  glob = v_0_
end
return nil
