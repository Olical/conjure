-- [nfnl] Compiled from fnl/conjure-spec/client/fennel/aniseed_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local a = require("nfnl.core")
local ani = require("conjure.client.fennel.aniseed")
local function _2_()
  local ex_mod = "test.foo.bar"
  local ex_file = "/some-big/ol/path/test/foo/bar.fnl"
  local ex_file2 = "/some-big/ol/path/test/foo/bar/init.fnl"
  local ex_no_file = "/some-big/ol/path/test/foo/bar/no/init.fnl"
  local function contains_3f(s, substr)
    local function _3_()
      if string.find(s, substr) then
        return substr
      else
        return s
      end
    end
    return substr, _3_()
  end
  local function _4_()
    package.loaded[ex_mod] = {my = "module"}
    local function _5_()
      return assert.are.equals(ani["default-module-name"], ani["module-name"](nil, nil))
    end
    it("default name", _5_)
    local function _6_()
      return assert.are.equals(ex_mod, ani["module-name"](ex_mod, ex_file))
    end
    it("ex-mod and ex-file", _6_)
    local function _7_()
      return assert.are.equals(ex_mod, ani["module-name"](nil, ex_file))
    end
    it("ex-file and no ex-mod", _7_)
    local function _8_()
      return assert.are.equals(ex_mod, ani["module-name"](nil, ex_file2))
    end
    it("ex-file2 and no ex-mod", _8_)
    local function _9_()
      return assert.are.equals(ani["default-module-name"], ani["module-name"](nil, ex_no_file))
    end
    it("default module name when no ex-file", _9_)
    package.loaded[ex_mod] = nil
    return nil
  end
  describe("module-name", _4_)
  local function _10_()
    local function eval_21(code)
      local result = nil
      local raw = nil
      local function _11_(_241)
        result = _241
        return nil
      end
      local function _12_(_241)
        raw = _241
        return nil
      end
      ani["eval-str"]({code = code, context = "foo.bar", ["passive?"] = true, ["file-path"] = "foo/bar.fnl", ["on-result"] = _11_, ["on-result-raw"] = _12_})
      return {result = result, raw = raw}
    end
    local function _13_()
      return assert.same({raw = {30}, result = "30"}, eval_21("(+ 10 20)"))
    end
    it("evaluates a form", _13_)
    local function _14_()
      local _let_15_ = eval_21("(fn hi [] 10)")
      local raw = _let_15_["raw"]
      local result = _let_15_["result"]
      assert.are.equals("function", type(a.first(raw)))
      assert.are.equals("string", type(result))
      return assert.is_not_nil(contains_3f(result, "#<function: "))
    end
    it("eval a function definition", _14_)
    local function _16_()
      return assert.same({raw = {10}, result = "10"}, eval_21("(hi)"))
    end
    it("evaluates a function", _16_)
    local function _17_()
      local _let_18_ = eval_21("(ohno)")
      local result = _let_18_["result"]
      local raw = _let_18_["raw"]
      return assert.are.equals(contains_3f(result, "Compile error: unknown identifier: ohno"))
    end
    it("evaulates unknown identifier", _17_)
    package.loaded["foo.bar"] = nil
    return nil
  end
  describe("eval-str", _10_)
  local function _19_()
    local foo_opts = {filename = "foo.fnl", moduleName = "foo"}
    local bar_opts = {filename = "bar.fnl", moduleName = "bar"}
    local bash_repl
    local function _20_(opts)
      local name = opts.moduleName
      local eval_21 = ani.repl(opts)
      local function _21_()
        return assert.same({["ok?"] = true, results = {3}}, eval_21("(+ 1 2)"))
      end
      it(("evaluate a form in module " .. name), _21_)
      local function _22_()
        assert.same({["ok?"] = true, results = {}}, eval_21("(local hi 10)"))
        return assert.same({["ok?"] = true, results = {15}}, eval_21("(+ 5 hi)"))
      end
      it(("create local and evaluate a form with it in module " .. name), _22_)
      local function _23_()
        assert.same({["ok?"] = true, results = {}}, eval_21("(def hi2 20)"))
        return assert.same({["ok?"] = true, results = {25}}, eval_21("(+ 5 hi2)"))
      end
      return it(("create def and evaluate a form with it in module " .. name), _23_)
    end
    bash_repl = _20_
    bash_repl(foo_opts)
    bash_repl(foo_opts)
    package.loaded[foo_opts.moduleName] = nil
    bash_repl(bar_opts)
    bash_repl(bar_opts)
    package.loaded[bar_opts.moduleName] = nil
    return nil
  end
  return describe("repl", _19_)
end
return describe("client.fennel.aniseed", _2_)
