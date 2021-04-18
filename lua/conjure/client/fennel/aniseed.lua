local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.fennel.aniseed"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.extract"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.aniseed.view")}
local a = _local_0_[1]
local view = _local_0_[10]
local client = _local_0_[2]
local config = _local_0_[3]
local extract = _local_0_[4]
local log = _local_0_[5]
local mapping = _local_0_[6]
local nvim = _local_0_[7]
local str = _local_0_[8]
local text = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.fennel.aniseed"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_0_ = ".fnl"
  _0_0["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local context_pattern
do
  local v_0_ = "%(%s*module%s+(.-)[%s){]"
  _0_0["context-pattern"] = v_0_
  context_pattern = v_0_
end
local comment_prefix
do
  local v_0_ = "; "
  _0_0["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
config.merge({client = {fennel = {aniseed = {aniseed_module_prefix = "conjure.aniseed.", mapping = {run_all_tests = "ta", run_buf_tests = "tt"}, use_metadata = true}}}})
local cfg = config["get-in-fn"]({"client", "fennel", "aniseed"})
local ani_aliases = {nu = "nvim.util"}
local function ani(mod_name, f_name)
  local mod_name0 = a.get(ani_aliases, mod_name, mod_name)
  local mod = require((cfg({"aniseed_module_prefix"}) .. mod_name0))
  if f_name then
    return a.get(mod, f_name)
  else
    return mod
  end
end
local function anic(mod, f_name, ...)
  return ani(mod, f_name)(...)
end
local display_result
do
  local v_0_
  local function display_result0(opts)
    if opts then
      local _let_0_ = opts
      local ok_3f = _let_0_["ok?"]
      local results = _let_0_["results"]
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
        local function _2_()
          if ok_3f then
            return result_lines
          else
            local function _2_(_241)
              return ("; " .. _241)
            end
            return a.map(_2_, result_lines)
          end
        end
        log.append(_2_())
      end
      if opts["on-result-raw"] then
        opts["on-result-raw"](results)
      end
      if opts["on-result"] then
        return opts["on-result"](result_str)
      end
    end
  end
  v_0_ = display_result0
  _0_0["display-result"] = v_0_
  display_result = v_0_
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    local function _1_()
      local code = (("(module " .. (opts.context or "aniseed.user") .. ") ") .. opts.code .. "\n")
      local out
      local function _2_()
        if cfg({"use_metadata"}) then
          package.loaded.fennel = ani("fennel")
        end
        local _let_0_ = {anic("eval", "str", code, {filename = opts["file-path"], useMetadata = cfg({"use_metadata"})})}
        local ok_3f = _let_0_[1]
        local results = {(table.unpack or unpack)(_let_0_, 2)}
        opts["ok?"] = ok_3f
        opts.results = results
        return nil
      end
      out = anic("nu", "with-out-str", _2_)
      if not a["empty?"](out) then
        log.append(text["prefixed-lines"](text["trim-last-newline"](out), "; (out) "))
      end
      return display_result(opts)
    end
    return client.wrap(_1_)()
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str
do
  local v_0_
  local function doc_str0(opts)
    a.assoc(opts, "code", ("(doc " .. opts.code .. ")"))
    return eval_str(opts)
  end
  v_0_ = doc_str0
  _0_0["doc-str"] = v_0_
  doc_str = v_0_
end
local eval_file
do
  local v_0_
  local function eval_file0(opts)
    opts.code = a.slurp(opts["file-path"])
    if opts.code then
      return eval_str(opts)
    end
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local function wrapped_test(req_lines, f)
  log.append(req_lines, {["break?"] = true})
  local res = anic("nu", "with-out-str", f)
  local _1_
  if ("" == res) then
    _1_ = "No results."
  else
    _1_ = res
  end
  return log.append(text["prefixed-lines"](_1_, "; "))
end
local run_buf_tests
do
  local v_0_
  local function run_buf_tests0()
    local c = extract.context()
    if c then
      local function _1_()
        return anic("test", "run", c)
      end
      return wrapped_test({("; run-buf-tests (" .. c .. ")")}, _1_)
    end
  end
  v_0_ = run_buf_tests0
  _0_0["run-buf-tests"] = v_0_
  run_buf_tests = v_0_
end
local run_all_tests
do
  local v_0_
  local function run_all_tests0()
    return wrapped_test({"; run-all-tests"}, ani("test", "run-all"))
  end
  v_0_ = run_all_tests0
  _0_0["run-all-tests"] = v_0_
  run_all_tests = v_0_
end
local on_filetype
do
  local v_0_
  local function on_filetype0()
    mapping.buf("n", "FnlRunBufTests", cfg({"mapping", "run_buf_tests"}), _2amodule_name_2a, "run-buf-tests")
    return mapping.buf("n", "FnlRunAllTests", cfg({"mapping", "run_all_tests"}), _2amodule_name_2a, "run-all-tests")
  end
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
local value__3ecompletions
do
  local v_0_
  local function value__3ecompletions0(x)
    if ("table" == type(x)) then
      local function _2_(_1_0)
        local _arg_0_ = _1_0
        local k = _arg_0_[1]
        local v = _arg_0_[2]
        return {info = nil, kind = type(v), menu = nil, word = k}
      end
      return a.map(_2_, a["kv-pairs"](x))
    end
  end
  v_0_ = value__3ecompletions0
  _0_0["value->completions"] = v_0_
  value__3ecompletions = v_0_
end
local completions
do
  local v_0_
  local function completions0(opts)
    local code
    if not str["blank?"](opts.prefix) then
      code = ("((. (require :" .. _2amodule_name_2a .. ") :value->completions) " .. (opts.prefix):gsub(".$", "") .. ")")
    else
    code = nil
    end
    local mods = value__3ecompletions(package.loaded)
    local locals
    do
      local ok_3f, m = nil, nil
      local function _2_()
        return require(opts.context)
      end
      ok_3f, m = (opts.context and pcall(_2_))
      if ok_3f then
        locals = a.concat(value__3ecompletions(a.get(m, "aniseed/locals")), value__3ecompletions(a["get-in"](m, {"aniseed/local-fns", "require"})), mods)
      else
        locals = mods
      end
    end
    local result_fn
    local function _2_(results)
      local xs = a.first(results)
      local function _3_()
        if ("table" == type(xs)) then
          local function _3_(x)
            local function _4_(_241)
              return (opts.prefix .. _241)
            end
            return a.update(x, "word", _4_)
          end
          return a.concat(a.map(_3_, xs), locals)
        else
          return locals
        end
      end
      return opts.cb(_3_())
    end
    result_fn = _2_
    local _, ok_3f = nil, nil
    if code then
      local function _3_()
        return eval_str({["on-result-raw"] = result_fn, ["passive?"] = true, code = code, context = opts.context})
      end
      _, ok_3f = pcall(_3_)
    else
    _, ok_3f = nil
    end
    if not ok_3f then
      return opts.cb(locals)
    end
  end
  v_0_ = completions0
  _0_0["completions"] = v_0_
  completions = v_0_
end
return nil