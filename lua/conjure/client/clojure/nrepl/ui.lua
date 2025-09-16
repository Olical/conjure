-- [nfnl] fnl/conjure/client/clojure/nrepl/ui.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local state = autoload("conjure.client.clojure.nrepl.state")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local M = define("clojure.client.clojure.nrepl.ui")
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
local function handle_join_line(resp)
  local next_key
  if resp.out then
    next_key = "out"
  elseif resp.err then
    next_key = "err"
  else
    next_key = nil
  end
  local key = state.get("join-next", "key")
  if (next_key or resp.value) then
    local function _3_()
      if (next_key and not text["trailing-newline?"](core.get(resp, next_key))) then
        return {key = next_key}
      else
        return nil
      end
    end
    core.assoc(state.get(), "join-next", _3_())
  else
  end
  return (next_key and (key == next_key))
end
M["display-result"] = function(resp, opts)
  local opts0 = (opts or {})
  local joined_3f = handle_join_line(resp)
  local _5_
  if resp.out then
    local _6_
    if (opts0["raw-out?"] or cfg({"eval", "raw_out"})) then
      _6_ = ""
    elseif opts0["simple-out?"] then
      _6_ = "; "
    else
      _6_ = "; (out) "
    end
    _5_ = text["prefixed-lines"](text["trim-last-newline"](resp.out), _6_, {["skip-first?"] = joined_3f})
  elseif resp.err then
    _5_ = text["prefixed-lines"](text["trim-last-newline"](resp.err), "; (err) ", {["skip-first?"] = joined_3f})
  elseif resp.value then
    if not (opts0["ignore-nil?"] and ("nil" == resp.value)) then
      _5_ = text["split-lines"](resp.value)
    else
      _5_ = nil
    end
  else
    _5_ = nil
  end
  return log.append(_5_, {["join-first?"] = joined_3f, ["low-priority?"] = not not (resp.out or resp.err)})
end
M["display-sessions"] = function(sessions, cb)
  local current = state.get("conn", "session")
  local function _11_(_10_)
    local idx = _10_[1]
    local session = _10_[2]
    local _12_
    if (current == session.id) then
      _12_ = ">"
    else
      _12_ = " "
    end
    return str.join({"; ", _12_, idx, " - ", session.str()})
  end
  log.append(core.concat({("; Sessions (" .. core.count(sessions) .. "):")}, core["map-indexed"](_11_, sessions)), {["break?"] = true})
  if cb then
    return cb()
  else
    return nil
  end
end
return M
