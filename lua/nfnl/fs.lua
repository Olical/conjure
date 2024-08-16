-- [nfnl] Compiled from fnl/nfnl/fs.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("nfnl.core")
local str = autoload("nfnl.string")
local function basename(path)
  if path then
    return vim.fn.fnamemodify(path, ":h")
  else
    return nil
  end
end
local function filename(path)
  if path then
    return vim.fn.fnamemodify(path, ":t")
  else
    return nil
  end
end
local function file_name_root(path)
  if path then
    return vim.fn.fnamemodify(path, ":r")
  else
    return nil
  end
end
local function full_path(path)
  if path then
    return vim.fn.fnamemodify(path, ":p")
  else
    return nil
  end
end
local function mkdirp(dir)
  if dir then
    return vim.fn.mkdir(dir, "p")
  else
    return nil
  end
end
local function replace_extension(path, ext)
  if path then
    return (file_name_root(path) .. ("." .. ext))
  else
    return nil
  end
end
local function read_first_line(path)
  local f = io.open(path)
  if (f and not core["string?"](f)) then
    local line = f:read()
    f:close()
    return line
  else
    return nil
  end
end
local function absglob(dir, expr)
  return vim.fn.globpath(dir, expr, true, true)
end
local function relglob(dir, expr)
  local dir_len = (2 + string.len(dir))
  local function _9_(_241)
    return string.sub(_241, dir_len)
  end
  return core.map(_9_, absglob(dir, expr))
end
local function glob_dir_newer_3f(a_dir, b_dir, expr, b_dir_path_fn)
  local newer_3f = false
  for _, path in ipairs(relglob(a_dir, expr)) do
    if (vim.fn.getftime((a_dir .. path)) > vim.fn.getftime((b_dir .. b_dir_path_fn(path)))) then
      newer_3f = true
    else
    end
  end
  return newer_3f
end
local function path_sep()
  local os = string.lower(jit.os)
  if (("linux" == os) or ("osx" == os) or ("bsd" == os) or ((1 == vim.fn.exists("+shellshash")) and vim.o.shellslash)) then
    return "/"
  else
    return "\\"
  end
end
local function findfile(name, path)
  local res = vim.fn.findfile(name, path)
  if not core["empty?"](res) then
    return full_path(res)
  else
    return nil
  end
end
local function split_path(path)
  return str.split(path, path_sep())
end
local function join_path(parts)
  return str.join(path_sep(), core.concat(parts))
end
local function replace_dirs(path, from, to)
  local function _13_(segment)
    if (from == segment) then
      return to
    else
      return segment
    end
  end
  return join_path(core.map(_13_, split_path(path)))
end
local function fnl_path__3elua_path(fnl_path)
  return replace_dirs(replace_extension(fnl_path, "lua"), "fnl", "lua")
end
return {basename = basename, filename = filename, ["file-name-root"] = file_name_root, ["full-path"] = full_path, mkdirp = mkdirp, ["replace-extension"] = replace_extension, absglob = absglob, relglob = relglob, ["glob-dir-newer?"] = glob_dir_newer_3f, ["path-sep"] = path_sep, findfile = findfile, ["split-path"] = split_path, ["join-path"] = join_path, ["read-first-line"] = read_first_line, ["replace-dirs"] = replace_dirs, ["fnl-path->lua-path"] = fnl_path__3elua_path}
