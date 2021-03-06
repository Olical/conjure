local _2afile_2a = "fnl/conjure/client/clojure/nrepl/ui.fnl"
local _0_
do
  local name_0_ = "conjure.client.clojure.nrepl.ui"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", config = "conjure.config", log = "conjure.log", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local config = _local_0_[2]
local log = _local_0_[3]
local state = _local_0_[4]
local str = _local_0_[5]
local text = _local_0_[6]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.client.clojure.nrepl.ui"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local cfg
do
  local v_0_ = config["get-in-fn"]({"client", "clojure", "nrepl"})
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["cfg"] = v_0_
  cfg = v_0_
end
local handle_join_line
do
  local v_0_
  local function handle_join_line0(resp)
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
      local function _4_()
        if (next_key and not text["trailing-newline?"](a.get(resp, next_key))) then
          return {key = next_key}
        end
      end
      a.assoc(state.get(), "join-next", _4_())
    end
    return (next_key and (key == next_key))
  end
  v_0_ = handle_join_line0
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["handle-join-line"] = v_0_
  handle_join_line = v_0_
end
local display_result
do
  local v_0_
  do
    local v_0_0
    local function display_result0(resp, opts)
      local opts0 = (opts or {})
      local joined_3f = handle_join_line(resp)
      local _3_
      if resp.out then
        local _4_
        if opts0["simple-out?"] then
          _4_ = "; "
        elseif (opts0["raw-out?"] or cfg({"eval", "raw_out"})) then
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
      return log.append(_3_, {["join-first?"] = joined_3f})
    end
    v_0_0 = display_result0
    _0_["display-result"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["display-result"] = v_0_
  display_result = v_0_
end
local display_sessions
do
  local v_0_
  do
    local v_0_0
    local function display_sessions0(sessions, cb)
      local current = state.get("conn", "session")
      local function _4_(_3_)
        local _arg_0_ = _3_
        local idx = _arg_0_[1]
        local session = _arg_0_[2]
        local _5_
        if (current == session.id) then
          _5_ = ">"
        else
          _5_ = " "
        end
        return str.join({"; ", _5_, idx, " - ", session.str()})
      end
      log.append(a.concat({("; Sessions (" .. a.count(sessions) .. "):")}, a["map-indexed"](_4_, sessions)), {["break?"] = true})
      if cb then
        return cb()
      end
    end
    v_0_0 = display_sessions0
    _0_["display-sessions"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["display-sessions"] = v_0_
  display_sessions = v_0_
end
return nil