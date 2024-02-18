local _2afile_2a = "test/fnl/conjure/client/fennel/aniseed-test.fnl"
local _2amodule_name_2a = "conjure.client.fennel.aniseed-test"
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
local a, ani = require("conjure.aniseed.core"), require("conjure.client.fennel.aniseed")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["ani"] = ani
local ex_mod = "test.foo.bar"
_2amodule_2a["ex-mod"] = ex_mod
local ex_file = "/some-big/ol/path/test/foo/bar.fnl"
_2amodule_2a["ex-file"] = ex_file
local ex_file2 = "/some-big/ol/path/test/foo/bar/init.fnl"
_2amodule_2a["ex-file2"] = ex_file2
local ex_no_file = "/some-big/ol/path/test/foo/bar/no/init.fnl"
_2amodule_2a["ex-no-file"] = ex_no_file
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    package.loaded[ex_mod] = {my = "module"}
    t["="](ani["default-module-name"], ani["module-name"](nil, nil))
    t["="](ex_mod, ani["module-name"](ex_mod, ex_file))
    t["="](ex_mod, ani["module-name"](nil, ex_file))
    t["="](ex_mod, ani["module-name"](nil, ex_file2))
    t["="](ani["default-module-name"], ani["module-name"](nil, ex_no_file))
    do end (package.loaded)[ex_mod] = nil
    return nil
  end
  tests_24_auto["module-name"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
local function contains_3f(s, substr)
  local function _2_()
    if string.find(s, substr) then
      return substr
    else
      return s
    end
  end
  return substr, _2_()
end
_2amodule_2a["contains?"] = contains_3f
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    local foo_opts = {filename = "foo.fnl", moduleName = "foo"}
    local bar_opts = {filename = "bar.fnl", moduleName = "bar"}
    local bash_repl
    local function _4_(opts)
      local eval_21 = ani.repl(opts)
      t["pr="]({["ok?"] = true, results = {3}}, eval_21("(+ 1 2)"))
      t["pr="]({["ok?"] = true, results = {}}, eval_21("(local hi 10)"))
      t["pr="]({["ok?"] = true, results = {15}}, eval_21("(+ 5 hi)"))
      t["pr="]({["ok?"] = true, results = {}}, eval_21("(def hi2 20)"))
      t["pr="]({["ok?"] = true, results = {25}}, eval_21("(+ 5 hi2)"))
      do
        local _let_5_ = eval_21("(ohno)")
        local results = _let_5_["results"]
        local ok_3f = _let_5_["ok?"]
        t["="](false, ok_3f)
        t["="](contains_3f(a.first(results), "Compile error: unknown identifier: ohno"))
      end
      local _let_6_ = eval_21("(())")
      local results = _let_6_["results"]
      local ok_3f = _let_6_["ok?"]
      t["="](false, ok_3f)
      return t["="](contains_3f(a.first(results), "expected a function"))
    end
    bash_repl = _4_
    bash_repl(foo_opts)
    bash_repl(foo_opts)
    do end (package.loaded)[foo_opts.moduleName] = nil
    bash_repl(bar_opts)
    bash_repl(bar_opts)
    do end (package.loaded)[bar_opts.moduleName] = nil
    return nil
  end
  tests_24_auto["repl"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _7_(t)
    local function eval_21(code)
      local result = nil
      local raw = nil
      local function _8_(_241)
        result = _241
        return nil
      end
      local function _9_(_241)
        raw = _241
        return nil
      end
      ani["eval-str"]({code = code, context = "foo.bar", ["passive?"] = true, ["file-path"] = "foo/bar.fnl", ["on-result"] = _8_, ["on-result-raw"] = _9_})
      return {result = result, raw = raw}
    end
    t["pr="]({raw = {30}, result = "30"}, eval_21("(+ 10 20)"))
    do
      local _let_10_ = eval_21("(fn hi [] 10)")
      local raw = _let_10_["raw"]
      local result = _let_10_["result"]
      t["="]("function", type(a.first(raw)))
      t["="](contains_3f(result, "#<function: "))
    end
    t["pr="]({raw = {10}, result = "10"}, eval_21("(hi)"))
    do
      local _let_11_ = eval_21("(ohno)")
      local result = _let_11_["result"]
      local raw = _let_11_["raw"]
      t["="](contains_3f(result, "Compile error: unknown identifier: ohno"))
    end
    package.loaded["foo.bar"] = nil
    return nil
  end
  tests_24_auto["eval-str"] = _7_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a