-- [nfnl] fnl/conjure-spec/log_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local before_each = _local_1_.before_each
local assert = require("luassert.assert")
local log = require("conjure.log")
local client = require("conjure.client")
local config = require("conjure.config")
local vim = _G.vim
local function _2_()
  local function _3_()
    config["assoc-in"]({"log", "linked_to_client_state"}, false)
    client.state["state-key-set?"] = false
    return nil
  end
  before_each(_3_)
  local function _4_()
    local function _5_()
      local function _6_()
        return assert.is_true(log["log-buf?"](("conjure-log-" .. vim.fn.getpid() .. ".fnl")))
      end
      return client["with-filetype"]("fennel", _6_)
    end
    it("matches a buffer named with the PID", _5_)
    local function _7_()
      client["set-state-key!"]("my-feature")
      local function _8_()
        return assert.is_false(log["log-buf?"]("conjure-log-my-feature.fnl"))
      end
      return client["with-filetype"]("fennel", _8_)
    end
    return it("does not match a buffer named with a state key", _7_)
  end
  describe("linked_to_client_state disabled", _4_)
  local function _9_()
    local function _10_()
      config["assoc-in"]({"log", "linked_to_client_state"}, true)
      return client["set-state-key!"]("my-feature")
    end
    before_each(_10_)
    local function _11_()
      local function _12_()
        return assert.is_true(log["log-buf?"]("conjure-log-my-feature.fnl"))
      end
      return client["with-filetype"]("fennel", _12_)
    end
    it("matches a buffer named with the state key", _11_)
    local function _13_()
      local function _14_()
        return assert.is_false(log["log-buf?"](("conjure-log-" .. vim.fn.getpid() .. ".fnl")))
      end
      return client["with-filetype"]("fennel", _14_)
    end
    return it("does not match a buffer named with the PID", _13_)
  end
  describe("linked_to_client_state enabled with state key set", _9_)
  local function _15_()
    local function _16_()
      return config["assoc-in"]({"log", "linked_to_client_state"}, true)
    end
    before_each(_16_)
    local function _17_()
      local function _18_()
        return assert.is_true(log["log-buf?"](("conjure-log-" .. vim.fn.getpid() .. ".fnl")))
      end
      return client["with-filetype"]("fennel", _18_)
    end
    return it("falls back to matching a buffer named with the PID", _17_)
  end
  return describe("linked_to_client_state enabled but no state key set", _15_)
end
describe("log-buf?", _2_)
local function _19_()
  local function hud_floating_3f()
    local win = log.state.hud.id
    return (("number" == type(win)) and vim.api.nvim_win_is_valid(win) and ("" ~= vim.api.nvim_win_get_config(win).relative))
  end
  local function _20_()
    log["close-hud"]()
    return config["assoc-in"]({"log", "hud", "enabled"}, true)
  end
  before_each(_20_)
  local function _21_()
    client["with-filetype"]("fennel", log["show-hud"])
    return assert.is_true(hud_floating_3f())
  end
  it("opens the HUD", _21_)
  local function _22_()
    config["assoc-in"]({"log", "hud", "enabled"}, false)
    client["with-filetype"]("fennel", log["show-hud"])
    return assert.is_true(hud_floating_3f())
  end
  it("opens the HUD even when the automatic HUD is disabled", _22_)
  local function _23_()
    client["with-filetype"]("fennel", log["show-hud"])
    local first_win = log.state.hud.id
    client["with-filetype"]("fennel", log["show-hud"])
    return assert.are.equals(first_win, log.state.hud.id)
  end
  return it("reuses the open HUD window", _23_)
end
return describe("show-hud", _19_)
