local _2afile_2a = "fnl/aniseed/eval.fnl"
local _2amodule_name_2a = "conjure.aniseed.eval"
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
local a, compile, fennel, fs, nvim = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.compile"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["compile"] = compile
_2amodule_locals_2a["fennel"] = fennel
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
local function str(code, opts)
  local fnl = fennel.impl()
  local function _1_()
    return fnl.eval(compile["wrap-macros"](code, opts), a.merge({compilerEnv = _G}, opts))
  end
  return xpcall(_1_, fnl.traceback)
end
_2amodule_2a["str"] = str
local function clean_values(vals)
  local function _2_(val)
    if a["table?"](val) then
      return (compile["delete-marker"] ~= a.first(val))
    else
      return true
    end
  end
  return a.filter(_2_, vals)
end
_2amodule_locals_2a["clean-values"] = clean_values
local function clean_error(err)
  return string.gsub(string.gsub(err, "^%b[string .-%b]:%d+: ", ""), "^Compile error in .-:%d+\n%s+", "")
end
_2amodule_2a["clean-error"] = clean_error
local function repl(opts)
  local eval_values = nil
  local fnl = fennel.impl()
  local opts0 = (opts or {})
  local co
  local function _4_()
    local function _5_(_241)
      eval_values = clean_values(_241)
      return nil
    end
    local function _6_(_241, _242)
      return (opts0["error-handler"] or nvim.err_writeln)(clean_error(_242))
    end
    return fnl.repl(a.merge({compilerEnv = _G, pp = a.identity, readChunk = coroutine.yield, onValues = _5_, onError = _6_}, opts0))
  end
  co = coroutine.create(_4_)
  coroutine.resume(co)
  coroutine.resume(co, compile["wrap-macros"](nil, opts0))
  eval_values = nil
  local function _7_(code)
    ANISEED_STATIC_MODULES = false
    coroutine.resume(co, code)
    local prev_eval_values = eval_values
    eval_values = nil
    return prev_eval_values
  end
  return _7_
end
_2amodule_2a["repl"] = repl
return _2amodule_2a
