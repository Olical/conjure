local _2afile_2a = "fnl/aniseed/compile.fnl"
local _2amodule_name_2a = "conjure.aniseed.compile"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, fennel, fs, nvim = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["fennel"] = fennel
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
local function wrap_macros(code, opts)
  local macros_module = "conjure.aniseed.macros"
  local filename
  do
    local _1_ = a.get(opts, "filename")
    if (nil ~= _1_) then
      filename = string.gsub(_1_, (nvim.fn.getcwd() .. fs["path-sep"]), "")
    else
      filename = _1_
    end
  end
  local function _3_()
    if filename then
      return ("\"" .. string.gsub(filename, "\\", "\\\\") .. "\"")
    else
      return "nil"
    end
  end
  return ("(local *file* " .. _3_() .. ")" .. "(require-macros \"" .. macros_module .. "\")\n" .. "(wrap-module-body " .. (code or "") .. ")")
end
_2amodule_2a["wrap-macros"] = wrap_macros
local marker_prefix = "ANISEED_"
_2amodule_2a["marker-prefix"] = marker_prefix
local delete_marker = (marker_prefix .. "DELETE_ME")
do end (_2amodule_2a)["delete-marker"] = delete_marker
local delete_marker_pat = ("\n[^\n]-\"" .. delete_marker .. "\".-")
do end (_2amodule_locals_2a)["delete-marker-pat"] = delete_marker_pat
local function str(code, opts)
  ANISEED_STATIC_MODULES = (true == a.get(opts, "static?"))
  local fnl = fennel.impl()
  local function _4_()
    return string.gsub(string.gsub(fnl.compileString(wrap_macros(code, opts), a["merge!"]({compilerEnv = _G, allowedGlobals = false}, opts)), (delete_marker_pat .. "\n"), "\n"), (delete_marker_pat .. "$"), "")
  end
  return xpcall(_4_, fnl.traceback)
end
_2amodule_2a["str"] = str
local function file(src, dest, opts)
  local code = a.slurp(src)
  local _5_, _6_ = str(code, a["merge!"]({filename = src, ["static?"] = true}, opts))
  if ((_5_ == false) and (nil ~= _6_)) then
    local err = _6_
    return nvim.err_writeln(err)
  elseif ((_5_ == true) and (nil ~= _6_)) then
    local result = _6_
    fs.mkdirp(fs.basename(dest))
    return a.spit(dest, result)
  else
    return nil
  end
end
_2amodule_2a["file"] = file
local function glob(src_expr, src_dir, dest_dir, opts)
  for _, path in ipairs(fs.relglob(src_dir, src_expr)) do
    if fs["macro-file-path?"](path) then
      local dest = (dest_dir .. path)
      fs.mkdirp(fs.basename(dest))
      a.spit(dest, a.slurp((src_dir .. path)))
    else
      file((src_dir .. path), string.gsub((dest_dir .. path), ".fnl$", ".lua"), opts)
    end
  end
  return nil
end
_2amodule_2a["glob"] = glob
return _2amodule_2a
