local _2afile_2a = "fnl/conjure/client/fennel/aniseed.fnl"
local _0_0
do
  local name_0_ = "conjure.client.fennel.aniseed"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.aniseed.view")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", extract = "conjure.extract", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", view = "conjure.aniseed.view"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
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
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_0_
  do
    local v_0_0 = ".fnl"
    _0_0["buf-suffix"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local context_pattern
do
  local v_0_
  do
    local v_0_0 = "%(%s*module%s+(.-)[%s){]"
    _0_0["context-pattern"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["context-pattern"] = v_0_
  context_pattern = v_0_
end
local comment_prefix
do
  local v_0_
  do
    local v_0_0 = "; "
    _0_0["comment-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
config.merge({client = {fennel = {aniseed = {aniseed_module_prefix = "conjure.aniseed.", mapping = {run_all_tests = "ta", run_buf_tests = "tt"}, use_metadata = true}}}})
local cfg
do
  local v_0_ = config["get-in-fn"]({"client", "fennel", "aniseed"})
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["cfg"] = v_0_
  cfg = v_0_
end
local ani_aliases
do
  local v_0_ = {nu = "nvim.util"}
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["ani-aliases"] = v_0_
  ani_aliases = v_0_
end
local ani
do
  local v_0_
  local function ani0(mod_name, f_name)
    local mod_name0 = a.get(ani_aliases, mod_name, mod_name)
    local mod = require((cfg({"aniseed_module_prefix"}) .. mod_name0))
    if f_name then
      return a.get(mod, f_name)
    else
      return mod
    end
  end
  v_0_ = ani0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["ani"] = v_0_
  ani = v_0_
end
local anic
do
  local v_0_
  local function anic0(mod, f_name, ...)
    return ani(mod, f_name)(...)
  end
  v_0_ = anic0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["anic"] = v_0_
  anic = v_0_
end
local display_result
do
  local v_0_
  do
    local v_0_0
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
          local function _3_()
            if ok_3f then
              return result_lines
            else
              local function _3_(_241)
                return ("; " .. _241)
              end
              return a.map(_3_, result_lines)
            end
          end
          log.append(_3_())
        end
        if opts["on-result-raw"] then
          opts["on-result-raw"](results)
        end
        if opts["on-result"] then
          return opts["on-result"](result_str)
        end
      end
    end
    v_0_0 = display_result0
    _0_0["display-result"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["display-result"] = v_0_
  display_result = v_0_
end
local eval_str
do
  local v_0_
  do
    local v_0_0
    local function eval_str0(opts)
      local function _2_()
        local code = (("(module " .. (opts.context or "conjure.aniseed.user") .. ") ") .. opts.code .. "\n")
        local out
        local function _3_()
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
        out = anic("nu", "with-out-str", _3_)
        if not a["empty?"](out) then
          log.append(text["prefixed-lines"](text["trim-last-newline"](out), "; (out) "))
        end
        return display_result(opts)
      end
      return client.wrap(_2_)()
    end
    v_0_0 = eval_str0
    _0_0["eval-str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str
do
  local v_0_
  do
    local v_0_0
    local function doc_str0(opts)
      a.assoc(opts, "code", ("(doc " .. opts.code .. ")"))
      return eval_str(opts)
    end
    v_0_0 = doc_str0
    _0_0["doc-str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["doc-str"] = v_0_
  doc_str = v_0_
end
local eval_file
do
  local v_0_
  do
    local v_0_0
    local function eval_file0(opts)
      opts.code = a.slurp(opts["file-path"])
      if opts.code then
        return eval_str(opts)
      end
    end
    v_0_0 = eval_file0
    _0_0["eval-file"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["eval-file"] = v_0_
  eval_file = v_0_
end
local wrapped_test
do
  local v_0_
  local function wrapped_test0(req_lines, f)
    log.append(req_lines, {["break?"] = true})
    local res = anic("nu", "with-out-str", f)
    local _2_
    if ("" == res) then
      _2_ = "No results."
    else
      _2_ = res
    end
    return log.append(text["prefixed-lines"](_2_, "; "))
  end
  v_0_ = wrapped_test0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["wrapped-test"] = v_0_
  wrapped_test = v_0_
end
local run_buf_tests
do
  local v_0_
  do
    local v_0_0
    local function run_buf_tests0()
      local c = extract.context()
      if c then
        local function _2_()
          return anic("test", "run", c)
        end
        return wrapped_test({("; run-buf-tests (" .. c .. ")")}, _2_)
      end
    end
    v_0_0 = run_buf_tests0
    _0_0["run-buf-tests"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["run-buf-tests"] = v_0_
  run_buf_tests = v_0_
end
local run_all_tests
do
  local v_0_
  do
    local v_0_0
    local function run_all_tests0()
      return wrapped_test({"; run-all-tests"}, ani("test", "run-all"))
    end
    v_0_0 = run_all_tests0
    _0_0["run-all-tests"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["run-all-tests"] = v_0_
  run_all_tests = v_0_
end
local on_filetype
do
  local v_0_
  do
    local v_0_0
    local function on_filetype0()
      mapping.buf("n", "FnlRunBufTests", cfg({"mapping", "run_buf_tests"}), _2amodule_name_2a, "run-buf-tests")
      return mapping.buf("n", "FnlRunAllTests", cfg({"mapping", "run_all_tests"}), _2amodule_name_2a, "run-all-tests")
    end
    v_0_0 = on_filetype0
    _0_0["on-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["on-filetype"] = v_0_
  on_filetype = v_0_
end
local value__3ecompletions
do
  local v_0_
  do
    local v_0_0
    local function value__3ecompletions0(x)
      if ("table" == type(x)) then
        local function _3_(_2_0)
          local _arg_0_ = _2_0
          local k = _arg_0_[1]
          local v = _arg_0_[2]
          return {info = nil, kind = type(v), menu = nil, word = k}
        end
        local function _5_(_4_0)
          local _arg_0_ = _4_0
          local k = _arg_0_[1]
          local v = _arg_0_[2]
          return not text["starts-with"](k, "aniseed/")
        end
        local function _6_()
          if x["aniseed/autoload-enabled?"] then
            do local _ = x["trick-aniseed-into-loading-the-module"] end
            return x["aniseed/autoload-module"]
          else
            return x
          end
        end
        return a.map(_3_, a.filter(_5_, a["kv-pairs"](_6_())))
      end
    end
    v_0_0 = value__3ecompletions0
    _0_0["value->completions"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["value->completions"] = v_0_
  value__3ecompletions = v_0_
end
local completions
do
  local v_0_
  do
    local v_0_0
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
        local function _3_()
          return require(opts.context)
        end
        ok_3f, m = (opts.context and pcall(_3_))
        if ok_3f then
          locals = a.concat(value__3ecompletions(a.get(m, "aniseed/locals")), value__3ecompletions(a["get-in"](m, {"aniseed/local-fns", "require"})), value__3ecompletions(a["get-in"](m, {"aniseed/local-fns", "autoload"})), mods)
        else
          locals = mods
        end
      end
      local result_fn
      local function _3_(results)
        local xs = a.first(results)
        local function _4_()
          if ("table" == type(xs)) then
            local function _4_(x)
              local function _5_(_241)
                return (opts.prefix .. _241)
              end
              return a.update(x, "word", _5_)
            end
            return a.concat(a.map(_4_, xs), locals)
          else
            return locals
          end
        end
        return opts.cb(_4_())
      end
      result_fn = _3_
      local _, ok_3f = nil, nil
      if code then
        local function _4_()
          return eval_str({["on-result-raw"] = result_fn, ["passive?"] = true, code = code, context = opts.context})
        end
        _, ok_3f = pcall(_4_)
      else
      _, ok_3f = nil
      end
      if not ok_3f then
        return opts.cb(locals)
      end
    end
    v_0_0 = completions0
    _0_0["completions"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["completions"] = v_0_
  completions = v_0_
end
return nil