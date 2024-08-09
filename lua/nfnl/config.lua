-- [nfnl] Compiled from fnl/nfnl/config.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("nfnl.core")
local fs = autoload("nfnl.fs")
local str = autoload("nfnl.string")
local fennel = autoload("nfnl.fennel")
local notify = autoload("nfnl.notify")
local config_file_name = ".nfnl.fnl"
local function find(dir)
  return fs.findfile(config_file_name, (dir .. ";"))
end
local function path_dirs(_2_)
  local rtp_patterns = _2_["rtp-patterns"]
  local runtimepath = _2_["runtimepath"]
  local base_dirs = _2_["base-dirs"]
  local function _3_(path)
    local function _4_(_241)
      return string.find(path, _241)
    end
    return core.some(_4_, rtp_patterns)
  end
  return core.distinct(core.concat(base_dirs, core.filter(_3_, str.split(runtimepath, ","))))
end
local function default(opts)
  local root_dir
  local or_5_ = core.get(opts, "root-dir")
  if not or_5_ then
    local tmp_3_auto = fs.cwd()
    if (nil ~= tmp_3_auto) then
      local tmp_3_auto0 = find(tmp_3_auto)
      if (nil ~= tmp_3_auto0) then
        local tmp_3_auto1 = fs["full-path"](tmp_3_auto0)
        if (nil ~= tmp_3_auto1) then
          or_5_ = fs.basename(tmp_3_auto1)
        else
          or_5_ = nil
        end
      else
        or_5_ = nil
      end
    else
      or_5_ = nil
    end
  end
  root_dir = (or_5_ or fs.cwd())
  local dirs = path_dirs({runtimepath = vim.o.runtimepath, ["rtp-patterns"] = core.get(opts, "rtp-patterns", {"/nfnl$"}), ["base-dirs"] = {root_dir}})
  local function _12_(root_dir0)
    return core.map(fs["join-path"], {{root_dir0, "?.fnl"}, {root_dir0, "?", "init.fnl"}, {root_dir0, "fnl", "?.fnl"}, {root_dir0, "fnl", "?", "init.fnl"}})
  end
  local function _13_(root_dir0)
    return core.map(fs["join-path"], {{root_dir0, "?.fnl"}, {root_dir0, "?", "init-macros.fnl"}, {root_dir0, "?", "init.fnl"}, {root_dir0, "fnl", "?.fnl"}, {root_dir0, "fnl", "?", "init-macros.fnl"}, {root_dir0, "fnl", "?", "init.fnl"}})
  end
  return {["compiler-options"] = {["error-pinpoint"] = false}, ["root-dir"] = root_dir, ["fennel-path"] = str.join(";", core.mapcat(_12_, dirs)), ["fennel-macro-path"] = str.join(";", core.mapcat(_13_, dirs)), ["source-file-patterns"] = {"*.fnl", fs["join-path"]({"**", "*.fnl"})}, ["fnl-path->lua-path"] = fs["fnl-path->lua-path"], verbose = false}
end
local function cfg_fn(t, opts)
  local default_cfg = default(opts)
  local function _14_(path)
    return core["get-in"](t, path, core["get-in"](default_cfg, path))
  end
  return _14_
end
local function config_file_path_3f(path)
  return (config_file_name == fs.filename(path))
end
local function find_and_load(dir)
  local _15_
  do
    local config_file_path = find(dir)
    if config_file_path then
      local root_dir = fs.basename(config_file_path)
      local read_fn
      if ("false" ~= vim.env.NFNL_USE_SECURE_READ) then
        read_fn = vim.secure.read
      else
        read_fn = core.slurp
      end
      local config_source = read_fn(config_file_path)
      local ok, config = nil, nil
      if core["nil?"](config_source) then
        ok, config = false, (config_file_path .. " is not trusted, refusing to compile.")
      elseif (str["blank?"](config_source) or ("{}" == str.trim(config_source))) then
        ok, config = true, {}
      else
        ok, config = pcall(fennel.eval, config_source, {filename = config_file_path})
      end
      if ok then
        _15_ = {config = config, ["root-dir"] = root_dir, cfg = cfg_fn(config, {["root-dir"] = root_dir})}
      else
        _15_ = notify.error(config)
      end
    else
      _15_ = nil
    end
  end
  return (_15_ or {})
end
return {["cfg-fn"] = cfg_fn, find = find, ["find-and-load"] = find_and_load, ["config-file-path?"] = config_file_path_3f, default = default, ["path-dirs"] = path_dirs}
