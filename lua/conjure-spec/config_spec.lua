-- [nfnl] fnl/conjure-spec/config_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local config = require("conjure.config")
local core = require("conjure.nfnl.core")
local function _2_()
  local function _3_()
    assert.is_true(config["get-in"]({"client_on_load"}))
    return assert.same("conjure.client.clojure.nrepl", config["get-in"]({"filetype", "clojure"}))
  end
  it("takes a table of keys and fetches the config value from vim.b or vim.g variables.", _3_)
  local function _4_()
    core.assoc(vim.g, "conjure#buf_override#key", {"K"})
    core.assoc(vim.b, "conjure#buf_override#key", false)
    local result = config["get-in"]({"buf_override", "key"})
    core.assoc(vim.g, "conjure#buf_override#key", nil)
    core.assoc(vim.b, "conjure#buf_override#key", nil)
    return assert.is_false(result)
  end
  return it("lets a buffer local false override a truthy global value", _4_)
end
describe("get-in", _2_)
local function _5_()
  local function _6_()
    assert.same(config["get-in"]({"filetypes"}), config.filetypes())
    return assert.same("clojure", core.first(config.filetypes()))
  end
  return it("returns the filetypes list", _6_)
end
describe("filetypes", _5_)
local function _7_()
  local function _8_()
    return assert.same("conjure.client.sql.stdio", config["get-in-fn"]({"filetype"})({"sql"}))
  end
  return it("returns a function that works like get-in but with a path prefix", _8_)
end
describe("get-in-fn", _7_)
local function _9_()
  local function _10_()
    config["assoc-in"]({"foo", "bar"}, "baz")
    return assert.same("baz", config["get-in"]({"foo", "bar"}))
  end
  return it("sets some new config", _10_)
end
describe("assoc-in", _9_)
local function _11_()
  local function _12_()
    config.merge({foo = {bar = "de_dust2"}})
    assert.same("baz", config["get-in"]({"foo", "bar"}))
    config.merge({foo = {bar = "de_dust2"}}, {["overwrite?"] = true})
    return assert.same("de_dust2", config["get-in"]({"foo", "bar"}))
  end
  return it("merges more config into the tree, requires overwrite? if it already exists", _12_)
end
describe("merge", _11_)
local function _13_()
  local function _14_()
    local warnings = {}
    local orig = vim.notify_once
    core.assoc(vim.g, "conjure#migration#old-key", "legacy")
    local function _15_(msg, _)
      return table.insert(warnings, msg)
    end
    vim.notify_once = _15_
    local result = config["get-in"]({"migration", "old_key"})
    vim.notify_once = orig
    core.assoc(vim.g, "conjure#migration#old-key", nil)
    assert.same("legacy", result)
    assert.same(1, #warnings)
    return assert.truthy(string.find(warnings[1], "deprecated", 1, true))
  end
  it("get-in falls back to a hyphenated key and emits a deprecation warning", _14_)
  local function _16_()
    local warnings = {}
    local orig = vim.notify_once
    core.assoc(vim.g, "conjure#migration#new_key", "modern")
    local function _17_(msg, _)
      return table.insert(warnings, msg)
    end
    vim.notify_once = _17_
    local result = config["get-in"]({"migration", "new_key"})
    vim.notify_once = orig
    core.assoc(vim.g, "conjure#migration#new_key", nil)
    assert.same("modern", result)
    return assert.same(0, #warnings)
  end
  it("get-in reads an underscore key normally without any warning", _16_)
  local function _18_()
    local warnings = {}
    local orig = vim.notify
    local function _19_(msg, _)
      return table.insert(warnings, msg)
    end
    vim.notify = _19_
    config["assoc-in"]({"migration", "bad-key"}, "val")
    vim.notify = orig
    core.assoc(vim.g, "conjure#migration#bad-key", nil)
    assert.same(1, #warnings)
    return assert.truthy(string.find(warnings[1], "hyphen", 1, true))
  end
  it("assoc-in warns when a key segment contains a hyphen", _18_)
  local function _20_()
    local warnings = {}
    local orig = vim.notify
    local function _21_(msg, _)
      return table.insert(warnings, msg)
    end
    vim.notify = _21_
    config["assoc-in"]({"migration", "good_key"}, "val")
    vim.notify = orig
    core.assoc(vim.g, "conjure#migration#good_key", nil)
    return assert.same(0, #warnings)
  end
  it("assoc-in does not warn for underscore keys", _20_)
  local function _22_()
    local orig = vim.notify_once
    core.assoc(vim.g, "conjure#migration#old-key", "legacy")
    local function _23_(_, _0)
      return nil
    end
    vim.notify_once = _23_
    config.merge({migration = {old_key = "default"}})
    local result = config["get-in"]({"migration", "old_key"})
    vim.notify_once = orig
    core.assoc(vim.g, "conjure#migration#old-key", nil)
    return assert.same("legacy", result)
  end
  it("merge does not overwrite a value already set via the legacy hyphen key", _22_)
  local function _24_()
    local warnings = {}
    local orig = vim.notify_once
    core.assoc(vim.b, "conjure#migration#buf-key", "buffer-legacy")
    local function _25_(msg, _)
      return table.insert(warnings, msg)
    end
    vim.notify_once = _25_
    local result = config["get-in"]({"migration", "buf_key"})
    vim.notify_once = orig
    core.assoc(vim.b, "conjure#migration#buf-key", nil)
    assert.same("buffer-legacy", result)
    assert.same(1, #warnings)
    return assert.truthy(string.find(warnings[1], "deprecated", 1, true))
  end
  return it("get-in falls back to a hyphenated key in vim.b and emits a deprecation warning", _24_)
end
return describe("hyphen migration", _13_)
