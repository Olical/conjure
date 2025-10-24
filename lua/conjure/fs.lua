-- [nfnl] fnl/conjure/fs.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local config = autoload("conjure.config")
local nfs = autoload("conjure.nfnl.fs")
local M = define("conjure.fs")
local path_sep = nfs["path-sep"]()
M.env = function(k)
  local v = vim.fn.getenv(k)
  if (core["string?"](v) and not core["empty?"](v)) then
    return v
  else
    return nil
  end
end
M["config-dir"] = function()
  local function _3_()
    if M.env("XDG_CONFIG_HOME") then
      return "$XDG_CONFIG_HOME/conjure"
    else
      return "~/.config/conjure"
    end
  end
  return vim.fs.normalize(_3_())
end
M["absolute-path"] = function(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end
M.findfile = function(name, path)
  local res = vim.fn.findfile(name, path)
  if not core["empty?"](res) then
    return M["absolute-path"](res)
  else
    return nil
  end
end
M["split-path"] = function(path)
  return vim.split(path, path_sep, {trimempty = true})
end
M["join-path"] = function(parts)
  return str.join(path_sep, core.concat(parts))
end
M["parent-dir"] = function(path)
  local res = M["join-path"](core.butlast(M["split-path"](path)))
  if ("" == res) then
    return nil
  else
    return (path_sep .. res)
  end
end
M["upwards-file-search"] = function(file_names, from_dir)
  if (from_dir and not core["empty?"](file_names)) then
    local result
    local function _6_(file_name)
      return M.findfile(file_name, from_dir)
    end
    result = core.some(_6_, file_names)
    if result then
      return result
    else
      return M["upwards-file-search"](file_names, M["parent-dir"](from_dir))
    end
  else
    return nil
  end
end
M["resolve-above"] = function(names)
  return (M["upwards-file-search"](names, vim.fn.expand("%:p:h")) or M["upwards-file-search"](names, vim.fn.getcwd()) or M["upwards-file-search"](names, M["config-dir"]()))
end
M["file-readable?"] = function(path)
  return (1 == vim.fn.filereadable(path))
end
M["resolve-relative-to"] = function(path, root)
  local function loop(parts)
    if core["empty?"](parts) then
      return path
    else
      if M["file-readable?"](M["join-path"](core.concat({root}, parts))) then
        return M["join-path"](parts)
      else
        return loop(core.rest(parts))
      end
    end
  end
  return loop(M["split-path"](path))
end
M["resolve-relative"] = function(path)
  local relative_file_root = config["get-in"]({"relative_file_root"})
  if relative_file_root then
    return M["resolve-relative-to"](path, relative_file_root)
  else
    return path
  end
end
M["apply-path-subs"] = function(path, path_subs)
  local function _13_(path0, _12_)
    local pat = _12_[1]
    local rep = _12_[2]
    return path0:gsub(pat, rep)
  end
  return core.reduce(_13_, path, core["kv-pairs"](path_subs))
end
M["localise-path"] = function(path)
  return M["resolve-relative"](M["apply-path-subs"](path, config["get-in"]({"path_subs"})))
end
M["current-source"] = function()
  local info = debug.getinfo(2, "S")
  if vim.startswith(core.get(info, "source"), "@") then
    return string.sub(info.source, 2)
  else
    return nil
  end
end
do
  local src = M["current-source"]()
  if src then
    M["conjure-source-directory"] = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(src)))
  else
    M["conjure-source-directory"] = nil
  end
end
M["file-path->module-name"] = function(file_path)
  if file_path then
    local function _16_(mod_name)
      local mod_path = string.gsub(mod_name, "%.", path_sep)
      if (vim.endswith(file_path, (mod_path .. ".fnl")) or vim.endswith(file_path, (mod_path .. "/init.fnl"))) then
        return mod_name
      else
        return nil
      end
    end
    return core.some(_16_, core.keys(package.loaded))
  else
    return nil
  end
end
return M
