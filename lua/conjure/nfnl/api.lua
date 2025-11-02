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
  local dir0 = (dir or vim.fn.getcwd())
  local _let_3_ = config["find-and-load"](dir0)
  local config0 = _let_3_.config
  local root_dir = _let_3_["root-dir"]
  local cfg = _let_3_.cfg
  if config0 then
    local orphan_files = gc["find-orphan-lua-files"]({["root-dir"] = root_dir, cfg = cfg})
    if core["empty?"](orphan_files) then
      if not passive_3f then
        notify.info("No orphan files detected.")
      else
      end
    else
      local function _5_(f)
        return (" - " .. f)
      end
      notify.warn("Orphan files detected, delete them with :NfnlDeleteOrphans.\n", str.join("\n", core.map(_5_, orphan_files)))
    end
    return orphan_files
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M["delete-orphans"] = function(_8_)
  local dir = _8_.dir
  local dir0 = (dir or vim.fn.getcwd())
  local _let_9_ = config["find-and-load"](dir0)
  local config0 = _let_9_.config
  local root_dir = _let_9_["root-dir"]
  local cfg = _let_9_.cfg
  if config0 then
    local orphan_files = gc["find-orphan-lua-files"]({["root-dir"] = root_dir, cfg = cfg})
    if core["empty?"](orphan_files) then
      notify.info("No orphan files detected.")
    else
      local function _10_(f)
        return (" - " .. f)
      end
      notify.info("Deleting orphan files:\n", str.join("\n", core.map(_10_, orphan_files)))
      core.map(os.remove, orphan_files)
    end
    return orphan_files
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
M["compile-file"] = function(_13_)
  local path = _13_.path
  local dir = _13_.dir
  local dir0 = (dir or vim.fn.getcwd())
  local _let_14_ = config["find-and-load"](dir0)
  local config0 = _let_14_.config
  local root_dir = _let_14_["root-dir"]
  local cfg = _let_14_.cfg
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
  local _let_16_ = config["find-and-load"](dir0)
  local config0 = _let_16_.config
  local root_dir = _let_16_["root-dir"]
  local cfg = _let_16_.cfg
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
