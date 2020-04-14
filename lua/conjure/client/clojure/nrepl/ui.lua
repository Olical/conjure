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
local display_result = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_result0(opts, resp)
      local lines = nil
      if resp.out then
        lines = text["prefixed-lines"](resp.out, "; (out) ")
      elseif resp.err then
        lines = text["prefixed-lines"](resp.err, "; (err) ")
      elseif resp.value then
        lines = text["split-lines"](resp.value)
      else
        lines = nil
      end
      return display(lines)
    end
    v_23_0_0 = display_result0
    _0_0["display-result"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-result"] = v_23_0_
  display_result = v_23_0_
end
local display_given_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_given_sessions0(sessions, cb)
      local current = a["get-in"](state, {"conn", "session"})
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
    v_23_0_0 = display_given_sessions0
    _0_0["display-given-sessions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-given-sessions"] = v_23_0_
  display_given_sessions = v_23_0_
end
return nil