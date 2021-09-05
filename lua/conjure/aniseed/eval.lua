local _2afile_2a = "fnl/aniseed/eval.fnl"
local _2amodule_name_2a = "conjure.aniseed.eval"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["_LOCALS"] = {}
  _2amodule_locals_2a = (_2amodule_2a)._LOCALS
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, compile, fennel, fs, nvim = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.compile"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["compile"] = compile
_2amodule_locals_2a["fennel"] = fennel
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
local function str(code, opts)
  local fnl = fennel.impl()
  local function _1_()
    return fnl.eval(compile["macros-prefix"](code, opts), a.merge({compilerEnv = _G}, opts))
  end
  return xpcall(_1_, fnl.traceback)
end
_2amodule_2a["str"] = str
local function clean_values(vals)
  local function _2_(val)
    if a["table?"](val) then
      return ((compile["delete-marker"] ~= a.first(val)) and (compile["replace-marker"] ~= a.first(val)))
    else
      return true
    end
  end
  return a.filter(_2_, vals)
end
_2amodule_locals_2a["clean-values"] = clean_values
local function repl(opts)
  local eval_values = nil
  local fnl = fennel.impl()
  local co
  local function _4_()
    local function _5_(_241, _242)
      return nvim.err_writeln(_242)
    end
    local function _6_(_241)
      eval_values = clean_values(_241)
      return nil
    end
    return fnl.repl(a.merge({allowedGlobals = false, compilerEnv = _G, onError = _5_, onValues = _6_, pp = a.identity, readChunk = coroutine.yield}, opts))
  end
  co = coroutine.create(_4_)
  coroutine.resume(co)
  coroutine.resume(co, compile["macros-prefix"](nil, opts))
  eval_values = nil
  local function _7_(code)
    coroutine.resume(co, code)
    local prev_eval_values = eval_values
    eval_values = nil
    return prev_eval_values
  end
  return _7_
end
_2amodule_2a["repl"] = repl
