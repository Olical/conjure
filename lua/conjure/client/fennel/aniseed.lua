local _2afile_2a = "fnl/conjure/client/fennel/aniseed.fnl"
local _2amodule_name_2a = "conjure.client.fennel.aniseed"
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
local a, client, config, extract, fs, log, mapping, nvim, str, text, view = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.aniseed.view")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["view"] = view
local buf_suffix = ".fnl"
_2amodule_2a["buf-suffix"] = buf_suffix
local context_pattern = "%(%s*module%s+(.-)[%s){]"
_2amodule_2a["context-pattern"] = context_pattern
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
config.merge({client = {fennel = {aniseed = {mapping = {run_buf_tests = "tt", run_all_tests = "ta", reset_repl = "rr", reset_all_repls = "ra"}, aniseed_module_prefix = "conjure.aniseed.", use_metadata = true}}}})
local cfg = config["get-in-fn"]({"client", "fennel", "aniseed"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local ani_aliases = {nu = "nvim.util"}
_2amodule_locals_2a["ani-aliases"] = ani_aliases
local function ani(mod_name, f_name)
  local mod_name0 = a.get(ani_aliases, mod_name, mod_name)
  local mod = require((cfg({"aniseed_module_prefix"}) .. mod_name0))
  if f_name then
    return a.get(mod, f_name)
  else
    return mod
  end
end
_2amodule_locals_2a["ani"] = ani
local function anic(mod, f_name, ...)
  return ani(mod, f_name)(...)
end
_2amodule_locals_2a["anic"] = anic
local repls = (repls or {})
do end (_2amodule_locals_2a)["repls"] = repls
local function reset_repl(filename)
  local filename0 = (filename or fs["localise-path"](extract["file-path"]()))
  do end (repls)[filename0] = nil
  return log.append({("; Reset REPL for " .. filename0)}, {["break?"] = true})
end
_2amodule_2a["reset-repl"] = reset_repl
local function reset_all_repls()
  local function _2_(filename)
    repls[filename] = nil
    return nil
  end
  a["run!"](_2_, a.keys(repls))
  return log.append({"; Reset all REPLs"}, {["break?"] = true})
end
_2amodule_2a["reset-all-repls"] = reset_all_repls
local default_module_name = "conjure.user"
_2amodule_2a["default-module-name"] = default_module_name
local function module_name(context, file_path)
  if context then
    return context
  elseif file_path then
    return (fs["file-path->module-name"](file_path) or default_module_name)
  else
    return default_module_name
  end
end
_2amodule_2a["module-name"] = module_name
local function repl(opts)
  local filename = a.get(opts, "filename")
  local function _7_()
    local ret = {}
    local _
    local function _4_(err)
      ret["ok?"] = false
      ret.results = {err}
      return nil
    end
    opts["error-handler"] = _4_
    _ = nil
    local eval_21 = anic("eval", "repl", opts)
    local repl0
    local function _5_(code)
      ret["ok?"] = nil
      ret.results = nil
      local results = eval_21(code)
      if a["nil?"](ret["ok?"]) then
        ret["ok?"] = true
        ret.results = results
      else
      end
      return ret
    end
    repl0 = _5_
    repl0(("(module " .. a.get(opts, "moduleName") .. ")"))
    do end (repls)[filename] = repl0
    return repl0
  end
  return ((not a.get(opts, "fresh?") and a.get(repls, filename)) or _7_())
end
_2amodule_2a["repl"] = repl
local function display_result(opts)
  if opts then
    local _let_8_ = opts
    local ok_3f = _let_8_["ok?"]
    local results = _let_8_["results"]
    local result_str
    local _9_
    if ok_3f then
      if not a["empty?"](results) then
        _9_ = str.join("\n", a.map(view.serialise, results))
      else
        _9_ = nil
      end
    else
      _9_ = a.first(results)
    end
    result_str = (_9_ or "nil")
    local result_lines = str.split(result_str, "\n")
    if not opts["passive?"] then
      local function _13_()
        if ok_3f then
          return result_lines
        else
          local function _12_(_241)
            return ("; " .. _241)
          end
          return a.map(_12_, result_lines)
        end
      end
      log.append(_13_())
    else
    end
    if opts["on-result-raw"] then
      opts["on-result-raw"](results)
    else
    end
    if opts["on-result"] then
      return opts["on-result"](result_str)
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_2a["display-result"] = display_result
local function eval_str(opts)
  local function _18_()
    local out
    local function _19_()
      if (cfg({"use_metadata"}) and not package.loaded.fennel) then
        package.loaded.fennel = anic("fennel", "impl")
      else
      end
      local eval_21 = repl({filename = opts["file-path"], moduleName = module_name(opts.context, opts["file-path"]), useMetadata = cfg({"use_metadata"}), ["fresh?"] = (("file" == opts.origin) or ("buf" == opts.origin) or text["starts-with"](opts.code, ("(module " .. (opts.context or ""))))})
      local _let_21_ = eval_21((opts.code .. "\n"))
      local ok_3f = _let_21_["ok?"]
      local results = _let_21_["results"]
      opts["ok?"] = ok_3f
      opts.results = results
      return nil
    end
    out = anic("nu", "with-out-str", _19_)
    if not a["empty?"](out) then
      log.append(text["prefixed-lines"](text["trim-last-newline"](out), "; (out) "))
    else
    end
    return display_result(opts)
  end
  return client.wrap(_18_)()
end
_2amodule_2a["eval-str"] = eval_str
local function doc_str(opts)
  a.assoc(opts, "code", ("(doc " .. opts.code .. ")"))
  return eval_str(opts)
end
_2amodule_2a["doc-str"] = doc_str
local function eval_file(opts)
  opts.code = a.slurp(opts["file-path"])
  if opts.code then
    return eval_str(opts)
  else
    return nil
  end
end
_2amodule_2a["eval-file"] = eval_file
local function wrapped_test(req_lines, f)
  log.append(req_lines, {["break?"] = true})
  local res = anic("nu", "with-out-str", f)
  local _24_
  if ("" == res) then
    _24_ = "No results."
  else
    _24_ = res
  end
  return log.append(text["prefixed-lines"](_24_, "; "))
end
_2amodule_locals_2a["wrapped-test"] = wrapped_test
local function run_buf_tests()
  local c = extract.context()
  if c then
    local function _26_()
      return anic("test", "run", c)
    end
    return wrapped_test({("; run-buf-tests (" .. c .. ")")}, _26_)
  else
    return nil
  end
end
_2amodule_2a["run-buf-tests"] = run_buf_tests
local function run_all_tests()
  return wrapped_test({"; run-all-tests"}, ani("test", "run-all"))
end
_2amodule_2a["run-all-tests"] = run_all_tests
local function on_filetype()
  mapping.buf("n", "FnlRunBufTests", cfg({"mapping", "run_buf_tests"}), _2amodule_name_2a, "run-buf-tests")
  mapping.buf("n", "FnlRunAllTests", cfg({"mapping", "run_all_tests"}), _2amodule_name_2a, "run-all-tests")
  mapping.buf("n", "FnlResetREPL", cfg({"mapping", "reset_repl"}), _2amodule_name_2a, "reset-repl")
  return mapping.buf("n", "FnlResetAllREPLs", cfg({"mapping", "reset_all_repls"}), _2amodule_name_2a, "reset-all-repls")
end
_2amodule_2a["on-filetype"] = on_filetype
local function value__3ecompletions(x)
  if ("table" == type(x)) then
    local function _30_(_28_)
      local _arg_29_ = _28_
      local k = _arg_29_[1]
      local v = _arg_29_[2]
      return {word = k, kind = type(v), menu = nil, info = nil}
    end
    local function _33_(_31_)
      local _arg_32_ = _31_
      local k = _arg_32_[1]
      local v = _arg_32_[2]
      return not text["starts-with"](k, "aniseed/")
    end
    local function _34_()
      if x["aniseed/autoload-enabled?"] then
        do local _ = x["trick-aniseed-into-loading-the-module"] end
        return x["aniseed/autoload-module"]
      else
        return x
      end
    end
    return a.map(_30_, a.filter(_33_, a["kv-pairs"](_34_())))
  else
    return nil
  end
end
_2amodule_2a["value->completions"] = value__3ecompletions
local function completions(opts)
  local code
  if not str["blank?"](opts.prefix) then
    local prefix = string.gsub(opts.prefix, ".$", "")
    code = ("((. (require :" .. _2amodule_name_2a .. ") :value->completions) " .. prefix .. ")")
  else
    code = nil
  end
  local mods = value__3ecompletions(package.loaded)
  local locals
  do
    local ok_3f, m = nil, nil
    local function _37_()
      return require(opts.context)
    end
    ok_3f, m = pcall(_37_)
    if ok_3f then
      locals = a.concat(value__3ecompletions(m), value__3ecompletions(a.get(m, "aniseed/locals")), mods)
    else
      locals = mods
    end
  end
  local result_fn
  local function _39_(results)
    local xs = a.first(results)
    local function _42_()
      if ("table" == type(xs)) then
        local function _40_(x)
          local function _41_(_241)
            return (opts.prefix .. _241)
          end
          return a.update(x, "word", _41_)
        end
        return a.concat(a.map(_40_, xs), locals)
      else
        return locals
      end
    end
    return opts.cb(_42_())
  end
  result_fn = _39_
  local ok_3f, err_or_res = nil, nil
  if code then
    local function _43_()
      return eval_str({["file-path"] = opts["file-path"], context = opts.context, code = code, ["passive?"] = true, ["on-result-raw"] = result_fn})
    end
    ok_3f, err_or_res = pcall(_43_)
  else
    ok_3f, err_or_res = nil
  end
  if not ok_3f then
    return opts.cb(locals)
  else
    return nil
  end
end
_2amodule_2a["completions"] = completions