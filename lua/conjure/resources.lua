-- [nfnl] fnl/conjure/resources.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = require("conjure.nfnl.core")
local log = autoload("conjure.log")
local M = define("conjure.resources")
local resource_prefix = "res/"
local cache = {}
local function read_and_cache_file_contents(path)
  log.dbg((path .. " resource not cached - reading"))
  local content = a.slurp(path)
  cache[path] = content
  return content
end
local function get_cached_file_contents(path)
  if cache[path] then
    return cache[path]
  else
    return read_and_cache_file_contents(path)
  end
end
M["get-resource-contents"] = function(path)
  local resource_path = (resource_prefix .. path)
  local file_paths = vim.api.nvim_get_runtime_file(resource_path, false)
  if (#file_paths > 0) then
    return get_cached_file_contents(file_paths[1])
  else
    return nil
  end
end
return M
