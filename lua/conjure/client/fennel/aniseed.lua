-- [nfnl] Compiled from fnl/conjure/client/fennel/aniseed.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.fennel.aniseed"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
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
local buf_suffix = (_2amodule_2a)["buf-suffix"]
local comment_node_3f = (_2amodule_2a)["comment-node?"]
local comment_prefix = (_2amodule_2a)["comment-prefix"]
local completions = (_2amodule_2a).completions
local context_pattern = (_2amodule_2a)["context-pattern"]
local default_module_name = (_2amodule_2a)["default-module-name"]
local display_result = (_2amodule_2a)["display-result"]
local doc_str = (_2amodule_2a)["doc-str"]
local eval_file = (_2amodule_2a)["eval-file"]
local eval_str = (_2amodule_2a)["eval-str"]
local form_node_3f = (_2amodule_2a)["form-node?"]
local module_name = (_2amodule_2a)["module-name"]
local on_filetype = (_2amodule_2a)["on-filetype"]
local repl = (_2amodule_2a).repl
local reset_all_repls = (_2amodule_2a)["reset-all-repls"]
local reset_repl = (_2amodule_2a)["reset-repl"]
local run_all_tests = (_2amodule_2a)["run-all-tests"]
local run_buf_tests = (_2amodule_2a)["run-buf-tests"]
local value__3ecompletions = (_2amodule_2a)["value->completions"]
local a0 = (_2amodule_locals_2a).a
local ani = (_2amodule_locals_2a).ani
local ani_aliases = (_2amodule_locals_2a)["ani-aliases"]
local anic = (_2amodule_locals_2a).anic
local cfg = (_2amodule_locals_2a).cfg
local client0 = (_2amodule_locals_2a).client
local config0 = (_2amodule_locals_2a).config
local extract0 = (_2amodule_locals_2a).extract
local fs0 = (_2amodule_locals_2a).fs
local log0 = (_2amodule_locals_2a).log
local mapping0 = (_2amodule_locals_2a).mapping
local nvim0 = (_2amodule_locals_2a).nvim
local repls = (_2amodule_locals_2a).repls
local str0 = (_2amodule_locals_2a).str
local text0 = (_2amodule_locals_2a).text
local ts0 = (_2amodule_locals_2a).ts
local view0 = (_2amodule_locals_2a).view
local wrapped_test = (_2amodule_locals_2a)["wrapped-test"]
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local comment_node_3f0 = ts0["lisp-comment-node?"]
_2amodule_2a["comment-node?"] = comment_node_3f0
do local _ = {nil, nil} end
local function form_node_3f0(node)
  return ts0["node-surrounded-by-form-pair-chars?"](node, {{"#(", ")"}})
end
_2amodule_2a["form-node?"] = form_node_3f0
do local _ = {form_node_3f0, nil} end
local buf_suffix0 = ".fnl"
_2amodule_2a["buf-suffix"] = buf_suffix0
do local _ = {nil, nil} end
local context_pattern0 = "%(%s*module%s+(.-)[%s){]"
_2amodule_2a["context-pattern"] = context_pattern0
do local _ = {nil, nil} end
local comment_prefix0 = "; "
_2amodule_2a["comment-prefix"] = comment_prefix0
do local _ = {nil, nil} end
config0.merge({client = {fennel = {aniseed = {aniseed_module_prefix = "conjure.aniseed.", use_metadata = true}}}})
if config0["get-in"]({"mapping", "enable_defaults"}) then
  config0.merge({client = {fennel = {aniseed = {mapping = {run_buf_tests = "tt", run_all_tests = "ta", reset_repl = "rr", reset_all_repls = "ra"}}}}})
else
end
local cfg0 = config0["get-in-fn"]({"client", "fennel", "aniseed"})
do end (_2amodule_locals_2a)["cfg"] = cfg0
do local _ = {nil, nil} end
local ani_aliases0 = {nu = "nvim.util"}
_2amodule_locals_2a["ani-aliases"] = ani_aliases0
do local _ = {nil, nil} end
local function ani0(mod_name, f_name)
  local mod_name0 = a0.get(ani_aliases0, mod_name, mod_name)
  local mod = require((cfg0({"aniseed_module_prefix"}) .. mod_name0))
  if f_name then
    return a0.get(mod, f_name)
  else
    return mod
  end
end
_2amodule_locals_2a["ani"] = ani0
do local _ = {ani0, nil} end
local function anic0(mod, f_name, ...)
  return ani0(mod, f_name)(...)
end
_2amodule_locals_2a["anic"] = anic0
do local _ = {anic0, nil} end
local repls0 = ((_2amodule_2a).repls or {})
do end (_2amodule_locals_2a)["repls"] = repls0
do local _ = {nil, nil} end
local function reset_repl0(filename)
  local filename0 = (filename or fs0["localise-path"](extract0["file-path"]()))
  do end (repls0)[filename0] = nil
  return log0.append({("; Reset REPL for " .. filename0)}, {["break?"] = true})
end
_2amodule_2a["reset-repl"] = reset_repl0
do local _ = {reset_repl0, nil} end
local function reset_all_repls0()
  local function _3_(filename)
    repls0[filename] = nil
    return nil
  end
  a0["run!"](_3_, a0.keys(repls0))
  return log0.append({"; Reset all REPLs"}, {["break?"] = true})
end
_2amodule_2a["reset-all-repls"] = reset_all_repls0
do local _ = {reset_all_repls0, nil} end
local default_module_name0 = "conjure.user"
_2amodule_2a["default-module-name"] = default_module_name0
do local _ = {nil, nil} end
local function module_name0(context, file_path)
  if context then
    return context
  elseif file_path then
    return (fs0["file-path->module-name"](file_path) or default_module_name0)
  else
    return default_module_name0
  end
end
_2amodule_2a["module-name"] = module_name0
do local _ = {module_name0, nil} end
local function repl0(opts)
  local filename = a0.get(opts, "filename")
  local function _8_()
    local ret = {}
    local _
    local function _5_(err)
      ret["ok?"] = false
      ret.results = {err}
      return nil
    end
    opts["error-handler"] = _5_
    _ = nil
    local eval_21 = anic0("eval", "repl", opts)
    local repl1
    local function _6_(code)
      ret["ok?"] = nil
      ret.results = nil
      local results = eval_21(code)
      if a0["nil?"](ret["ok?"]) then
        ret["ok?"] = true
        ret.results = results
      else
      end
      return ret
    end
    repl1 = _6_
    repl1(("(module " .. a0.get(opts, "moduleName") .. ")"))
    do end (repls0)[filename] = repl1
    return repl1
  end
  return ((not a0.get(opts, "fresh?") and a0.get(repls0, filename)) or _8_())
end
_2amodule_2a["repl"] = repl0
do local _ = {repl0, nil} end
local function display_result0(opts)
  if opts then
    local _let_9_ = opts
    local ok_3f = _let_9_["ok?"]
    local results = _let_9_["results"]
    local result_str
    local function _11_()
      if ok_3f then
        if not a0["empty?"](results) then
          return str0.join("\n", a0.map(view0.serialise, results))
        else
          return nil
        end
      else
        return a0.first(results)
      end
    end
    result_str = (_11_() or "nil")
    local result_lines = str0.split(result_str, "\n")
    if not opts["passive?"] then
      local function _13_()
        if ok_3f then
          return result_lines
        else
          local function _12_(_241)
            return ("; " .. _241)
          end
          return a0.map(_12_, result_lines)
        end
      end
      log0.append(_13_())
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
_2amodule_2a["display-result"] = display_result0
do local _ = {display_result0, nil} end
local function eval_str0(opts)
  local function _18_()
    local out
    local function _19_()
      if (cfg0({"use_metadata"}) and not package.loaded.fennel) then
        package.loaded.fennel = anic0("fennel", "impl")
      else
      end
      local eval_21 = repl0({filename = opts["file-path"], moduleName = module_name0(opts.context, opts["file-path"]), useMetadata = cfg0({"use_metadata"}), ["fresh?"] = (("file" == opts.origin) or ("buf" == opts.origin) or text0["starts-with"](opts.code, ("(module " .. (opts.context or ""))))})
      local _let_21_ = eval_21((opts.code .. "\n"))
      local ok_3f = _let_21_["ok?"]
      local results = _let_21_["results"]
      if ("ok" ~= a0["get-in"](eval_21(":ok\n"), {"results", 1})) then
        log0.append({"; REPL appears to be stuck, did you open a string or form and not close it?", str0.join({"; You can use ", config0["get-in"]({"mapping", "prefix"}), cfg0({"mapping", "reset_repl"}), " to reset and repair the REPL."})})
      else
      end
      opts["ok?"] = ok_3f
      opts.results = results
      return nil
    end
    out = anic0("nu", "with-out-str", _19_)
    if not a0["empty?"](out) then
      log0.append(text0["prefixed-lines"](text0["trim-last-newline"](out), "; (out) "))
    else
    end
    return display_result0(opts)
  end
  return client0.wrap(_18_)()
end
_2amodule_2a["eval-str"] = eval_str0
do local _ = {eval_str0, nil} end
local function doc_str0(opts)
  a0.assoc(opts, "code", (",doc " .. opts.code))
  return eval_str0(opts)
end
_2amodule_2a["doc-str"] = doc_str0
do local _ = {doc_str0, nil} end
local function eval_file0(opts)
  opts.code = a0.slurp(opts["file-path"])
  if opts.code then
    return eval_str0(opts)
  else
    return nil
  end
end
_2amodule_2a["eval-file"] = eval_file0
do local _ = {eval_file0, nil} end
local function wrapped_test0(req_lines, f)
  log0.append(req_lines, {["break?"] = true})
  local res = anic0("nu", "with-out-str", f)
  local _25_
  if ("" == res) then
    _25_ = "No results."
  else
    _25_ = res
  end
  return log0.append(text0["prefixed-lines"](_25_, "; "))
end
_2amodule_locals_2a["wrapped-test"] = wrapped_test0
do local _ = {wrapped_test0, nil} end
local function run_buf_tests0()
  local c = extract0.context()
  if c then
    local function _27_()
      return anic0("test", "run", c)
    end
    return wrapped_test0({("; run-buf-tests (" .. c .. ")")}, _27_)
  else
    return nil
  end
end
_2amodule_2a["run-buf-tests"] = run_buf_tests0
do local _ = {run_buf_tests0, nil} end
local function run_all_tests0()
  return wrapped_test0({"; run-all-tests"}, ani0("test", "run-all"))
end
_2amodule_2a["run-all-tests"] = run_all_tests0
do local _ = {run_all_tests0, nil} end
local function on_filetype0()
  local function _29_()
    return run_buf_tests0()
  end
  mapping0.buf("FnlRunBufTests", cfg0({"mapping", "run_buf_tests"}), _29_, {desc = "Run loaded buffer tests"})
  local function _30_()
    return run_all_tests0()
  end
  mapping0.buf("FnlRunAllTests", cfg0({"mapping", "run_all_tests"}), _30_, {desc = "Run all loaded tests"})
  local function _31_()
    return reset_repl0()
  end
  mapping0.buf("FnlResetREPL", cfg0({"mapping", "reset_repl"}), _31_, {desc = "Reset the current REPL state"})
  local function _32_()
    return reset_all_repls0()
  end
  return mapping0.buf("FnlResetAllREPLs", cfg0({"mapping", "reset_all_repls"}), _32_, {desc = "Reset all REPL states"})
end
_2amodule_2a["on-filetype"] = on_filetype0
do local _ = {on_filetype0, nil} end
local function value__3ecompletions0(x)
  if ("table" == type(x)) then
    local function _35_(_33_)
      local _arg_34_ = _33_
      local k = _arg_34_[1]
      local v = _arg_34_[2]
      return {word = k, kind = type(v), menu = nil, info = nil}
    end
    local function _38_(_36_)
      local _arg_37_ = _36_
      local k = _arg_37_[1]
      local v = _arg_37_[2]
      return not text0["starts-with"](k, "aniseed/")
    end
    local function _39_()
      if x["aniseed/autoload-enabled?"] then
        do local _ = x["trick-aniseed-into-loading-the-module"] end
        return x["aniseed/autoload-module"]
      else
        return x
      end
    end
    return a0.map(_35_, a0.filter(_38_, a0["kv-pairs"](_39_())))
  else
    return nil
  end
end
_2amodule_2a["value->completions"] = value__3ecompletions0
do local _ = {value__3ecompletions0, nil} end
local function completions0(opts)
  local code
  if not str0["blank?"](opts.prefix) then
    local prefix = string.gsub(opts.prefix, ".$", "")
    code = ("((. (require :" .. _2amodule_name_2a .. ") :value->completions) " .. prefix .. ")")
  else
    code = nil
  end
  local mods = value__3ecompletions0(package.loaded)
  local locals
  do
    local ok_3f, m = nil, nil
    local function _42_()
      return require(opts.context)
    end
    ok_3f, m = pcall(_42_)
    if ok_3f then
      locals = a0.concat(value__3ecompletions0(m), value__3ecompletions0(a0.get(m, "aniseed/locals")), mods)
    else
      locals = mods
    end
  end
  local result_fn
  local function _44_(results)
    local xs = a0.first(results)
    local function _47_()
      if ("table" == type(xs)) then
        local function _45_(x)
          local function _46_(_241)
            return (opts.prefix .. _241)
          end
          return a0.update(x, "word", _46_)
        end
        return a0.concat(a0.map(_45_, xs), locals)
      else
        return locals
      end
    end
    return opts.cb(_47_())
  end
  result_fn = _44_
  local ok_3f, err_or_res = nil, nil
  if code then
    local function _48_()
      return eval_str0({["file-path"] = opts["file-path"], context = opts.context, code = code, ["passive?"] = true, ["on-result-raw"] = result_fn})
    end
    ok_3f, err_or_res = pcall(_48_)
  else
    ok_3f, err_or_res = nil
  end
  if not ok_3f then
    return opts.cb(locals)
  else
    return nil
  end
end
_2amodule_2a["completions"] = completions0
do local _ = {completions0, nil} end
return _2amodule_2a
