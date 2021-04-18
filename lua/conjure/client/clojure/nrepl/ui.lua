local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.clojure.nrepl.ui"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.log"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.text")}
local a = _local_0_[1]
local log = _local_0_[2]
local state = _local_0_[3]
local str = _local_0_[4]
local text = _local_0_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.ui"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
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
      end
    end
    a.assoc(state.get(), "join-next", _2_())
  end
  return (next_key and (key == next_key))
end
local display_result
do
  local v_0_
  local function display_result0(resp, opts)
    local opts0 = (opts or {})
    local joined_3f = handle_join_line(resp)
    local _1_
    if resp.out then
      local _2_
      if opts0["simple-out?"] then
        _2_ = "; "
      elseif opts0["raw-out?"] then
        _2_ = ""
      else
        _2_ = "; (out) "
      end
      _1_ = text["prefixed-lines"](text["trim-last-newline"](resp.out), _2_, {["skip-first?"] = joined_3f})
    elseif resp.err then
      _1_ = text["prefixed-lines"](text["trim-last-newline"](resp.err), "; (err) ", {["skip-first?"] = joined_3f})
    elseif resp.value then
      if not (opts0["ignore-nil?"] and ("nil" == resp.value)) then
        _1_ = text["split-lines"](resp.value)
      else
      _1_ = nil
      end
    else
      _1_ = nil
    end
    return log.append(_1_, {["join-first?"] = joined_3f})
  end
  v_0_ = display_result0
  _0_0["display-result"] = v_0_
  display_result = v_0_
end
local display_sessions
do
  local v_0_
  local function display_sessions0(sessions, cb)
    local current = state.get("conn", "session")
    local function _2_(_1_0)
      local _arg_0_ = _1_0
      local idx = _arg_0_[1]
      local session = _arg_0_[2]
      local _3_
      if (current == session.id) then
        _3_ = ">"
      else
        _3_ = " "
      end
      return str.join({"; ", _3_, idx, " - ", session.str()})
    end
    log.append(a.concat({("; Sessions (" .. a.count(sessions) .. "):")}, a["map-indexed"](_2_, sessions)), {["break?"] = true})
    if cb then
      return cb()
    end
  end
  v_0_ = display_sessions0
  _0_0["display-sessions"] = v_0_
  display_sessions = v_0_
end
return nil