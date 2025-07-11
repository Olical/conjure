-- [nfnl] fnl/nfnl/api.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local compile = autoload("conjure.nfnl.compile")
local config = autoload("conjure.nfnl.config")
local notify = autoload("conjure.nfnl.notify")
local fs = autoload("conjure.nfnl.fs")
local gc = autoload("conjure.nfnl.gc")
local M = define("conjure.nfnl.api")
M["find-orphans"] = function(opts)
  local dir = vim.fn.getcwd()
  local _let_2_ = config["find-and-load"](dir)
  local config0 = _let_2_["config"]
  local root_dir = _let_2_["root-dir"]
  local cfg = _let_2_["cfg"]
  if config0 then
    local orphan_files = gc["find-orphan-lua-files"]({["root-dir"] = root_dir, cfg = cfg})
    if core["empty?"](orphan_files) then
      if not core.get(opts, "passive?") then
        notify.info("No orphan files detected.")
      else
      end
    else
      local function _4_(f)
        return (" - " .. f)
      end
      notify.warn("Orphan files detected, delete them with :NfnlDeleteOrphans.\n", str.join("\n", core.map(_4_, orphan_files)))
    end
    return orphan_files
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M["delete-orphans"] = function()
  local dir = vim.fn.getcwd()
  local _let_7_ = config["find-and-load"](dir)
  local config0 = _let_7_["config"]
  local root_dir = _let_7_["root-dir"]
  local cfg = _let_7_["cfg"]
  if config0 then
    local orphan_files = gc["find-orphan-lua-files"]({["root-dir"] = root_dir, cfg = cfg})
    if core["empty?"](orphan_files) then
      notify.info("No orphan files detected.")
    else
      local function _8_(f)
        return (" - " .. f)
      end
      notify.info("Deleting orphan files:\n", str.join("\n", core.map(_8_, orphan_files)))
      core.map(os.remove, orphan_files)
    end
    return orphan_files
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M["compile-file"] = function(_11_)
  local path = _11_["path"]
  local dir = _11_["dir"]
  local dir0 = (dir or vim.fn.getcwd())
  local _let_12_ = config["find-and-load"](dir0)
  local config0 = _let_12_["config"]
  local root_dir = _let_12_["root-dir"]
  local cfg = _let_12_["cfg"]
  if config0 then
    local path0 = fs["join-path"]({root_dir, vim.fn.expand((path or "%"))})
    local result = compile["into-file"]({["root-dir"] = root_dir, cfg = cfg, path = path0, source = core.slurp(path0), ["batch?"] = true})
    notify.info("Compilation complete.\n", result)
    return result
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M["compile-all-files"] = function(dir)
  local dir0 = (dir or vim.fn.getcwd())
  local _let_14_ = config["find-and-load"](dir0)
  local config0 = _let_14_["config"]
  local root_dir = _let_14_["root-dir"]
  local cfg = _let_14_["cfg"]
  if config0 then
    local results = compile["all-files"]({["root-dir"] = root_dir, cfg = cfg})
    notify.info("Compilation complete.\n", results)
    return results
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M.dofile = function(file)
  return dofile(fs["fnl-path->lua-path"](vim.fn.expand((file or "%"))))
end
return M
