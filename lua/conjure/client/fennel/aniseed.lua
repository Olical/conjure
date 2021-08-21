local _2afile_2a = "fnl/conjure/client/fennel/aniseed.fnl"
local _1_
do
  local name_4_auto = "conjure.client.fennel.aniseed"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.aniseed.view")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", extract = "conjure.extract", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", view = "conjure.aniseed.view"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local view = _local_4_[10]
local client = _local_4_[2]
local config = _local_4_[3]
local extract = _local_4_[4]
local log = _local_4_[5]
local mapping = _local_4_[6]
local nvim = _local_4_[7]
local str = _local_4_[8]
local text = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.fennel.aniseed"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_23_auto
  do
    local v_25_auto = ".fnl"
    _1_["buf-suffix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-suffix"] = v_23_auto
  buf_suffix = v_23_auto
end
local context_pattern
do
  local v_23_auto
  do
    local v_25_auto = "%(%s*module%s+(.-)[%s){]"
    _1_["context-pattern"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["context-pattern"] = v_23_auto
  context_pattern = v_23_auto
end
local comment_prefix
do
  local v_23_auto
  do
    local v_25_auto = "; "
    _1_["comment-prefix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-prefix"] = v_23_auto
  comment_prefix = v_23_auto
end
config.merge({client = {fennel = {aniseed = {aniseed_module_prefix = "conjure.aniseed.", mapping = {run_all_tests = "ta", run_buf_tests = "tt"}, use_metadata = true}}}})
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "fennel", "aniseed"})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
local ani_aliases
do
  local v_23_auto = {nu = "nvim.util"}
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["ani-aliases"] = v_23_auto
  ani_aliases = v_23_auto
end
local ani
do
  local v_23_auto
  local function ani0(mod_name, f_name)
    local mod_name0 = a.get(ani_aliases, mod_name, mod_name)
    local mod = require((cfg({"aniseed_module_prefix"}) .. mod_name0))
    if f_name then
      return a.get(mod, f_name)
    else
      return mod
    end
  end
  v_23_auto = ani0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["ani"] = v_23_auto
  ani = v_23_auto
end
local anic
do
  local v_23_auto
  local function anic0(mod, f_name, ...)
    return ani(mod, f_name)(...)
  end
  v_23_auto = anic0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["anic"] = v_23_auto
  anic = v_23_auto
end
local repls
do
  local v_23_auto = ((_1_)["aniseed/locals"].repls or {})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["repls"] = v_23_auto
  repls = v_23_auto
end
local repl
do
  local v_23_auto
  local function repl0(opts)
    local filename = a.get(opts, "filename")
    local function _9_()
      local repl1 = anic("eval", "repl", opts)
      repl1(("(module " .. opts.moduleName .. ")\n"))
      do end (repls)[filename] = repl1
      return repl1
    end
    return (a.get(repls, filename) or _9_())
  end
  v_23_auto = repl0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["repl"] = v_23_auto
  repl = v_23_auto
end
local display_result
do
  local v_23_auto
  do
    local v_25_auto
    local function display_result0(opts)
      if opts then
        local _let_10_ = opts
        local ok_3f = _let_10_["ok?"]
        local results = _let_10_["results"]
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
          local function _14_()
            if ok_3f then
              return result_lines
            else
              local function _13_(_241)
                return ("; " .. _241)
              end
              return a.map(_13_, result_lines)
            end
          end
          log.append(_14_())
        end
        if opts["on-result-raw"] then
          opts["on-result-raw"](results)
        end
        if opts["on-result"] then
          return opts["on-result"](result_str)
        end
      end
    end
    v_25_auto = display_result0
    _1_["display-result"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-result"] = v_23_auto
  display_result = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      local function _19_()
        local out
        local function _20_()
          if (cfg({"use_metadata"}) and not package.loaded.fennel) then
            package.loaded.fennel = anic("fennel", "impl")
          end
          local eval
          local function _22_(err_type, err, lua_source)
            opts["ok?"] = false
            opts.results = {err}
            return nil
          end
          eval = repl({filename = opts["file-path"], moduleName = (opts.context or "conjure.aniseed.user"), onError = _22_, useMetadata = cfg({"use_metadata"})})
          local results = eval((opts.code .. "\n"))
          if (nil == opts["ok?"]) then
            opts["ok?"] = true
            opts.results = results
            return nil
          end
        end
        out = anic("nu", "with-out-str", _20_)
        if not a["empty?"](out) then
          log.append(text["prefixed-lines"](text["trim-last-newline"](out), "; (out) "))
        end
        return display_result(opts)
      end
      return client.wrap(_19_)()
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local doc_str
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_str0(opts)
      a.assoc(opts, "code", ("(doc " .. opts.code .. ")"))
      return eval_str(opts)
    end
    v_25_auto = doc_str0
    _1_["doc-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local eval_file
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_file0(opts)
      opts.code = a.slurp(opts["file-path"])
      if opts.code then
        return eval_str(opts)
      end
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local wrapped_test
do
  local v_23_auto
  local function wrapped_test0(req_lines, f)
    log.append(req_lines, {["break?"] = true})
    local res = anic("nu", "with-out-str", f)
    local _26_
    if ("" == res) then
      _26_ = "No results."
    else
      _26_ = res
    end
    return log.append(text["prefixed-lines"](_26_, "; "))
  end
  v_23_auto = wrapped_test0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["wrapped-test"] = v_23_auto
  wrapped_test = v_23_auto
end
local run_buf_tests
do
  local v_23_auto
  do
    local v_25_auto
    local function run_buf_tests0()
      local c = extract.context()
      if c then
        local function _28_()
          return anic("test", "run", c)
        end
        return wrapped_test({("; run-buf-tests (" .. c .. ")")}, _28_)
      end
    end
    v_25_auto = run_buf_tests0
    _1_["run-buf-tests"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-buf-tests"] = v_23_auto
  run_buf_tests = v_23_auto
end
local run_all_tests
do
  local v_23_auto
  do
    local v_25_auto
    local function run_all_tests0()
      return wrapped_test({"; run-all-tests"}, ani("test", "run-all"))
    end
    v_25_auto = run_all_tests0
    _1_["run-all-tests"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-all-tests"] = v_23_auto
  run_all_tests = v_23_auto
end
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
    local function on_filetype0()
      mapping.buf("n", "FnlRunBufTests", cfg({"mapping", "run_buf_tests"}), _2amodule_name_2a, "run-buf-tests")
      return mapping.buf("n", "FnlRunAllTests", cfg({"mapping", "run_all_tests"}), _2amodule_name_2a, "run-all-tests")
    end
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
end
local value__3ecompletions
do
  local v_23_auto
  do
    local v_25_auto
    local function value__3ecompletions0(x)
      if ("table" == type(x)) then
        local function _32_(_30_)
          local _arg_31_ = _30_
          local k = _arg_31_[1]
          local v = _arg_31_[2]
          return {info = nil, kind = type(v), menu = nil, word = k}
        end
        local function _35_(_33_)
          local _arg_34_ = _33_
          local k = _arg_34_[1]
          local v = _arg_34_[2]
          return not text["starts-with"](k, "aniseed/")
        end
        local function _36_()
          if x["aniseed/autoload-enabled?"] then
            do local _ = x["trick-aniseed-into-loading-the-module"] end
            return x["aniseed/autoload-module"]
          else
            return x
          end
        end
        return a.map(_32_, a.filter(_35_, a["kv-pairs"](_36_())))
      end
    end
    v_25_auto = value__3ecompletions0
    _1_["value->completions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["value->completions"] = v_23_auto
  value__3ecompletions = v_23_auto
end
local completions
do
  local v_23_auto
  do
    local v_25_auto
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
        local function _39_()
          return require(opts.context)
        end
        ok_3f, m = (opts.context and pcall(_39_))
        if ok_3f then
          locals = a.concat(value__3ecompletions(a.get(m, "aniseed/locals")), value__3ecompletions(a["get-in"](m, {"aniseed/local-fns", "require"})), value__3ecompletions(a["get-in"](m, {"aniseed/local-fns", "autoload"})), mods)
        else
          locals = mods
        end
      end
      local result_fn
      local function _41_(results)
        local xs = a.first(results)
        local function _44_()
          if ("table" == type(xs)) then
            local function _42_(x)
              local function _43_(_241)
                return (opts.prefix .. _241)
              end
              return a.update(x, "word", _43_)
            end
            return a.concat(a.map(_42_, xs), locals)
          else
            return locals
          end
        end
        return opts.cb(_44_())
      end
      result_fn = _41_
      local _, ok_3f = nil, nil
      if code then
        local function _45_()
          return eval_str({["on-result-raw"] = result_fn, ["passive?"] = true, code = code, context = opts.context})
        end
        _, ok_3f = pcall(_45_)
      else
      _, ok_3f = nil
      end
      if not ok_3f then
        return opts.cb(locals)
      end
    end
    v_25_auto = completions0
    _1_["completions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["completions"] = v_23_auto
  completions = v_23_auto
end
return nil