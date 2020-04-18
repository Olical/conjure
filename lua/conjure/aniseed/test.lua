local _0_0 = nil
do
  local name_23_0_ = "conjure.aniseed.test"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local nvim = _2_[2]
local str = _2_[3]
do local _ = ({nil, _0_0, nil})[2] end
local ok_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function ok_3f0(_3_0)
      local _4_ = _3_0
      local tests_passed = _4_["tests-passed"]
      local tests = _4_["tests"]
      return (tests == tests_passed)
    end
    v_23_0_0 = ok_3f0
    _0_0["ok?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["ok?"] = v_23_0_
  ok_3f = v_23_0_
end
local display_results = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_results0(results, prefix)
      do
        local _3_ = results
        local assertions_passed = _3_["assertions-passed"]
        local assertions = _3_["assertions"]
        local tests_passed = _3_["tests-passed"]
        local tests = _3_["tests"]
        local function _4_()
          if ok_3f(results) then
            return "OK"
          else
            return "FAILED"
          end
        end
        a.println((prefix .. " " .. _4_() .. " " .. tests_passed .. "/" .. tests .. " tests and " .. assertions_passed .. "/" .. assertions .. " assertions passed"))
      end
      return results
    end
    v_23_0_0 = display_results0
    _0_0["display-results"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-results"] = v_23_0_
  display_results = v_23_0_
end
local run = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
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
            local fail = nil
            local function _3_(desc, ...)
              test_failed = true
              local function _4_(...)
                if desc then
                  return (" (" .. desc .. ")")
                else
                  return ""
                end
              end
              return a.println((str.join({prefix, " ", ...}) .. _4_(...)))
            end
            fail = _3_
            local begin = nil
            local function _4_()
              return a.update(results, "assertions", a.inc)
            end
            begin = _4_
            local pass = nil
            local function _5_()
              return a.update(results, "assertions-passed", a.inc)
            end
            pass = _5_
            local t = nil
            local function _6_(e, r, desc)
              begin()
              if (e == r) then
                return pass()
              else
                return fail(desc, "Expected '", a["pr-str"](e), "' but received '", a["pr-str"](r), "'")
              end
            end
            local function _7_(r, desc)
              begin()
              if r then
                return pass()
              else
                return fail(desc, "Expected truthy result but received '", a["pr-str"](r), "'")
              end
            end
            local function _8_(e, r, desc)
              begin()
              do
                local se = a["pr-str"](e)
                local sr = a["pr-str"](r)
                if (se == sr) then
                  return pass()
                else
                  return fail(desc, "Expected (with pr) '", se, "' but received '", sr, "'")
                end
              end
            end
            t = {["="] = _6_, ["ok?"] = _7_, ["pr="] = _8_}
            do
              local _9_0, _10_0 = nil, nil
              local function _11_()
                return f(t)
              end
              _9_0, _10_0 = pcall(_11_)
              if ((_9_0 == false) and (nil ~= _10_0)) then
                local err = _10_0
                fail("Exception: ", err)
              end
            end
          end
          if not test_failed then
            a.update(results, "tests-passed", a.inc)
          end
        end
        return display_results(results, ("[" .. mod_name .. "]"))
      end
    end
    v_23_0_0 = run0
    _0_0["run"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run"] = v_23_0_
  run = v_23_0_
end
local run_all = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_all0()
      local function _3_(totals, results)
        for k, v in pairs(results) do
          totals[k] = (v + totals[k])
        end
        return totals
      end
      return display_results(a.reduce(_3_, {["assertions-passed"] = 0, ["tests-passed"] = 0, assertions = 0, tests = 0}, a.filter(a["table?"], a.map(run, a.keys(package.loaded)))), "[total]")
    end
    v_23_0_0 = run_all0
    _0_0["run-all"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-all"] = v_23_0_
  run_all = v_23_0_
end
local suite = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function suite0()
      nvim.ex.redir_("> test/results.txt")
      local function _3_(path)
        return require(string.gsub(string.match(path, "^test/fnl/(.-).fnl$"), "/", "."))
      end
      a["run!"](_3_, nvim.fn.globpath("test/fnl", "**/*-test.fnl", false, true))
      do
        local results = run_all()
        if ok_3f(results) then
          return nvim.ex.q()
        else
          return nvim.ex.cq()
        end
      end
    end
    v_23_0_0 = suite0
    _0_0["suite"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["suite"] = v_23_0_
  suite = v_23_0_
end
return nil
