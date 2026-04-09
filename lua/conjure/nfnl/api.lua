-- [nfnl] fnl/nfnl/api.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local compile = autoload("conjure.nfnl.compile")
local config = autoload("conjure.nfnl.config")
local notify = autoload("conjure.nfnl.notify")
local fs = autoload("conjure.nfnl.fs")
local gc = autoload("conjure.nfnl.gc")
local vim = _G.vim
local M = define("conjure.nfnl.api")
M["find-orphans"] = function(_2_)
  local passive_3f = _2_["passive?"]
  local dir = _2_.dir
  local config0 = _2_.config
  local root_dir = _2_["root-dir"]
  local cfg = _2_.cfg
  local dir0 = (dir or vim.fn.getcwd())
  local function _3_()
    if config0 then
      return {config = config0, ["root-dir"] = root_dir, cfg = cfg}
    else
      return config0["find-and-load"](dir0)
    end
  end
  local _let_4_ = _3_()
  local config1 = _let_4_.config
  local root_dir0 = _let_4_["root-dir"]
  local cfg0 = _let_4_.cfg
  if config1 then
    local orphan_files = gc["find-orphan-lua-files"]({["root-dir"] = root_dir0, cfg = cfg0})
    if core["empty?"](orphan_files) then
      if not passive_3f then
        notify.info("No orphan files detected.")
      else
      end
    else
      local function _6_(f)
        return (" - " .. f)
      end
      notify.warn("Orphan files detected, delete them with :NfnlDeleteOrphans.\n", str.join("\n", core.map(_6_, orphan_files)))
    end
    return orphan_files
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M["delete-orphans"] = function(_9_)
  local dir = _9_.dir
  local dir0 = (dir or vim.fn.getcwd())
  local _let_10_ = config["find-and-load"](dir0)
  local config0 = _let_10_.config
  local root_dir = _let_10_["root-dir"]
  local cfg = _let_10_.cfg
  if config0 then
    local orphan_files = gc["find-orphan-lua-files"]({["root-dir"] = root_dir, cfg = cfg})
    if core["empty?"](orphan_files) then
      notify.info("No orphan files detected.")
    else
      local function _11_(f)
        return (" - " .. f)
      end
      notify.info("Deleting orphan files:\n", str.join("\n", core.map(_11_, orphan_files)))
      core.map(os.remove, orphan_files)
    end
    return orphan_files
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M["compile-file"] = function(_14_)
  local path = _14_.path
  local dir = _14_.dir
  local dir0 = (dir or vim.fn.getcwd())
  local _let_15_ = config["find-and-load"](dir0)
  local config0 = _let_15_.config
  local root_dir = _let_15_["root-dir"]
  local cfg = _let_15_.cfg
  if config0 then
    local path0 = fs["absolute-path"](vim.fn.expand((path or "%")))
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
  local _let_17_ = config["find-and-load"](dir0)
  local config0 = _let_17_.config
  local root_dir = _let_17_["root-dir"]
  local cfg = _let_17_.cfg
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
