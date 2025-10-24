-- [nfnl] fnl/conjure-spec/fs_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local fs = require("conjure.fs")
local function _2_()
  local function _3_()
    local function _4_()
      vim.fn.setenv("XDG_CONFIG_HOME", "")
      vim.fn.setenv("HOME", "/home/conjure")
      return assert.equals("/home/conjure/.config/conjure", fs["config-dir"]())
    end
    return it("returns the default config dir when XDG_CONFIG_HOME is not set", _4_)
  end
  local function _5_()
    vim.fn.setenv("XDG_CONFIG_HOME", "/home/conjure/.config")
    return assert.equals("/home/conjure/.config/conjure", fs["config-dir"]())
  end
  return describe("config-dir", _3_, it("returns the XDG config dir when XDG_CONFIG_HOME is set", _5_))
end
local function _6_()
  local function _7_()
    return assert.equals(nil, fs.findfile("definitely doesn't exist"))
  end
  it("returns nil for non-existent files", _7_)
  local function _8_()
    return assert.equals((vim.fn.getcwd() .. "/README.adoc"), fs.findfile("README.adoc"))
  end
  return it("returns the correct file path for an existing file", _8_)
end
local function _9_()
  local function _10_()
    return assert.equals(false, fs["file-readable?"]("doesn't exist"))
  end
  it("returns false for non-existent files", _10_)
  local function _11_()
    return assert.equals(false, fs["file-readable?"]("fnl"))
  end
  it("returns false for directories", _11_)
  local function _12_()
    return assert.equals(true, fs["file-readable?"]("README.adoc"))
  end
  return it("returns true for readable files", _12_)
end
local function _13_()
  local function _14_()
    return assert.same({}, fs["split-path"](""))
  end
  it("returns an empty list for an empty path", _14_)
  local function _15_()
    return assert.same({}, fs["split-path"]("/"))
  end
  it("returns an empty list for the root path", _15_)
  local function _16_()
    return assert.same({"foo", "bar", "baz"}, fs["split-path"]("/foo/bar/baz"))
  end
  return it("splits a path into its components", _16_)
end
local function _17_()
  local function _18_()
    return assert.equals("", fs["join-path"]({}))
  end
  it("returns an empty string for an empty list", _18_)
  local function _19_()
    return assert.equals("foo/bar/baz", fs["join-path"]({"foo", "bar", "baz"}))
  end
  return it("joins path components into a single string", _19_)
end
local function _20_()
  local function _21_()
    return assert.equals("fnl/conjure/fs.fnl", fs["resolve-relative-to"]((vim.fn.getcwd() .. "/fnl/conjure/fs.fnl"), vim.fn.getcwd()))
  end
  it("resolves a path relative to a given base path", _21_)
  local function _22_()
    return assert.equals("/foo/bar/fnl/conjure/fs.fnl-nope", fs["resolve-relative-to"]("/foo/bar/fnl/conjure/fs.fnl-nope", vim.fn.getcwd()))
  end
  return it("falls back to the original path if it can't be resolved", _22_)
end
local function _23_()
  local function _24_()
    return assert.equals("/home/olical/foo", fs["apply-path-subs"]("/home/ollie/foo", {ollie = "olical"}))
  end
  it("applies a simple mid-string replacement", _24_)
  local function _25_()
    return assert.equals("/home/ollie/foo", fs["apply-path-subs"]("/home/ollie/foo", {["^ollie"] = "olical"}))
  end
  it("does nothing when there are no matches", _25_)
  local function _26_()
    return assert.equals("/home/ollie/foo", fs["apply-path-subs"]("/home/ollie/foo", nil))
  end
  it("does nothing when path-subs is nil", _26_)
  local function _27_()
    return assert.equals("/home/olical/foo", fs["apply-path-subs"]("/home/ollie/foo", {["^(/home/)ollie"] = "%1olical"}))
  end
  return it("applies a gsub capture group replacement", _27_)
end
local function _28_()
  local ex_mod = "test.foo.bar"
  local ex_file = "/some-big/ol/path/test/foo/bar.fnl"
  local ex_file2 = "/some-big/ol/path/test/foo/bar/init.fnl"
  local ex_no_file = "/some-big/ol/path/test/foo/bar/no/init.fnl"
  local function _29_()
    return assert.equals(nil, fs["file-path->module-name"](nil))
  end
  it("returns nil for a nil file path", _29_)
  local function _30_()
    package.loaded[ex_mod] = {my = "module"}
    assert.equals(ex_mod, fs["file-path->module-name"](ex_file))
    assert.equals(ex_mod, fs["file-path->module-name"](ex_file2))
    package.loaded[ex_mod] = nil
    return nil
  end
  it("returns the module name for a valid file path", _30_)
  local function _31_()
    return assert.equals(nil, fs["file-path->module-name"](ex_no_file))
  end
  return it("returns nil for a non-existent file path", _31_)
end
local function _32_()
  local function _33_()
    assert.equals(nil, fs["upwards-file-search"]({}, vim.fn.getcwd()))
    return assert.equals(nil, fs["upwards-file-search"]({"thisbetternotexist"}, vim.fn.getcwd()))
  end
  it("returns nil when no match is found", _33_)
  local function _34_()
    return assert.equals((vim.fn.getcwd() .. "/README.adoc"), fs["upwards-file-search"]({"README.adoc"}, vim.fn.getcwd()))
  end
  it("finds a file in the current directory", _34_)
  local function _35_()
    return assert.equals((vim.fn.getcwd() .. "/README.adoc"), fs["upwards-file-search"]({"README.adoc"}, (vim.fn.getcwd() .. "/fnl/conjure/client/clojure/nrepl")))
  end
  it("walks upwards to find a file", _35_)
  local function _36_()
    return assert.equals((vim.fn.getcwd() .. "/fnl/conjure-spec/.fs.test"), fs["upwards-file-search"]({"README.adoc", ".fs.test"}, (vim.fn.getcwd() .. "/fnl/conjure-spec/client/clojure/nrepl")))
  end
  it("returns early when matching below first", _36_)
  local function _37_()
    return assert.equals((vim.fn.getcwd() .. "/fnl/conjure-spec/.fs.test"), fs["upwards-file-search"]({"README.adoc", ".fs.test"}, (vim.fn.getcwd() .. "/fnl/conjure-spec")))
  end
  return it("returns early when matching at the same level first", _37_)
end
local function _38_()
  local function _39_()
    assert.equals(nil, fs["resolve-above"]({}))
    return assert.equals(nil, fs["resolve-above"]({"thisbetternotexist"}))
  end
  it("returns nil when no match is found", _39_)
  local function _40_()
    return assert.equals((vim.fn.getcwd() .. "/README.adoc"), fs["resolve-above"]({"README.adoc"}))
  end
  return it("finds a file in the current directory", _40_)
end
local function _41_()
  local function _42_()
    return assert.equals((vim.fn.getcwd() .. "/.test/nvim/pack/main/start/conjure"), fs["conjure-source-directory"])
  end
  return it("returns the current working directory", _42_)
end
return describe("fs", _2_, describe("findfile", _6_), describe("file-readable?", _9_), describe("split-path", _13_), describe("join-path", _17_), describe("resolve-relative-to", _20_), describe("apply-path-subs", _23_), describe("file-path->module-name", _28_), describe("upwards-file-search", _32_), describe("resolve-above", _38_), describe("conjure-source-directory", _41_))
