-- [nfnl] Compiled from fnl/nfnl/compile.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("nfnl.core")
local fs = autoload("nfnl.fs")
local fennel = autoload("nfnl.fennel")
local notify = autoload("nfnl.notify")
local config = autoload("nfnl.config")
local mod = {}
local header_marker = "[nfnl]"
local function with_header(file, src)
  return ("-- " .. header_marker .. " Compiled from " .. file .. " by https://github.com/Olical/nfnl, do not edit.\n" .. src)
end
local function safe_target_3f(path)
  local header = fs["read-first-line"](path)
  return (core["nil?"](header) or not core["nil?"](header:find(header_marker, 1, true)))
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
mod["into-string"] = function(_4_)
  local root_dir = _4_["root-dir"]
  local path = _4_["path"]
  local cfg = _4_["cfg"]
  local source = _4_["source"]
  local batch_3f = _4_["batch?"]
  local file_exists_on_disk_3f = _4_["file-exists-on-disk?"]
  local opts = _4_
  local macro_3f = macro_source_3f(source)
  if (macro_3f and batch_3f) then
    return {status = "macros-are-not-compiled", ["source-path"] = path}
  elseif macro_3f then
    core["clear-table!"](fennel["macro-loaded"])
    return mod["all-files"]({["root-dir"] = root_dir, cfg = cfg})
  elseif config["config-file-path?"](path) then
    return {status = "nfnl-config-is-not-compiled", ["source-path"] = path}
  else
    local and_5_ = (false ~= file_exists_on_disk_3f)
    if and_5_ then
      local function _6_(_241)
        return (path == _241)
      end
      and_5_ = not core.some(_6_, valid_source_files(fs.absglob, opts))
    end
    if and_5_ then
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
        return {status = "ok", ["source-path"] = path, result = (with_header(rel_file_name, res) .. "\n")}
      else
        if not batch_3f then
          notify.error(res)
        else
        end
        return {status = "compilation-error", error = res, ["source-path"] = path}
      end
    end
  end
end
mod["into-file"] = function(_11_)
  local _root_dir = _11_["_root-dir"]
  local cfg = _11_["cfg"]
  local _source = _11_["_source"]
  local path = _11_["path"]
  local batch_3f = _11_["batch?"]
  local opts = _11_
  local fnl_path__3elua_path = cfg({"fnl-path->lua-path"})
  local destination_path = fnl_path__3elua_path(path)
  local _let_12_ = mod["into-string"](opts)
  local status = _let_12_["status"]
  local source_path = _let_12_["source-path"]
  local result = _let_12_["result"]
  local res = _let_12_
  if ("ok" ~= status) then
    return res
  elseif safe_target_3f(destination_path) then
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
mod["all-files"] = function(_15_)
  local root_dir = _15_["root-dir"]
  local cfg = _15_["cfg"]
  local opts = _15_
  local function _16_(path)
    return mod["into-file"]({["root-dir"] = root_dir, path = path, cfg = cfg, source = core.slurp(path), ["batch?"] = true})
  end
  local function _17_(_241)
    return fs["join-path"]({root_dir, _241})
  end
  return core.map(_16_, core.map(_17_, valid_source_files(fs.relglob, opts)))
end
return mod
