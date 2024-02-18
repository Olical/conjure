local _2afile_2a = "test/fnl/conjure/fs-test.fnl"
local _2amodule_name_2a = "conjure.fs-test"
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
local fs, nvim = require("conjure.fs"), require("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    nvim.fn.setenv("XDG_CONFIG_HOME", "")
    nvim.fn.setenv("HOME", "/home/conjure")
    t["="]("/home/conjure/.config/conjure", fs["config-dir"]())
    nvim.fn.setenv("XDG_CONFIG_HOME", "/home/conjure/.config")
    return t["="]("/home/conjure/.config/conjure", fs["config-dir"]())
  end
  tests_24_auto["config-dir"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    t["="](nil, fs.findfile("definitely doesn't exist"))
    return t["="]("README.adoc", fs.findfile("README.adoc"))
  end
  tests_24_auto["findfile"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    t["="](false, fs["file-readable?"]("doesn't exist"), "doesn't exist")
    t["="](false, fs["file-readable?"]("fnl", "it's a directory"))
    return t["="](true, fs["file-readable?"]("README.adoc"), "README.adoc is readable")
  end
  tests_24_auto["file-readable?"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _4_(t)
    t["pr="]({}, fs["split-path"](""))
    t["pr="]({}, fs["split-path"]("/"))
    return t["pr="]({"foo", "bar", "baz"}, fs["split-path"]("/foo/bar/baz"))
  end
  tests_24_auto["split-path"] = _4_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _5_(t)
    t["pr="]("", fs["join-path"]({}))
    return t["pr="]("foo/bar/baz", fs["join-path"]({"foo", "bar", "baz"}))
  end
  tests_24_auto["join-path"] = _5_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _6_(t)
    t["="]("fnl/conjure/fs.fnl", fs["resolve-relative-to"]((nvim.fn.getcwd() .. "/fnl/conjure/fs.fnl"), nvim.fn.getcwd()), "cut down relative to the root")
    return t["="]("/foo/bar/fnl/conjure/fs.fnl-nope", fs["resolve-relative-to"]("/foo/bar/fnl/conjure/fs.fnl-nope", nvim.fn.getcwd()), "fall back to original")
  end
  tests_24_auto["resolve-relative-to"] = _6_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _7_(t)
    t["="]("/home/olical/foo", fs["apply-path-subs"]("/home/ollie/foo", {ollie = "olical"}), "simple mid-string replacement")
    t["="]("/home/ollie/foo", fs["apply-path-subs"]("/home/ollie/foo", {["^ollie"] = "olical"}), "non matches do nothing")
    t["="]("/home/ollie/foo", fs["apply-path-subs"]("/home/ollie/foo", nil), "nil path-subs does nothing")
    return t["="]("/home/olical/foo", fs["apply-path-subs"]("/home/ollie/foo", {["^(/home/)ollie"] = "%1olical"}), "gsub capture group replacement")
  end
  tests_24_auto["apply-path-subs"] = _7_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
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
  local function _8_(t)
    package.loaded[ex_mod] = {my = "module"}
    t["="](nil, fs["file-path->module-name"](nil))
    t["="](ex_mod, fs["file-path->module-name"](ex_file))
    t["="](ex_mod, fs["file-path->module-name"](ex_file))
    t["="](ex_mod, fs["file-path->module-name"](ex_file2))
    t["="](nil, fs["file-path->module-name"](ex_no_file))
    do end (package.loaded)[ex_mod] = nil
    return nil
  end
  tests_24_auto["file-path->module-name"] = _8_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _9_(t)
    t["="](nil, fs["upwards-file-search"]({}, nvim.fn.getcwd()))
    t["="](nil, fs["upwards-file-search"]({"thisbetternotexist"}, nvim.fn.getcwd()))
    t["="]("README.adoc", fs["upwards-file-search"]({"README.adoc"}, nvim.fn.getcwd()))
    t["="]("README.adoc", fs["upwards-file-search"]({"README.adoc"}, (nvim.fn.getcwd() .. "/test/fnl/conjure/client/clojure/nrepl")))
    t["="]("test/fnl/conjure/.fs.test", fs["upwards-file-search"]({"README.adoc", ".fs.test"}, (nvim.fn.getcwd() .. "/test/fnl/conjure/client/clojure/nrepl")))
    return t["="]("test/fnl/conjure/.fs.test", fs["upwards-file-search"]({"README.adoc", ".fs.test"}, (nvim.fn.getcwd() .. "/test/fnl/conjure")))
  end
  tests_24_auto["upwards-file-search"] = _9_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _10_(t)
    t["="](nil, fs["resolve-above"]({}))
    t["="](nil, fs["resolve-above"]({"thisbetternotexist"}))
    return t["="]("README.adoc", fs["resolve-above"]({"README.adoc"}))
  end
  tests_24_auto["resolve-above"] = _10_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a