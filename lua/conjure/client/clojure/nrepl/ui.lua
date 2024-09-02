-- [nfnl] Compiled from fnl/conjure/client/clojure/nrepl/ui.fnl by https://github.com/Olical/nfnl, do not edit.
local autoload = require("nfnl.autoload")
local a = autoload("conjure.aniseed.core")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local state = autoload("conjure.client.clojure.nrepl.state")
local str = autoload("conjure.aniseed.string")
local text = autoload("conjure.text")
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
    local function _2_()
      if (next_key and not text["trailing-newline?"](a.get(resp, next_key))) then
        return {key = next_key}
      else
        return nil
      end
    end
    a.assoc(state.get(), "join-next", _2_())
  else
  end
  return (next_key and (key == next_key))
end
local function display_result(resp, opts)
  local opts0 = (opts or {})
  local joined_3f = handle_join_line(resp)
  local _4_
  if resp.out then
    local _5_
    if (opts0["raw-out?"] or cfg({"eval", "raw_out"})) then
      _5_ = ""
    elseif opts0["simple-out?"] then
      _5_ = "; "
    else
      _5_ = "; (out) "
    end
    _4_ = text["prefixed-lines"](text["trim-last-newline"](resp.out), _5_, {["skip-first?"] = joined_3f})
  elseif resp.err then
    _4_ = text["prefixed-lines"](text["trim-last-newline"](resp.err), "; (err) ", {["skip-first?"] = joined_3f})
  elseif resp.value then
    if not (opts0["ignore-nil?"] and ("nil" == resp.value)) then
      _4_ = text["split-lines"](resp.value)
    else
      _4_ = nil
    end
  else
    _4_ = nil
  end
  return log.append(_4_, {["join-first?"] = joined_3f, ["low-priority?"] = not not (resp.out or resp.err)})
end
local function display_sessions(sessions, cb)
  local current = state.get("conn", "session")
  local function _10_(_9_)
    local idx = _9_[1]
    local session = _9_[2]
    local _11_
    if (current == session.id) then
      _11_ = ">"
    else
      _11_ = " "
    end
    return str.join({"; ", _11_, idx, " - ", session.str()})
  end
  log.append(a.concat({("; Sessions (" .. a.count(sessions) .. "):")}, a["map-indexed"](_10_, sessions)), {["break?"] = true})
  if cb then
    return cb()
  else
    return nil
  end
end
return {["display-result"] = display_result, ["display-sessions"] = display_sessions}
