-- [nfnl] fnl/nfnl/fs.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.nfnl.fs")
M.basename = function(path)
  if path then
    return vim.fn.fnamemodify(path, ":h")
  else
    return nil
  end
end
M.filename = function(path)
  if path then
    return vim.fn.fnamemodify(path, ":t")
  else
    return nil
  end
end
M["file-name-root"] = function(path)
  if path then
    return vim.fn.fnamemodify(path, ":r")
  else
    return nil
  end
end
M["full-path"] = function(path)
  if path then
    return vim.fn.fnamemodify(path, ":p")
  else
    return nil
  end
end
M.mkdirp = function(dir)
  if dir then
    return vim.fn.mkdir(dir, "p")
  else
    return nil
  end
end
M["replace-extension"] = function(path, ext)
  if path then
    return (M["file-name-root"](path) .. ("." .. ext))
  else
    return nil
  end
end
M["read-first-line"] = function(path)
  local f = io.open(path, "r")
  if (f and not core["string?"](f)) then
    local line = f:read("*line")
    f:close()
    return line
  else
    return nil
  end
end
M.absglob = function(dir, expr)
  return vim.fn.globpath(dir, expr, true, true)
end
M.relglob = function(dir, expr)
  local dir_len = (2 + string.len(dir))
  local function _9_(_241)
    return string.sub(_241, dir_len)
  end
  return core.map(_9_, M.absglob(dir, expr))
end
M["glob-dir-newer?"] = function(a_dir, b_dir, expr, b_dir_path_fn)
  local newer_3f = false
  for _, path in ipairs(M.relglob(a_dir, expr)) do
    if (vim.fn.getftime((a_dir .. path)) > vim.fn.getftime((b_dir .. b_dir_path_fn(path)))) then
      newer_3f = true
    else
    end
  end
  return newer_3f
end
M["path-sep"] = function()
  local os = string.lower(jit.os)
  if (("linux" == os) or ("osx" == os) or ("bsd" == os) or ((1 == vim.fn.exists("+shellshash")) and vim.o.shellslash)) then
    return "/"
  else
    return "\\"
  end
end
M.findfile = function(name, path)
  local res = vim.fn.findfile(name, path)
  if not core["empty?"](res) then
    return M["full-path"](res)
  else
    return nil
  end
end
M["split-path"] = function(path)
  return str.split(path, M["path-sep"]())
end
M["join-path"] = function(parts)
  return str.join(M["path-sep"](), core.concat(parts))
end
M["replace-dirs"] = function(path, from, to)
  local function _13_(segment)
    if (from == segment) then
      return to
    else
      return segment
    end
  end
  return M["join-path"](core.map(_13_, M["split-path"](path)))
end
M["fnl-path->lua-path"] = function(fnl_path)
  return M["replace-dirs"](M["replace-extension"](fnl_path, "lua"), "fnl", "lua")
end
M["glob-matches?"] = function(dir, expr, path)
  local regex = vim.regex(vim.fn.glob2regpat(M["join-path"]({dir, expr})))
  return regex:match_str(path)
end
local uv = (vim.uv or vim.loop)
M["exists?"] = function(path)
  if path then
    return ("table" == type(uv.fs_stat(path)))
  else
    return nil
  end
end
return M
