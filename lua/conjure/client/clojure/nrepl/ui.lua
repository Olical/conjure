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
    local function display_result0(resp, opts)
      local opts0 = (opts or {})
      local function _3_()
        if resp.out then
          local function _3_()
            if opts0["simple-out?"] then
              return "; "
            elseif opts0["raw-out?"] then
              return ""
            else
              return "; (out) "
            end
          end
          return text["prefixed-lines"](resp.out, _3_())
        elseif resp.err then
          return text["prefixed-lines"](resp.err, "; (err) ")
        elseif resp.value then
          if not (opts0["ignore-nil?"] and ("nil" == resp.value)) then
            return text["split-lines"](resp.value)
          end
        else
          return nil
        end
      end
      return display(_3_())
    end
    v_23_0_0 = display_result0
    _0_0["display-result"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-result"] = v_23_0_
  display_result = v_23_0_
end
local display_result_fn = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_result_fn0(opts)
      local state0 = {err = "", out = ""}
      local function _3_(resp)
        local k = nil
        if resp.out then
          k = "out"
        elseif resp.err then
          k = "err"
        else
        k = nil
        end
        if k then
          local s = a.get(resp, k)
          local current = a.get(state0, k)
          local start, _end = string.find(string.reverse(s), "\n")
          if start then
            if (1 == start) then
              a.assoc(state0, k, "")
              a.assoc(resp, k, (current .. s))
              return display_result(resp, opts)
            else
              local before = string.sub(s, 1, ( - start))
              local after = string.sub(s, ( - _end))
              a.assoc(state0, k, after)
              a.assoc(resp, k, (current .. before))
              return display_result(resp, opts)
            end
          else
            a.assoc(state0, k, (current .. s))
            return nil
          end
        else
          if resp.value then
            local function _5_(k0)
              local s = a.get(state0, k0)
              if not a["empty?"](s) then
                return display_result({[k0] = s})
              end
            end
            a["run!"](_5_, {"out", "err"})
          end
          return display_result(resp, opts)
        end
      end
      return _3_
    end
    v_23_0_0 = display_result_fn0
    _0_0["display-result-fn"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-result-fn"] = v_23_0_
  display_result_fn = v_23_0_
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