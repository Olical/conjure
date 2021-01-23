local _0_0 = nil
do
  local name_0_ = "conjure.client.fennel.aniseed"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.extract"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.aniseed.view")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", extract = "conjure.extract", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", view = "conjure.aniseed.view"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local view = _1_[10]
local client = _1_[2]
local config = _1_[3]
local extract = _1_[4]
local log = _1_[5]
local mapping = _1_[6]
local nvim = _1_[7]
local str = _1_[8]
local text = _1_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.fennel.aniseed"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local buf_suffix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = ".fnl"
    _0_0["buf-suffix"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local context_pattern = nil
do
  local v_0_ = nil
  do
    local v_0_0 = "%(%s*module%s+(.-)[%s){]"
    _0_0["context-pattern"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["context-pattern"] = v_0_
  context_pattern = v_0_
end
local comment_prefix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = "; "
    _0_0["comment-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
config.merge({client = {fennel = {aniseed = {aniseed_module_prefix = "conjure.aniseed.", mapping = {run_all_tests = "ta", run_buf_tests = "tt"}, use_metadata = true}}}})
local cfg = nil
do
  local v_0_ = config["get-in-fn"]({"client", "fennel", "aniseed"})
  _0_0["aniseed/locals"]["cfg"] = v_0_
  cfg = v_0_
end
local ani_aliases = nil
do
  local v_0_ = {nu = "nvim.util"}
  _0_0["aniseed/locals"]["ani-aliases"] = v_0_
  ani_aliases = v_0_
end
local ani = nil
do
  local v_0_ = nil
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
  _0_0["aniseed/locals"]["ani"] = v_0_
  ani = v_0_
end
local anic = nil
do
  local v_0_ = nil
  local function anic0(mod, f_name, ...)
    return ani(mod, f_name)(...)
  end
  v_0_ = anic0
  _0_0["aniseed/locals"]["anic"] = v_0_
  anic = v_0_
end
local display_result = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display_result0(opts)
      if opts then
        local _3_ = opts
        local ok_3f = _3_["ok?"]
        local results = _3_["results"]
        local result_str = nil
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
          local function _5_()
            if ok_3f then
              return result_lines
            else
              local function _5_(_241)
                return ("; " .. _241)
              end
              return a.map(_5_, result_lines)
            end
          end
          log.append(_5_())
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
  _0_0["aniseed/locals"]["display-result"] = v_0_
  display_result = v_0_
end
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
      local function _3_()
        local code = (("(module " .. (opts.context or "aniseed.user") .. ") ") .. opts.code .. "\n")
        local out = nil
        local function _4_()
          if cfg({"use_metadata"}) then
            package.loaded.fennel = ani("fennel")
          end
          local _6_ = {anic("eval", "str", code, {filename = opts["file-path"], useMetadata = cfg({"use_metadata"})})}
          local ok_3f = _6_[1]
          local results = {(table.unpack or unpack)(_6_, 2)}
          opts["ok?"] = ok_3f
          opts.results = results
          return nil
        end
        out = anic("nu", "with-out-str", _4_)
        if not a["empty?"](out) then
          log.append(text["prefixed-lines"](text["trim-last-newline"](out), "; (out) "))
        end
        return display_result(opts)
      end
      return client.wrap(_3_)()
    end
    v_0_0 = eval_str0
    _0_0["eval-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_str0(opts)
      a.assoc(opts, "code", ("(doc " .. opts.code .. ")"))
      return eval_str(opts)
    end
    v_0_0 = doc_str0
    _0_0["doc-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_0_
  doc_str = v_0_
end
local eval_file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  _0_0["aniseed/locals"]["eval-file"] = v_0_
  eval_file = v_0_
end
local wrapped_test = nil
do
  local v_0_ = nil
  local function wrapped_test0(req_lines, f)
    log.append(req_lines, {["break?"] = true})
    local res = anic("nu", "with-out-str", f)
    local _3_
    if ("" == res) then
      _3_ = "No results."
    else
      _3_ = res
    end
    return log.append(text["prefixed-lines"](_3_, "; "))
  end
  v_0_ = wrapped_test0
  _0_0["aniseed/locals"]["wrapped-test"] = v_0_
  wrapped_test = v_0_
end
local run_buf_tests = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function run_buf_tests0()
      local c = extract.context()
      if c then
        local function _3_()
          return anic("test", "run", c)
        end
        return wrapped_test({("; run-buf-tests (" .. c .. ")")}, _3_)
      end
    end
    v_0_0 = run_buf_tests0
    _0_0["run-buf-tests"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["run-buf-tests"] = v_0_
  run_buf_tests = v_0_
end
local run_all_tests = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function run_all_tests0()
      return wrapped_test({"; run-all-tests"}, ani("test", "run-all"))
    end
    v_0_0 = run_all_tests0
    _0_0["run-all-tests"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["run-all-tests"] = v_0_
  run_all_tests = v_0_
end
local on_filetype = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", "FnlRunBufTests", cfg({"mapping", "run_buf_tests"}), _2amodule_name_2a, "run-buf-tests")
      return mapping.buf("n", "FnlRunAllTests", cfg({"mapping", "run_all_tests"}), _2amodule_name_2a, "run-all-tests")
    end
    v_0_0 = on_filetype0
    _0_0["on-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_0_
  on_filetype = v_0_
end
local completions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function completions0(opts)
      local code = nil
      if not str["blank?"](opts.prefix) then
        code = ("((. (require :conjure.aniseed.core) :keys) " .. (opts.prefix):gsub(".$", "") .. ")")
      else
      code = nil
      end
      local mods = a.keys(package.loaded)
      local locals = nil
      do
        local ok_3f, m = nil, nil
        local function _4_()
          return require(opts.context)
        end
        ok_3f, m = (opts.context and pcall(_4_))
        if ok_3f then
          local _6_
          do
            local _5_0 = a.get(m, "aniseed/locals")
            if _5_0 then
              _6_ = a.keys(_5_0)
            else
              _6_ = _5_0
            end
          end
          local _8_
          do
            local _7_0 = a["get-in"](m, {"aniseed/local-fns", "require"})
            if _7_0 then
              _8_ = a.keys(_7_0)
            else
              _8_ = _7_0
            end
          end
          locals = a.concat(_6_, _8_, mods)
        else
          locals = mods
        end
      end
      local _, ok_3f = nil, nil
      if code then
        local function _4_()
          local function _5_(results)
            local xs = a.first(results)
            if ("table" == type(xs)) then
              local function _6_(x)
                return (opts.prefix .. x)
              end
              return opts.cb(a.concat(a.map(_6_, xs), locals))
            end
          end
          return eval_str({["on-result-raw"] = _5_, ["passive?"] = true, code = code, context = opts.context})
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
  _0_0["aniseed/locals"]["completions"] = v_0_
  completions = v_0_
end
return nil