local _0_0 = nil
do
  local name_23_0_ = "conjure.client.fennel.aniseed"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", extract = "conjure.extract", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", view = "conjure.aniseed.view"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.extract"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.aniseed.view")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local extract = _2_[3]
local log = _2_[4]
local mapping = _2_[5]
local nvim = _2_[6]
local str = _2_[7]
local text = _2_[8]
local view = _2_[9]
do local _ = ({nil, _0_0, nil})[2] end
local buf_suffix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = ".fnl"
    _0_0["buf-suffix"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf-suffix"] = v_23_0_
  buf_suffix = v_23_0_
end
local context_pattern = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = "%(%s*module%s*(.-)[%s){]"
    _0_0["context-pattern"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["context-pattern"] = v_23_0_
  context_pattern = v_23_0_
end
local comment_prefix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = "; "
    _0_0["comment-prefix"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["comment-prefix"] = v_23_0_
  comment_prefix = v_23_0_
end
local config = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["aniseed-module-prefix"] = "conjure.aniseed.", ["use-metadata?"] = true, mappings = {["run-all-tests"] = "ta", ["run-buf-tests"] = "tt"}}
    _0_0["config"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["config"] = v_23_0_
  config = v_23_0_
end
local ani_aliases = nil
do
  local v_23_0_ = {nu = "nvim.util"}
  _0_0["aniseed/locals"]["ani-aliases"] = v_23_0_
  ani_aliases = v_23_0_
end
local ani = nil
do
  local v_23_0_ = nil
  local function ani0(mod_name, f_name)
    local mod_name0 = a.get(ani_aliases, mod_name, mod_name)
    local mod = require((config["aniseed-module-prefix"] .. mod_name0))
    if f_name then
      return a.get(mod, f_name)
    else
      return mod
    end
  end
  v_23_0_ = ani0
  _0_0["aniseed/locals"]["ani"] = v_23_0_
  ani = v_23_0_
end
local anic = nil
do
  local v_23_0_ = nil
  local function anic0(mod, f_name, ...)
    return ani(mod, f_name)(...)
  end
  v_23_0_ = anic0
  _0_0["aniseed/locals"]["anic"] = v_23_0_
  anic = v_23_0_
end
local display = nil
do
  local v_23_0_ = nil
  local function display0(lines, opts)
    return client["with-filetype"]("fennel", log.append, lines, opts)
  end
  v_23_0_ = display0
  _0_0["aniseed/locals"]["display"] = v_23_0_
  display = v_23_0_
end
local display_result = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_result0(opts)
      if opts then
        local _3_ = opts
        local results = _3_["results"]
        local ok_3f = _3_["ok?"]
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
        return display(_5_())
      end
    end
    v_23_0_0 = display_result0
    _0_0["display-result"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-result"] = v_23_0_
  display_result = v_23_0_
end
local eval_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_str0(opts)
      local code = (("(module " .. (opts.context or "aniseed.user") .. ") ") .. opts.code .. "\n")
      local out = nil
      local function _3_()
        if config["use-metadata?"] then
          package.loaded.fennel = ani("fennel")
        end
        do
          local _5_ = {anic("eval", "str", code, {filename = opts["file-path"], useMetadata = config["use-metadata?"]})}
          local ok_3f = _5_[1]
          local results = {(table.unpack or unpack)(_5_, 2)}
          opts["ok?"] = ok_3f
          opts.results = results
          return nil
        end
      end
      out = anic("nu", "with-out-str", _3_)
      if not a["empty?"](out) then
        display(text["prefixed-lines"](out, "; (out) "))
      end
      return display_result(opts)
    end
    v_23_0_0 = eval_str0
    _0_0["eval-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_23_0_
  eval_str = v_23_0_
end
local doc_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function doc_str0(opts)
      a.assoc(opts, "code", ("(doc " .. opts.code .. ")"))
      return eval_str(opts)
    end
    v_23_0_0 = doc_str0
    _0_0["doc-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_23_0_
  doc_str = v_23_0_
end
local eval_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_file0(opts)
      opts.code = a.slurp(opts["file-path"])
      if opts.code then
        return eval_str(opts)
      end
    end
    v_23_0_0 = eval_file0
    _0_0["eval-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_23_0_
  eval_file = v_23_0_
end
local wrapped_test = nil
do
  local v_23_0_ = nil
  local function wrapped_test0(req_lines, f)
    display(req_lines, {["break?"] = true})
    do
      local res = anic("nu", "with-out-str", f)
      local _3_
      if ("" == res) then
        _3_ = "No results."
      else
        _3_ = res
      end
      return display(text["prefixed-lines"](_3_, "; "))
    end
  end
  v_23_0_ = wrapped_test0
  _0_0["aniseed/locals"]["wrapped-test"] = v_23_0_
  wrapped_test = v_23_0_
end
local run_buf_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_buf_tests0()
      local c = extract.context()
      if c then
        local function _3_()
          return anic("test", "run", c)
        end
        return wrapped_test({("; run-buf-tests (" .. c .. ")")}, _3_)
      end
    end
    v_23_0_0 = run_buf_tests0
    _0_0["run-buf-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-buf-tests"] = v_23_0_
  run_buf_tests = v_23_0_
end
local run_all_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_all_tests0()
      return wrapped_test({"; run-all-tests"}, ani("test", "run-all"))
    end
    v_23_0_0 = run_all_tests0
    _0_0["run-all-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-all-tests"] = v_23_0_
  run_all_tests = v_23_0_
end
local on_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", config.mappings["run-buf-tests"], "conjure.client.fennel.aniseed", "run-buf-tests")
      return mapping.buf("n", config.mappings["run-all-tests"], "conjure.client.fennel.aniseed", "run-all-tests")
    end
    v_23_0_0 = on_filetype0
    _0_0["on-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_23_0_
  on_filetype = v_23_0_
end
return nil