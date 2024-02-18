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
  local _arg_3_ = _2_
  local rtp_patterns = _arg_3_["rtp-patterns"]
  local runtimepath = _arg_3_["runtimepath"]
  local base_dirs = _arg_3_["base-dirs"]
  local function _4_(path)
    local function _5_(_241)
      return string.find(path, _241)
    end
    return core.some(_5_, rtp_patterns)
  end
  return core.distinct(core.concat(base_dirs, core.filter(_4_, str.split(runtimepath, ","))))
end
local function default(opts)
  local root_dir
  local function _6_()
    local _7_ = vim.fn.getcwd()
    if (nil ~= _7_) then
      local _8_ = find(_7_)
      if (nil ~= _8_) then
        local _9_ = fs["full-path"](_8_)
        if (nil ~= _9_) then
          return string.sub(_9_, 1, -2)
        else
          return _9_
        end
      else
        return _8_
      end
    else
      return _7_
    end
  end
  root_dir = (core.get(opts, "root-dir") or _6_() or vim.fn.getcwd())
  local dirs = path_dirs({runtimepath = vim.o.runtimepath, ["rtp-patterns"] = core.get(opts, "rtp-patterns", {(fs["path-sep"]() .. "nfnl$")}), ["base-dirs"] = {root_dir}})
  local function _13_(root_dir0)
    return core.map(fs["join-path"], {{root_dir0, "?.fnl"}, {root_dir0, "?", "init.fnl"}, {root_dir0, "fnl", "?.fnl"}, {root_dir0, "fnl", "?", "init.fnl"}})
  end
  local function _14_(root_dir0)
    return core.map(fs["join-path"], {{root_dir0, "?.fnl"}, {root_dir0, "?", "init-macros.fnl"}, {root_dir0, "?", "init.fnl"}, {root_dir0, "fnl", "?.fnl"}, {root_dir0, "fnl", "?", "init-macros.fnl"}, {root_dir0, "fnl", "?", "init.fnl"}})
  end
  return {["compiler-options"] = {["error-pinpoint"] = false}, ["fennel-path"] = str.join(";", core.mapcat(_13_, dirs)), ["fennel-macro-path"] = str.join(";", core.mapcat(_14_, dirs)), ["source-file-patterns"] = {"*.fnl", fs["join-path"]({"**", "*.fnl"})}, ["fnl-path->lua-path"] = fs["fnl-path->lua-path"], verbose = false}
end
local function cfg_fn(t, opts)
  local default_cfg = default(opts)
  local function _15_(path)
    return core["get-in"](t, path, core["get-in"](default_cfg, path))
  end
  return _15_
end
local function config_file_path_3f(path)
  return (config_file_name == fs.filename(path))
end
local function find_and_load(dir)
  local function _16_()
    local config_file_path = find(dir)
    if config_file_path then
      local root_dir = fs.basename(config_file_path)
      local config_source = vim.secure.read(config_file_path)
      local ok, config = nil, nil
      if core["nil?"](config_source) then
        ok, config = false, (config_file_path .. " is not trusted, refusing to compile.")
      elseif (str["blank?"](config_source) or ("{}" == str.trim(config_source))) then
        ok, config = true, {}
      else
        ok, config = pcall(fennel.eval, config_source, {filename = config_file_path})
      end
      if ok then
        return {config = config, ["root-dir"] = root_dir, cfg = cfg_fn(config, {["root-dir"] = root_dir})}
      else
        return notify.error(config)
      end
    else
      return nil
    end
  end
  return (_16_() or {})
end
return {["cfg-fn"] = cfg_fn, find = find, ["find-and-load"] = find_and_load, ["config-file-path?"] = config_file_path_3f, default = default, ["path-dirs"] = path_dirs}
