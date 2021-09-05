local _2afile_2a = "fnl/aniseed/test.fnl"
local _2amodule_name_2a = "conjure.aniseed.test"
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
local a, fs, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function ok_3f(_1_)
  local _arg_2_ = _1_
  local tests = _arg_2_["tests"]
  local tests_passed = _arg_2_["tests-passed"]
  return (tests == tests_passed)
end
_2amodule_2a["ok?"] = ok_3f
local function display_results(results, prefix)
  do
    local _let_3_ = results
    local assertions = _let_3_["assertions"]
    local assertions_passed = _let_3_["assertions-passed"]
    local tests = _let_3_["tests"]
    local tests_passed = _let_3_["tests-passed"]
    local _4_
    if ok_3f(results) then
      _4_ = "OK"
    else
      _4_ = "FAILED"
    end
    a.println((prefix .. " " .. _4_ .. " " .. tests_passed .. "/" .. tests .. " tests and " .. assertions_passed .. "/" .. assertions .. " assertions passed"))
  end
  return results
end
_2amodule_2a["display-results"] = display_results
local function run(mod_name)
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
        local function _6_(desc, ...)
          test_failed = true
          local _7_
          if desc then
            _7_ = (" (" .. desc .. ")")
          else
            _7_ = ""
          end
          return a.println((str.join({prefix, " ", ...}) .. _7_))
        end
        fail = _6_
        local begin
        local function _9_()
          return a.update(results, "assertions", a.inc)
        end
        begin = _9_
        local pass
        local function _10_()
          return a.update(results, "assertions-passed", a.inc)
        end
        pass = _10_
        local t
        local function _11_(e, r, desc)
          begin()
          if (e == r) then
            return pass()
          else
            return fail(desc, "Expected '", a["pr-str"](e), "' but received '", a["pr-str"](r), "'")
          end
        end
        local function _13_(r, desc)
          begin()
          if r then
            return pass()
          else
            return fail(desc, "Expected truthy result but received '", a["pr-str"](r), "'")
          end
        end
        local function _15_(e, r, desc)
          begin()
          local se = a["pr-str"](e)
          local sr = a["pr-str"](r)
          if (se == sr) then
            return pass()
          else
            return fail(desc, "Expected (with pr) '", se, "' but received '", sr, "'")
          end
        end
        t = {["="] = _11_, ["ok?"] = _13_, ["pr="] = _15_}
        local _17_, _18_ = nil, nil
        local function _19_()
          return f(t)
        end
        _17_, _18_ = pcall(_19_)
        if ((_17_ == false) and (nil ~= _18_)) then
          local err = _18_
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
_2amodule_2a["run"] = run
local function run_all()
  local function _23_(totals, results)
    for k, v in pairs(results) do
      totals[k] = (v + totals[k])
    end
    return totals
  end
  return display_results(a.reduce(_23_, {["assertions-passed"] = 0, ["tests-passed"] = 0, assertions = 0, tests = 0}, a.filter(a["table?"], a.map(run, a.keys(_G.package.loaded)))), "[total]")
end
_2amodule_2a["run-all"] = run_all
local function suite()
  do
    local sep = fs["path-sep"]
    local function _24_(path)
      return require(string.gsub(string.match(path, ("^test" .. sep .. "fnl" .. sep .. "(.-).fnl$")), sep, "."))
    end
    a["run!"](_24_, nvim.fn.globpath(("test" .. sep .. "fnl"), "**/*-test.fnl", false, true))
  end
  if ok_3f(run_all()) then
    return nvim.ex.q()
  else
    return nvim.ex.cq()
  end
end
_2amodule_2a["suite"] = suite
