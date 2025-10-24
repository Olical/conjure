-- [nfnl] fnl/nfnl/compile.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local fs = autoload("conjure.nfnl.fs")
local fennel = autoload("conjure.nfnl.fennel")
local notify = autoload("conjure.nfnl.notify")
local config = autoload("conjure.nfnl.config")
local header = autoload("conjure.nfnl.header")
local M = define("conjure.nfnl.compile")
local function safe_target_3f(path)
  local line = fs["read-first-line"](path)
  return (not line or header["tagged?"](line))
end
M["macro-source?"] = function(_2_)
  local source = _2_.source
  local path = _2_.path
  return ((string.find(source, "%s*;+%s*%[nfnl%-macro%]") and true) or (path and str["ends-with?"](path, ".fnlm")))
end
local function valid_source_files(glob_fn, _3_)
  local root_dir = _3_["root-dir"]
  local cfg = _3_.cfg
  local function _4_(_241)
    return glob_fn(root_dir, _241)
  end
  return core.mapcat(_4_, cfg({"source-file-patterns"}))
end
local function valid_source_file_3f(path, _5_)
  local root_dir = _5_["root-dir"]
  local cfg = _5_.cfg
  local function _6_(_241)
    return fs["glob-matches?"](root_dir, _241, path)
  end
  return core.some(_6_, cfg({"source-file-patterns"}))
end
M["into-string"] = function(_7_)
  local root_dir = _7_["root-dir"]
  local path = _7_.path
  local cfg = _7_.cfg
  local source = _7_.source
  local batch_3f = _7_["batch?"]
  local opts = _7_
  local macro_3f = M["macro-source?"](opts)
  if (macro_3f and batch_3f) then
    return {status = "macros-are-not-compiled", ["source-path"] = path}
  elseif macro_3f then
    core["clear-table!"](fennel["macro-loaded"])
    return M["all-files"]({["root-dir"] = root_dir, cfg = cfg})
  elseif config["config-file-path?"](path) then
    return {status = "nfnl-config-is-not-compiled", ["source-path"] = path}
  elseif not valid_source_file_3f(path, opts) then
    return {status = "path-is-not-in-source-file-patterns", ["source-path"] = path}
  else
    local rel_file_name = path:sub((2 + root_dir:len()))
    local ok, res
    do
      fennel.path = cfg({"fennel-path"})
      fennel["macro-path"] = cfg({"fennel-macro-path"})
      ok, res = pcall(fennel["compile-string"], source, core.merge({filename = path, warn = notify.warn}, cfg({"compiler-options"})))
    end
    if ok then
      if cfg({"verbose"}) then
        notify.info("Successfully compiled: ", path)
      else
      end
      local _9_
      if cfg({"header-comment"}) then
        _9_ = header["with-header"](rel_file_name, res)
      else
        _9_ = res
      end
      return {status = "ok", ["source-path"] = path, result = (_9_ .. "\n")}
    else
      if not batch_3f then
        notify.error(res)
      else
      end
      return {status = "compilation-error", error = res, ["source-path"] = path}
    end
  end
end
M["into-file"] = function(_14_)
  local _root_dir = _14_["_root-dir"]
  local cfg = _14_.cfg
  local _source = _14_._source
  local path = _14_.path
  local batch_3f = _14_["batch?"]
  local opts = _14_
  local fnl_path__3elua_path = cfg({"fnl-path->lua-path"})
  local destination_path = fnl_path__3elua_path(path)
  local _let_15_ = M["into-string"](opts)
  local status = _let_15_.status
  local source_path = _let_15_["source-path"]
  local result = _let_15_.result
  local res = _let_15_
  if ("ok" ~= status) then
    return res
  elseif (safe_target_3f(destination_path) or not cfg({"header-comment"})) then
    fs.mkdirp(fs.basename(destination_path))
    core.spit(destination_path, result)
    return {status = "ok", ["source-path"] = source_path, ["destination-path"] = destination_path}
  else
    if not batch_3f then
      notify.warn(destination_path, " was not compiled by nfnl. Delete it manually if you wish to compile into this file.")
    else
    end
    return {status = "destination-exists", ["source-path"] = path, ["destination-path"] = destination_path}
  end
end
M["all-files"] = function(_18_)
  local root_dir = _18_["root-dir"]
  local cfg = _18_.cfg
  local opts = _18_
  local function _19_(path)
    return M["into-file"]({["root-dir"] = root_dir, path = path, cfg = cfg, source = core.slurp(path), ["batch?"] = true})
  end
  local function _20_(_241)
    return fs["join-path"]({root_dir, _241})
  end
  return core.map(_19_, core.map(_20_, valid_source_files(fs.relglob, opts)))
end
return M
