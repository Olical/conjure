-- [nfnl] Compiled from fnl/nfnl/api.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("nfnl.core")
local compile = autoload("nfnl.compile")
local config = autoload("nfnl.config")
local notify = autoload("nfnl.notify")
local fs = autoload("nfnl.fs")
local mod = {}
mod["compile-file"] = function(_2_)
  local path = _2_["path"]
  local dir = _2_["dir"]
  local dir0 = (dir or vim.fn.getcwd())
  local _let_3_ = config["find-and-load"](dir0)
  local config0 = _let_3_["config"]
  local root_dir = _let_3_["root-dir"]
  local cfg = _let_3_["cfg"]
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
mod["compile-all-files"] = function(dir)
  local dir0 = (dir or vim.fn.getcwd())
  local _let_5_ = config["find-and-load"](dir0)
  local config0 = _let_5_["config"]
  local root_dir = _let_5_["root-dir"]
  local cfg = _let_5_["cfg"]
  if config0 then
    local results = compile["all-files"]({["root-dir"] = root_dir, cfg = cfg})
    notify.info("Compilation complete.\n", results)
    return results
  else
    notify.warn("No .nfnl.fnl configuration found.")
    return {}
  end
end
mod.dofile = function(file)
  return dofile(fs["fnl-path->lua-path"](vim.fn.expand((file or "%"))))
end
return mod
