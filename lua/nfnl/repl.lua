-- [nfnl] Compiled from fnl/nfnl/repl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("nfnl.core")
local fennel = autoload("nfnl.fennel")
local notify = autoload("nfnl.notify")
local str = autoload("nfnl.string")
local function new(opts)
  local results_to_return = nil
  local cfg
  do
    local t_2_ = opts
    if (nil ~= t_2_) then
      t_2_ = t_2_.cfg
    else
    end
    cfg = t_2_
  end
  local co
  local function _4_()
    local function _5_(results)
      results_to_return = core.concat(results_to_return, results)
      return nil
    end
    local function _6_(err_type, err, lua_source)
      local _8_
      do
        local t_7_ = opts
        if (nil ~= t_7_) then
          t_7_ = t_7_["on-error"]
        else
        end
        _8_ = t_7_
      end
      if _8_ then
        return opts["on-error"](err_type, err, lua_source)
      else
        return notify.error(str.trim(str.join("\n\n", {("[" .. err_type .. "] " .. err), lua_source})))
      end
    end
    local function _11_()
      if cfg then
        return cfg({"compiler-options"})
      else
        return nil
      end
    end
    return fennel.repl(core["merge!"]({pp = core.identity, readChunk = coroutine.yield, env = core.merge(_G), onValues = _5_, onError = _6_}, _11_()))
  end
  co = coroutine.create(_4_)
  coroutine.resume(co)
  local function _12_(input)
    if cfg then
      fennel.path = cfg({"fennel-path"})
      fennel["macro-path"] = cfg({"fennel-macro-path"})
    else
    end
    coroutine.resume(co, input)
    local prev_eval_values = results_to_return
    results_to_return = nil
    return prev_eval_values
  end
  return _12_
end
return {new = new}
