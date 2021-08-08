local _2afile_2a = "fnl/aniseed/test.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.test"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", fs = "conjure.aniseed.fs", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local fs = _local_4_[2]
local nvim = _local_4_[3]
local str = _local_4_[4]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.test"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local ok_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function ok_3f0(_8_)
      local _arg_9_ = _8_
      local tests = _arg_9_["tests"]
      local tests_passed = _arg_9_["tests-passed"]
      return (tests == tests_passed)
    end
    v_25_auto = ok_3f0
    _1_["ok?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["ok?"] = v_23_auto
  ok_3f = v_23_auto
end
local display_results
do
  local v_23_auto
  do
    local v_25_auto
    local function display_results0(results, prefix)
      do
        local _let_10_ = results
        local assertions = _let_10_["assertions"]
        local assertions_passed = _let_10_["assertions-passed"]
        local tests = _let_10_["tests"]
        local tests_passed = _let_10_["tests-passed"]
        local _11_
        if ok_3f(results) then
          _11_ = "OK"
        else
          _11_ = "FAILED"
        end
        a.println((prefix .. " " .. _11_ .. " " .. tests_passed .. "/" .. tests .. " tests and " .. assertions_passed .. "/" .. assertions .. " assertions passed"))
      end
      return results
    end
    v_25_auto = display_results0
    _1_["display-results"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-results"] = v_23_auto
  display_results = v_23_auto
end
local run
do
  local v_23_auto
  do
    local v_25_auto
    local function run0(mod_name)
      local mod = _G.package.loaded[mod_name]
      local tests = (a["table?"](mod) and mod["aniseed/tests"])
      if a["table?"](tests) then
        local results = {["assertions-passed"] = 0, ["tests-passed"] = 0, assertions = 0, tests = #tests}
        for label, f in pairs(tests) do
          local test_failed = false
          a.update(results, "tests", a.inc)
          do
            local prefix = ("[" .. mod_name .. "/" .. label .. "]")
            local fail
            local function _13_(desc, ...)
              test_failed = true
              local _14_
              if desc then
                _14_ = (" (" .. desc .. ")")
              else
                _14_ = ""
              end
              return a.println((str.join({prefix, " ", ...}) .. _14_))
            end
            fail = _13_
            local begin
            local function _16_()
              return a.update(results, "assertions", a.inc)
            end
            begin = _16_
            local pass
            local function _17_()
              return a.update(results, "assertions-passed", a.inc)
            end
            pass = _17_
            local t
            local function _18_(e, r, desc)
              begin()
              if (e == r) then
                return pass()
              else
                return fail(desc, "Expected '", a["pr-str"](e), "' but received '", a["pr-str"](r), "'")
              end
            end
            local function _20_(r, desc)
              begin()
              if r then
                return pass()
              else
                return fail(desc, "Expected truthy result but received '", a["pr-str"](r), "'")
              end
            end
            local function _22_(e, r, desc)
              begin()
              local se = a["pr-str"](e)
              local sr = a["pr-str"](r)
              if (se == sr) then
                return pass()
              else
                return fail(desc, "Expected (with pr) '", se, "' but received '", sr, "'")
              end
            end
            t = {["="] = _18_, ["ok?"] = _20_, ["pr="] = _22_}
            local _24_, _25_ = nil, nil
            local function _26_()
              return f(t)
            end
            _24_, _25_ = pcall(_26_)
            if ((_24_ == false) and (nil ~= _25_)) then
              local err = _25_
              fail("Exception: ", err)
            end
          end
          if not test_failed then
            a.update(results, "tests-passed", a.inc)
          end
        end
        return display_results(results, ("[" .. mod_name .. "]"))
      end
    end
    v_25_auto = run0
    _1_["run"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run"] = v_23_auto
  run = v_23_auto
end
local run_all
do
  local v_23_auto
  do
    local v_25_auto
    local function run_all0()
      local function _30_(totals, results)
        for k, v in pairs(results) do
          totals[k] = (v + totals[k])
        end
        return totals
      end
      return display_results(a.reduce(_30_, {["assertions-passed"] = 0, ["tests-passed"] = 0, assertions = 0, tests = 0}, a.filter(a["table?"], a.map(run, a.keys(_G.package.loaded)))), "[total]")
    end
    v_25_auto = run_all0
    _1_["run-all"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-all"] = v_23_auto
  run_all = v_23_auto
end
local suite
do
  local v_23_auto
  do
    local v_25_auto
    local function suite0()
      do
        local sep = fs["path-sep"]
        local function _31_(path)
          return require(string.gsub(string.match(path, ("^test" .. sep .. "fnl" .. sep .. "(.-).fnl$")), sep, "."))
        end
        a["run!"](_31_, nvim.fn.globpath(("test" .. sep .. "fnl"), "**/*-test.fnl", false, true))
      end
      if ok_3f(run_all()) then
        return nvim.ex.q()
      else
        return nvim.ex.cq()
      end
    end
    v_25_auto = suite0
    _1_["suite"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["suite"] = v_23_auto
  suite = v_23_auto
end
return nil
