local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.aniseed.test"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local nvim = _local_0_[2]
local str = _local_0_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.test"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local ok_3f
do
  local v_0_
  local function ok_3f0(_1_0)
    local _arg_0_ = _1_0
    local tests = _arg_0_["tests"]
    local tests_passed = _arg_0_["tests-passed"]
    return (tests == tests_passed)
  end
  v_0_ = ok_3f0
  _0_0["ok?"] = v_0_
  ok_3f = v_0_
end
local display_results
do
  local v_0_
  local function display_results0(results, prefix)
    do
      local _let_0_ = results
      local assertions = _let_0_["assertions"]
      local assertions_passed = _let_0_["assertions-passed"]
      local tests = _let_0_["tests"]
      local tests_passed = _let_0_["tests-passed"]
      local _1_
      if ok_3f(results) then
        _1_ = "OK"
      else
        _1_ = "FAILED"
      end
      a.println((prefix .. " " .. _1_ .. " " .. tests_passed .. "/" .. tests .. " tests and " .. assertions_passed .. "/" .. assertions .. " assertions passed"))
    end
    return results
  end
  v_0_ = display_results0
  _0_0["display-results"] = v_0_
  display_results = v_0_
end
local run
do
  local v_0_
  local function run0(mod_name)
    local mod = package.loaded[mod_name]
    local tests = (a["table?"](mod) and mod["aniseed/tests"])
    if a["table?"](tests) then
      local results = {["assertions-passed"] = 0, ["tests-passed"] = 0, assertions = 0, tests = #tests}
      for label, f in pairs(tests) do
        local test_failed = false
        a.update(results, "tests", a.inc)
        do
          local prefix = ("[" .. mod_name .. "/" .. label .. "]")
          local fail
          local function _1_(desc, ...)
            test_failed = true
            local function _2_(...)
              if desc then
                return (" (" .. desc .. ")")
              else
                return ""
              end
            end
            return a.println((str.join({prefix, " ", ...}) .. _2_(...)))
          end
          fail = _1_
          local begin
          local function _2_()
            return a.update(results, "assertions", a.inc)
          end
          begin = _2_
          local pass
          local function _3_()
            return a.update(results, "assertions-passed", a.inc)
          end
          pass = _3_
          local t
          local function _4_(e, r, desc)
            begin()
            if (e == r) then
              return pass()
            else
              return fail(desc, "Expected '", a["pr-str"](e), "' but received '", a["pr-str"](r), "'")
            end
          end
          local function _5_(r, desc)
            begin()
            if r then
              return pass()
            else
              return fail(desc, "Expected truthy result but received '", a["pr-str"](r), "'")
            end
          end
          local function _6_(e, r, desc)
            begin()
            local se = a["pr-str"](e)
            local sr = a["pr-str"](r)
            if (se == sr) then
              return pass()
            else
              return fail(desc, "Expected (with pr) '", se, "' but received '", sr, "'")
            end
          end
          t = {["="] = _4_, ["ok?"] = _5_, ["pr="] = _6_}
          local _7_0, _8_0 = nil, nil
          local function _9_()
            return f(t)
          end
          _7_0, _8_0 = pcall(_9_)
          if ((_7_0 == false) and (nil ~= _8_0)) then
            local err = _8_0
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
  v_0_ = run0
  _0_0["run"] = v_0_
  run = v_0_
end
local run_all
do
  local v_0_
  local function run_all0()
    local function _1_(totals, results)
      for k, v in pairs(results) do
        totals[k] = (v + totals[k])
      end
      return totals
    end
    return display_results(a.reduce(_1_, {["assertions-passed"] = 0, ["tests-passed"] = 0, assertions = 0, tests = 0}, a.filter(a["table?"], a.map(run, a.keys(package.loaded)))), "[total]")
  end
  v_0_ = run_all0
  _0_0["run-all"] = v_0_
  run_all = v_0_
end
local suite
do
  local v_0_
  local function suite0()
    local function _1_(path)
      return require(string.gsub(string.match(path, "^test/fnl/(.-).fnl$"), "/", "."))
    end
    a["run!"](_1_, nvim.fn.globpath("test/fnl", "**/*-test.fnl", false, true))
    if ok_3f(run_all()) then
      return nvim.ex.q()
    else
      return nvim.ex.cq()
    end
  end
  v_0_ = suite0
  _0_0["suite"] = v_0_
  suite = v_0_
end
return nil
