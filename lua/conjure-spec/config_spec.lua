-- [nfnl] Compiled from fnl/conjure-spec/config_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local config = require("conjure.config")
local core = require("nfnl.core")
local function _2_()
  local function _3_()
    assert.is_true(config["get-in"]({"client_on_load"}))
    return assert.same("conjure.client.clojure.nrepl", config["get-in"]({"filetype", "clojure"}))
  end
  return it("takes a table of keys and fetches the config value from vim.b or vim.g variables.", _3_)
end
describe("get-in", _2_)
local function _4_()
  local function _5_()
    assert.same(config["get-in"]({"filetypes"}), config.filetypes())
    return assert.same("clojure", core.first(config.filetypes()))
  end
  return it("returns the filetypes list", _5_)
end
describe("filetypes", _4_)
local function _6_()
  local function _7_()
    return assert.same("conjure.client.sql.stdio", config["get-in-fn"]({"filetype"})({"sql"}))
  end
  return it("returns a function that works like get-in but with a path prefix", _7_)
end
describe("get-in-fn", _6_)
local function _8_()
  local function _9_()
    config["assoc-in"]({"foo", "bar"}, "baz")
    return assert.same("baz", config["get-in"]({"foo", "bar"}))
  end
  return it("sets some new config", _9_)
end
describe("assoc-in", _8_)
local function _10_()
  local function _11_()
    config.merge({foo = {bar = "de_dust2"}})
    assert.same("baz", config["get-in"]({"foo", "bar"}))
    config.merge({foo = {bar = "de_dust2"}}, {["overwrite?"] = true})
    return assert.same("de_dust2", config["get-in"]({"foo", "bar"}))
  end
  return it("merges more config into the tree, requires overwrite? if it already exists", _11_)
end
return describe("merge", _10_)
