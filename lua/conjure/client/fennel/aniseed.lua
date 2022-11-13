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
local a, client, config, extract, fs, log, mapping, nvim, str, text, ts, view = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), autoload("conjure.aniseed.view")
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
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["view"] = view
local comment_node_3f = ts["lisp-comment-node?"]
_2amodule_2a["comment-node?"] = comment_node_3f
local function form_node_3f(node)
  return ts["node-surrounded-by-form-pair-chars?"](node, {{"#(", ")"}})
end
_2amodule_2a["form-node?"] = form_node_3f
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
local repls = ((_2amodule_2a).repls or {})
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
    local function _10_()
      if ok_3f then
        if not a["empty?"](results) then
          return str.join("\n", a.map(view.serialise, results))
        else
          return nil
        end
      else
        return a.first(results)
      end
    end
    result_str = (_10_() or "nil")
    local result_lines = str.split(result_str, "\n")
    if not opts["passive?"] then
      local function _12_()
        if ok_3f then
          return result_lines
        else
          local function _11_(_241)
            return ("; " .. _241)
          end
          return a.map(_11_, result_lines)
        end
      end
      log.append(_12_())
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
  local function _17_()
    local out
    local function _18_()
      if (cfg({"use_metadata"}) and not package.loaded.fennel) then
        package.loaded.fennel = anic("fennel", "impl")
      else
      end
      local eval_21 = repl({filename = opts["file-path"], moduleName = module_name(opts.context, opts["file-path"]), useMetadata = cfg({"use_metadata"}), ["fresh?"] = (("file" == opts.origin) or ("buf" == opts.origin) or text["starts-with"](opts.code, ("(module " .. (opts.context or ""))))})
      local _let_20_ = eval_21((opts.code .. "\n"))
      local ok_3f = _let_20_["ok?"]
      local results = _let_20_["results"]
      if ("ok" ~= a["get-in"](eval_21(":ok\n"), {"results", 1})) then
        log.append({"; REPL appears to be stuck, did you open a string or form and not close it?", str.join({"; You can use ", config["get-in"]({"mapping", "prefix"}), cfg({"mapping", "reset_repl"}), " to reset and repair the REPL."})})
      else
      end
      opts["ok?"] = ok_3f
      opts.results = results
      return nil
    end
    out = anic("nu", "with-out-str", _18_)
    if not a["empty?"](out) then
      log.append(text["prefixed-lines"](text["trim-last-newline"](out), "; (out) "))
    else
    end
    return display_result(opts)
  end
  return client.wrap(_17_)()
end
_2amodule_2a["eval-str"] = eval_str
local function doc_str(opts)
  a.assoc(opts, "code", (",doc " .. opts.code))
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
  local function _28_()
    return run_buf_tests()
  end
  mapping.buf("FnlRunBufTests", cfg({"mapping", "run_buf_tests"}), _28_, {desc = "Run loaded buffer tests"})
  local function _29_()
    return run_all_tests()
  end
  mapping.buf("FnlRunAllTests", cfg({"mapping", "run_all_tests"}), _29_, {desc = "Run all loaded tests"})
  local function _30_()
    return reset_repl()
  end
  mapping.buf("FnlResetREPL", cfg({"mapping", "reset_repl"}), _30_, {desc = "Reset the current REPL state"})
  local function _31_()
    return reset_all_repls()
  end
  return mapping.buf("FnlResetAllREPLs", cfg({"mapping", "reset_all_repls"}), _31_, {desc = "Reset all REPL states"})
end
_2amodule_2a["on-filetype"] = on_filetype
local function value__3ecompletions(x)
  if ("table" == type(x)) then
    local function _34_(_32_)
      local _arg_33_ = _32_
      local k = _arg_33_[1]
      local v = _arg_33_[2]
      return {word = k, kind = type(v), menu = nil, info = nil}
    end
    local function _37_(_35_)
      local _arg_36_ = _35_
      local k = _arg_36_[1]
      local v = _arg_36_[2]
      return not text["starts-with"](k, "aniseed/")
    end
    local function _38_()
      if x["aniseed/autoload-enabled?"] then
        do local _ = x["trick-aniseed-into-loading-the-module"] end
        return x["aniseed/autoload-module"]
      else
        return x
      end
    end
    return a.map(_34_, a.filter(_37_, a["kv-pairs"](_38_())))
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
    local function _41_()
      return require(opts.context)
    end
    ok_3f, m = pcall(_41_)
    if ok_3f then
      locals = a.concat(value__3ecompletions(m), value__3ecompletions(a.get(m, "aniseed/locals")), mods)
    else
      locals = mods
    end
  end
  local result_fn
  local function _43_(results)
    local xs = a.first(results)
    local function _46_()
      if ("table" == type(xs)) then
        local function _44_(x)
          local function _45_(_241)
            return (opts.prefix .. _241)
          end
          return a.update(x, "word", _45_)
        end
        return a.concat(a.map(_44_, xs), locals)
      else
        return locals
      end
    end
    return opts.cb(_46_())
  end
  result_fn = _43_
  local ok_3f, err_or_res = nil, nil
  if code then
    local function _47_()
      return eval_str({["file-path"] = opts["file-path"], context = opts.context, code = code, ["passive?"] = true, ["on-result-raw"] = result_fn})
    end
    ok_3f, err_or_res = pcall(_47_)
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
return _2amodule_2a