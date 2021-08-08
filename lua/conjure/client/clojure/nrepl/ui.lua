local _2afile_2a = "fnl/conjure/client/clojure/nrepl/ui.fnl"
local _1_
do
  local name_4_auto = "conjure.client.clojure.nrepl.ui"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", config = "conjure.config", log = "conjure.log", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local config = _local_4_[2]
local log = _local_4_[3]
local state = _local_4_[4]
local str = _local_4_[5]
local text = _local_4_[6]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.clojure.nrepl.ui"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "clojure", "nrepl"})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
local handle_join_line
do
  local v_23_auto
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
      local function _9_()
        if (next_key and not text["trailing-newline?"](a.get(resp, next_key))) then
          return {key = next_key}
        end
      end
      a.assoc(state.get(), "join-next", _9_())
    end
    return (next_key and (key == next_key))
  end
  v_23_auto = handle_join_line0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["handle-join-line"] = v_23_auto
  handle_join_line = v_23_auto
end
local display_result
do
  local v_23_auto
  do
    local v_25_auto
    local function display_result0(resp, opts)
      local opts0 = (opts or {})
      local joined_3f = handle_join_line(resp)
      local _11_
      if resp.out then
        local _12_
        if opts0["simple-out?"] then
          _12_ = "; "
        elseif (opts0["raw-out?"] or cfg({"eval", "raw_out"})) then
          _12_ = ""
        else
          _12_ = "; (out) "
        end
        _11_ = text["prefixed-lines"](text["trim-last-newline"](resp.out), _12_, {["skip-first?"] = joined_3f})
      elseif resp.err then
        _11_ = text["prefixed-lines"](text["trim-last-newline"](resp.err), "; (err) ", {["skip-first?"] = joined_3f})
      elseif resp.value then
        if not (opts0["ignore-nil?"] and ("nil" == resp.value)) then
          _11_ = text["split-lines"](resp.value)
        else
        _11_ = nil
        end
      else
        _11_ = nil
      end
      return log.append(_11_, {["join-first?"] = joined_3f})
    end
    v_25_auto = display_result0
    _1_["display-result"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-result"] = v_23_auto
  display_result = v_23_auto
end
local display_sessions
do
  local v_23_auto
  do
    local v_25_auto
    local function display_sessions0(sessions, cb)
      local current = state.get("conn", "session")
      local function _18_(_16_)
        local _arg_17_ = _16_
        local idx = _arg_17_[1]
        local session = _arg_17_[2]
        local _19_
        if (current == session.id) then
          _19_ = ">"
        else
          _19_ = " "
        end
        return str.join({"; ", _19_, idx, " - ", session.str()})
      end
      log.append(a.concat({("; Sessions (" .. a.count(sessions) .. "):")}, a["map-indexed"](_18_, sessions)), {["break?"] = true})
      if cb then
        return cb()
      end
    end
    v_25_auto = display_sessions0
    _1_["display-sessions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-sessions"] = v_23_auto
  display_sessions = v_23_auto
end
return nil