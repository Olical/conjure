-- [nfnl] fnl/nfnl/gc.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local fs = autoload("conjure.nfnl.fs")
local header = autoload("conjure.nfnl.header")
local M = define("conjure.nfnl.gc")
M["find-orphan-lua-files"] = function(_2_)
  local cfg = _2_["cfg"]
  local root_dir = _2_["root-dir"]
  local fnl_path__3elua_path = cfg({"fnl-path->lua-path"})
  local ignore_patterns = cfg({"orphan-detection", "ignore-patterns"})
  local function _3_(path)
    local line = fs["read-first-line"](path)
    local function _4_(pat)
      return path:find(pat)
    end
    return (not core.some(_4_, ignore_patterns) and header["tagged?"](line) and not fs["exists?"](header["source-path"](line)))
  end
  local function _5_(fnl_pattern)
    local lua_pattern = fnl_path__3elua_path(fnl_pattern)
    return fs.relglob(root_dir, lua_pattern)
  end
  return core.filter(_3_, core.keys(core["->set"](core.mapcat(_5_, cfg({"source-file-patterns"})))))
end
--[[ (local config (require "conjure.nfnl.config")) (M.find-orphan-lua-files (config.find-and-load ".")) ]]
return M
