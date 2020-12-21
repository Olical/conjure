local _0_0 = nil
do
  local name_0_ = "conjure.client.clojure.nrepl.ui"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core"), require("conjure.log"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", log = "conjure.log", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local log = _local_0_[2]
local state = _local_0_[3]
local str = _local_0_[4]
local text = _local_0_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.ui"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local handle_join_line = nil
do
  local v_0_ = nil
  local function handle_join_line0(resp)
    local next_key = nil
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
        if (next_key and not text["trailing-newline?"](a.get(resp, next_key))) then
          return {key = next_key}
        end
      end
      a.assoc(state.get(), "join-next", _3_())
    end
    return (next_key and (key == next_key))
  end
  v_0_ = handle_join_line0
  _0_0["aniseed/locals"]["handle-join-line"] = v_0_
  handle_join_line = v_0_
end
local display_result = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display_result0(resp, opts)
      local opts0 = (opts or {})
      local joined_3f = handle_join_line(resp)
      local _2_
      if resp.out then
        local _3_
        if opts0["simple-out?"] then
          _3_ = "; "
        elseif opts0["raw-out?"] then
          _3_ = ""
        else
          _3_ = "; (out) "
        end
        _2_ = text["prefixed-lines"](text["trim-last-newline"](resp.out), _3_, {["skip-first?"] = joined_3f})
      elseif resp.err then
        _2_ = text["prefixed-lines"](text["trim-last-newline"](resp.err), "; (err) ", {["skip-first?"] = joined_3f})
      elseif resp.value then
        if not (opts0["ignore-nil?"] and ("nil" == resp.value)) then
          _2_ = text["split-lines"](resp.value)
        else
        _2_ = nil
        end
      else
        _2_ = nil
      end
      return log.append(_2_, {["join-first?"] = joined_3f})
    end
    v_0_0 = display_result0
    _0_0["display-result"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["display-result"] = v_0_
  display_result = v_0_
end
local display_sessions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display_sessions0(sessions, cb)
      local current = state.get("conn", "session")
      local function _2_(_3_0)
        local _arg_0_ = _3_0
        local idx = _arg_0_[1]
        local session = _arg_0_[2]
        local _4_
        if (current == session.id) then
          _4_ = ">"
        else
          _4_ = " "
        end
        return str.join({"; ", _4_, idx, " - ", session.str()})
      end
      log.append(a.concat({("; Sessions (" .. a.count(sessions) .. "):")}, a["map-indexed"](_2_, sessions)), {["break?"] = true})
      if cb then
        return cb()
      end
    end
    v_0_0 = display_sessions0
    _0_0["display-sessions"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["display-sessions"] = v_0_
  display_sessions = v_0_
end
return nil