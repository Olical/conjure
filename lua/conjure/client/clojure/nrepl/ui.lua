local _2afile_2a = "fnl/conjure/client/clojure/nrepl/ui.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.ui"
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
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, config, log, state, str, text = autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["state"] = state
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
do end (_2amodule_locals_2a)["cfg"] = cfg
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
_2amodule_locals_2a["handle-join-line"] = handle_join_line
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
  return log.append(_4_, {["join-first?"] = joined_3f})
end
_2amodule_2a["display-result"] = display_result
local function display_sessions(sessions, cb)
  local current = state.get("conn", "session")
  local function _11_(_9_)
    local _arg_10_ = _9_
    local idx = _arg_10_[1]
    local session = _arg_10_[2]
    local _12_
    if (current == session.id) then
      _12_ = ">"
    else
      _12_ = " "
    end
    return str.join({"; ", _12_, idx, " - ", session.str()})
  end
  log.append(a.concat({("; Sessions (" .. a.count(sessions) .. "):")}, a["map-indexed"](_11_, sessions)), {["break?"] = true})
  if cb then
    return cb()
  else
    return nil
  end
end
_2amodule_2a["display-sessions"] = display_sessions