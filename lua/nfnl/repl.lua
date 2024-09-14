-- [nfnl] Compiled from fnl/nfnl/repl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("nfnl.core")
local fennel = autoload("nfnl.fennel")
local notify = autoload("nfnl.notify")
local str = autoload("nfnl.string")
local function new(opts)
  local results_to_return = nil
  local co
  local function _2_()
    local function _3_(results)
      results_to_return = core.concat(results_to_return, results)
      return nil
    end
    local function _4_(err_type, err, lua_source)
      local _6_
      do
        local t_5_ = opts
        if (nil ~= t_5_) then
          t_5_ = t_5_["on-error"]
        else
        end
        _6_ = t_5_
      end
      if _6_ then
        return opts["on-error"](err_type, err, lua_source)
      else
        return notify.error(str.join("\n\n", {("[" .. err_type .. "] " .. err), lua_source}))
      end
    end
    return fennel.repl({pp = core.identity, readChunk = coroutine.yield, onValues = _3_, onError = _4_})
  end
  co = coroutine.create(_2_)
  coroutine.resume(co)
  local function _9_(input)
    coroutine.resume(co, input)
    local prev_eval_values = results_to_return
    results_to_return = nil
    return prev_eval_values
  end
  return _9_
end
return {new = new}
