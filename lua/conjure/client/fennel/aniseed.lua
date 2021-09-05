local _2afile_2a = "fnl/conjure/client/fennel/aniseed.fnl"
local _2amodule_name_2a = "conjure.client.fennel.aniseed"
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
local a, client, config, extract, log, mapping, nvim, str, text, view = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.aniseed.view")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
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
config.merge({client = {fennel = {aniseed = {aniseed_module_prefix = "conjure.aniseed.", mapping = {run_all_tests = "ta", run_buf_tests = "tt"}, use_metadata = true}}}})
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
local function repl(opts)
  local filename = a.get(opts, "filename")
  local function _2_()
    local repl0 = anic("eval", "repl", opts)
    repl0(("(module " .. opts.moduleName .. ")\n"))
    do end (repls)[filename] = repl0
    return repl0
  end
  return (a.get(repls, filename) or _2_())
end
_2amodule_locals_2a["repl"] = repl
local function display_result(opts)
  if opts then
    local _let_3_ = opts
    local ok_3f = _let_3_["ok?"]
    local results = _let_3_["results"]
    local result_str
    if ok_3f then
      if a["empty?"](results) then
        result_str = "nil"
      else
        result_str = str.join("\n", a.map(view.serialise, results))
      end
    else
      result_str = a.first(results)
    end
    local result_lines = str.split(result_str, "\n")
    if not opts["passive?"] then
      local function _7_()
        if ok_3f then
          return result_lines
        else
          local function _6_(_241)
            return ("; " .. _241)
          end
          return a.map(_6_, result_lines)
        end
      end
      log.append(_7_())
    end
    if opts["on-result-raw"] then
      opts["on-result-raw"](results)
    end
    if opts["on-result"] then
      return opts["on-result"](result_str)
    end
  end
end
_2amodule_2a["display-result"] = display_result
local function eval_str(opts)
  local function _12_()
    local out
    local function _13_()
      if (cfg({"use_metadata"}) and not package.loaded.fennel) then
        package.loaded.fennel = anic("fennel", "impl")
      end
      local eval
      local function _15_(err_type, err, lua_source)
        opts["ok?"] = false
        opts.results = {err}
        return nil
      end
      eval = repl({filename = opts["file-path"], moduleName = (opts.context or "conjure.aniseed.user"), onError = _15_, useMetadata = cfg({"use_metadata"})})
      local results = eval((opts.code .. "\n"))
      if (nil == opts["ok?"]) then
        opts["ok?"] = true
        opts.results = results
        return nil
      end
    end
    out = anic("nu", "with-out-str", _13_)
    if not a["empty?"](out) then
      log.append(text["prefixed-lines"](text["trim-last-newline"](out), "; (out) "))
    end
    return display_result(opts)
  end
  return client.wrap(_12_)()
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
  end
end
_2amodule_2a["eval-file"] = eval_file
local function wrapped_test(req_lines, f)
  log.append(req_lines, {["break?"] = true})
  local res = anic("nu", "with-out-str", f)
  local _19_
  if ("" == res) then
    _19_ = "No results."
  else
    _19_ = res
  end
  return log.append(text["prefixed-lines"](_19_, "; "))
end
_2amodule_locals_2a["wrapped-test"] = wrapped_test
local function run_buf_tests()
  local c = extract.context()
  if c then
    local function _21_()
      return anic("test", "run", c)
    end
    return wrapped_test({("; run-buf-tests (" .. c .. ")")}, _21_)
  end
end
_2amodule_2a["run-buf-tests"] = run_buf_tests
local function run_all_tests()
  return wrapped_test({"; run-all-tests"}, ani("test", "run-all"))
end
_2amodule_2a["run-all-tests"] = run_all_tests
local function on_filetype()
  mapping.buf("n", "FnlRunBufTests", cfg({"mapping", "run_buf_tests"}), _2amodule_name_2a, "run-buf-tests")
  return mapping.buf("n", "FnlRunAllTests", cfg({"mapping", "run_all_tests"}), _2amodule_name_2a, "run-all-tests")
end
_2amodule_2a["on-filetype"] = on_filetype
local function value__3ecompletions(x)
  if ("table" == type(x)) then
    local function _25_(_23_)
      local _arg_24_ = _23_
      local k = _arg_24_[1]
      local v = _arg_24_[2]
      return {info = nil, kind = type(v), menu = nil, word = k}
    end
    local function _28_(_26_)
      local _arg_27_ = _26_
      local k = _arg_27_[1]
      local v = _arg_27_[2]
      return ("_LOCALS" ~= k)
    end
    local function _29_()
      if x["aniseed/autoload-enabled?"] then
        do local _ = x["trick-aniseed-into-loading-the-module"] end
        return x["aniseed/autoload-module"]
      else
        return x
      end
    end
    return a.map(_25_, a.filter(_28_, a["kv-pairs"](_29_())))
  end
end
_2amodule_2a["value->completions"] = value__3ecompletions
local function completions(opts)
  local code
  if not str["blank?"](opts.prefix) then
    code = ("((. (require :" .. _2amodule_name_2a .. ") :value->completions) " .. string.gsub(opts.prefix, "%..*$", "") .. ")")
  else
  code = nil
  end
  local mods = value__3ecompletions(package.loaded)
  local locals
  do
    local ok_3f, m = nil, nil
    local function _32_()
      return require(opts.context)
    end
    ok_3f, m = (opts.context and pcall(_32_))
    if ok_3f then
      locals = a.concat(value__3ecompletions(m), value__3ecompletions(a.get(m, "_LOCALS")), mods)
    else
      locals = mods
    end
  end
  local result_fn
  local function _34_(results)
    local xs = a.first(results)
    local function _37_()
      if ("table" == type(xs)) then
        local function _35_(x)
          local function _36_(_241)
            return (opts.prefix .. _241)
          end
          return a.update(x, "word", _36_)
        end
        return a.concat(a.map(_35_, xs), locals)
      else
        return locals
      end
    end
    return opts.cb(_37_())
  end
  result_fn = _34_
  local ok_3f, err_or_res = nil, nil
  if code then
    local function _38_()
      return eval_str({["on-result-raw"] = result_fn, ["passive?"] = true, code = code, context = opts.context})
    end
    ok_3f, err_or_res = pcall(_38_)
  else
  ok_3f, err_or_res = nil
  end
  if not ok_3f then
    return opts.cb(locals)
  end
end
_2amodule_2a["completions"] = completions