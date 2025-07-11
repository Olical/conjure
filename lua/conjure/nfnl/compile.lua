-- [nfnl] fnl/nfnl/compile.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local fs = autoload("conjure.nfnl.fs")
local fennel = autoload("conjure.nfnl.fennel")
local notify = autoload("conjure.nfnl.notify")
local config = autoload("conjure.nfnl.config")
local header = autoload("conjure.nfnl.header")
local mod = {}
local function safe_target_3f(path)
  local line = fs["read-first-line"](path)
  return (not line or header["tagged?"](line))
end
local function macro_source_3f(source)
  return string.find(source, "%s*;+%s*%[nfnl%-macro%]")
end
local function valid_source_files(glob_fn, _2_)
  local root_dir = _2_["root-dir"]
  local cfg = _2_["cfg"]
  local function _3_(_241)
    return glob_fn(root_dir, _241)
  end
  return core.mapcat(_3_, cfg({"source-file-patterns"}))
end
local function valid_source_file_3f(path, _4_)
  local root_dir = _4_["root-dir"]
  local cfg = _4_["cfg"]
  local function _5_(_241)
    return fs["glob-matches?"](root_dir, _241, path)
  end
  return core.some(_5_, cfg({"source-file-patterns"}))
end
mod["into-string"] = function(_6_)
  local root_dir = _6_["root-dir"]
  local path = _6_["path"]
  local cfg = _6_["cfg"]
  local source = _6_["source"]
  local batch_3f = _6_["batch?"]
  local opts = _6_
  local macro_3f = macro_source_3f(source)
  if (macro_3f and batch_3f) then
    return {status = "macros-are-not-compiled", ["source-path"] = path}
  elseif macro_3f then
    core["clear-table!"](fennel["macro-loaded"])
    return mod["all-files"]({["root-dir"] = root_dir, cfg = cfg})
  elseif config["config-file-path?"](path) then
    return {status = "nfnl-config-is-not-compiled", ["source-path"] = path}
  elseif not valid_source_file_3f(path, opts) then
    return {status = "path-is-not-in-source-file-patterns", ["source-path"] = path}
  else
    local rel_file_name = path:sub((2 + root_dir:len()))
    local ok, res = nil, nil
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
      local _8_
      if cfg({"header-comment"}) then
        _8_ = header["with-header"](rel_file_name, res)
      else
        _8_ = res
      end
      return {status = "ok", ["source-path"] = path, result = (_8_ .. "\n")}
    else
      if not batch_3f then
        notify.error(res)
      else
      end
      return {status = "compilation-error", error = res, ["source-path"] = path}
    end
  end
end
mod["into-file"] = function(_13_)
  local _root_dir = _13_["_root-dir"]
  local cfg = _13_["cfg"]
  local _source = _13_["_source"]
  local path = _13_["path"]
  local batch_3f = _13_["batch?"]
  local opts = _13_
  local fnl_path__3elua_path = cfg({"fnl-path->lua-path"})
  local destination_path = fnl_path__3elua_path(path)
  local _let_14_ = mod["into-string"](opts)
  local status = _let_14_["status"]
  local source_path = _let_14_["source-path"]
  local result = _let_14_["result"]
  local res = _let_14_
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
mod["all-files"] = function(_17_)
  local root_dir = _17_["root-dir"]
  local cfg = _17_["cfg"]
  local opts = _17_
  local function _18_(path)
    return mod["into-file"]({["root-dir"] = root_dir, path = path, cfg = cfg, source = core.slurp(path), ["batch?"] = true})
  end
  local function _19_(_241)
    return fs["join-path"]({root_dir, _241})
  end
  return core.map(_18_, core.map(_19_, valid_source_files(fs.relglob, opts)))
end
return mod
