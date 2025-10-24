-- [nfnl] fnl/nfnl/config.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local fs = autoload("conjure.nfnl.fs")
local str = autoload("conjure.nfnl.string")
local fennel = autoload("conjure.nfnl.fennel")
local notify = autoload("conjure.nfnl.notify")
local vim = _G.vim
local M = define("conjure.nfnl.config")
local config_file_name = ".nfnl.fnl"
M.find = function(dir)
  return fs.findfile(config_file_name, (dir .. ";"))
end
M["path-dirs"] = function(_2_)
  local rtp_patterns = _2_["rtp-patterns"]
  local runtimepath = _2_.runtimepath
  local base_dirs = _2_["base-dirs"]
  local function _3_(path)
    local function _4_(_241)
      return string.find(path, _241)
    end
    return core.some(_4_, rtp_patterns)
  end
  return core.distinct(core.concat(base_dirs, core.filter(_3_, str.split(runtimepath, ","))))
end
M.default = function(opts)
  local root_dir
  local or_5_ = core.get(opts, "root-dir")
  if not or_5_ then
    local tmp_3_ = vim.fn.getcwd()
    if (nil ~= tmp_3_) then
      local tmp_3_0 = M.find(tmp_3_)
      if (nil ~= tmp_3_0) then
        local tmp_3_1 = fs["full-path"](tmp_3_0)
        if (nil ~= tmp_3_1) then
          or_5_ = fs.basename(tmp_3_1)
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
  root_dir = (or_5_ or vim.fn.getcwd())
  local dirs = M["path-dirs"]({runtimepath = vim.o.runtimepath, ["rtp-patterns"] = core.get(opts, "rtp-patterns", {(fs["path-sep"]() .. "nfnl$")}), ["base-dirs"] = {root_dir}})
  local function _12_(root_dir0)
    return core.map(fs["join-path"], {{root_dir0, "?.fnl"}, {root_dir0, "?", "init.fnl"}, {root_dir0, "fnl", "?.fnl"}, {root_dir0, "fnl", "?", "init.fnl"}})
  end
  local function _13_(root_dir0)
    return core.map(fs["join-path"], {{root_dir0, "?.fnlm"}, {root_dir0, "?", "init.fnlm"}, {root_dir0, "fnl", "?.fnlm"}, {root_dir0, "fnl", "?", "init.fnlm"}, {root_dir0, "?.fnl"}, {root_dir0, "?", "init.fnl"}, {root_dir0, "?", "init-macros.fnl"}, {root_dir0, "fnl", "?.fnl"}, {root_dir0, "fnl", "?", "init.fnl"}, {root_dir0, "fnl", "?", "init-macros.fnl"}})
  end
  return {["header-comment"] = true, ["compiler-options"] = {["error-pinpoint"] = false}, ["orphan-detection"] = {["auto?"] = true, ["ignore-patterns"] = {}}, ["root-dir"] = root_dir, ["fennel-path"] = str.join(";", core.mapcat(_12_, dirs)), ["fennel-macro-path"] = str.join(";", core.mapcat(_13_, dirs)), ["source-file-patterns"] = {".*.fnl", "*.fnl", fs["join-path"]({"**", "*.fnl"})}, ["fnl-path->lua-path"] = fs["fnl-path->lua-path"], verbose = false}
end
M["cfg-fn"] = function(t, opts)
  local default_cfg = M.default(opts)
  local function _14_(path)
    return core["get-in"](t, path, core["get-in"](default_cfg, path))
  end
  return _14_
end
M["config-file-path?"] = function(path)
  return (config_file_name == fs.filename(path))
end
M["find-and-load"] = function(dir)
  local _15_
  do
    local config_file_path = M.find(dir)
    if config_file_path then
      local root_dir = fs.basename(config_file_path)
      local config_source = vim.secure.read(config_file_path)
      local ok, config
      if core["nil?"](config_source) then
        ok, config = false, (config_file_path .. " is not trusted, refusing to compile.")
      elseif (str["blank?"](config_source) or ("{}" == str.trim(config_source))) then
        ok, config = true, {}
      else
        ok, config = pcall(fennel.eval, config_source, {filename = config_file_path})
      end
      if ok then
        _15_ = {config = config, ["root-dir"] = root_dir, cfg = M["cfg-fn"](config, {["root-dir"] = root_dir})}
      else
        _15_ = notify.error(config)
      end
    else
      _15_ = nil
    end
  end
  return (_15_ or {})
end
return M
