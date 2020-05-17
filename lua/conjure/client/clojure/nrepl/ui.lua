local _0_0 = nil
do
  local name_23_0_ = "conjure.client.clojure.nrepl.ui"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", state = "conjure.client.clojure.nrepl.state", text = "conjure.text"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.client.clojure.nrepl.state"), require("conjure.text")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local log = _2_[3]
local state = _2_[4]
local text = _2_[5]
do local _ = ({nil, _0_0, nil})[2] end
local display = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display0(lines, opts)
      return client["with-filetype"]("clojure", log.append, lines, opts)
    end
    v_23_0_0 = display0
    _0_0["display"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display"] = v_23_0_
  display = v_23_0_
end
local state0 = nil
do
  local v_23_0_ = (_0_0["aniseed/locals"].state or {["join-next"] = {key = nil}})
  _0_0["aniseed/locals"]["state"] = v_23_0_
  state0 = v_23_0_
end
local handle_join_line = nil
do
  local v_23_0_ = nil
  local function handle_join_line0(resp)
    local next_key = nil
    if resp.out then
      next_key = "out"
    elseif resp.err then
      next_key = "err"
    else
    next_key = nil
    end
    local _4_ = a.get(state0, "join-next", {})
    local key = _4_["key"]
    if (next_key or resp.value) then
      local function _5_()
        if (next_key and not text["trailing-newline?"](a.get(resp, next_key))) then
          return {key = next_key}
        end
      end
      a.assoc(state0, "join-next", _5_())
    end
    return (next_key and (key == next_key))
  end
  v_23_0_ = handle_join_line0
  _0_0["aniseed/locals"]["handle-join-line"] = v_23_0_
  handle_join_line = v_23_0_
end
local display_result = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_result0(resp, opts)
      local opts0 = (opts or {})
      local joined_3f = handle_join_line(resp)
      local _3_
      if resp.out then
        local _4_
        if opts0["simple-out?"] then
          _4_ = "; "
        elseif opts0["raw-out?"] then
          _4_ = ""
        else
          _4_ = "; (out) "
        end
        _3_ = text["prefixed-lines"](text["trim-last-newline"](resp.out), _4_, {["skip-first?"] = joined_3f})
      elseif resp.err then
        _3_ = text["prefixed-lines"](text["trim-last-newline"](resp.err), "; (err) ", {["skip-first?"] = joined_3f})
      elseif resp.value then
        if not (opts0["ignore-nil?"] and ("nil" == resp.value)) then
          _3_ = text["split-lines"](resp.value)
        else
        _3_ = nil
        end
      else
        _3_ = nil
      end
      return display(_3_, {["join-first?"] = joined_3f})
    end
    v_23_0_0 = display_result0
    _0_0["display-result"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-result"] = v_23_0_
  display_result = v_23_0_
end
local display_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_sessions0(sessions, cb)
      local current = a["get-in"](state0, {"conn", "session"})
      local function _3_(_4_0)
        local _5_ = _4_0
        local idx = _5_[1]
        local session = _5_[2]
        local function _6_()
          if (current == session) then
            return " (current)"
          else
            return ""
          end
        end
        return (";  " .. idx .. " - " .. session .. _6_())
      end
      display(a.concat({("; Sessions (" .. a.count(sessions) .. "):")}, a["map-indexed"](_3_, sessions)), {["break?"] = true})
      if cb then
        return cb(sessions)
      end
    end
    v_23_0_0 = display_sessions0
    _0_0["display-sessions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-sessions"] = v_23_0_
  display_sessions = v_23_0_
end
return nil