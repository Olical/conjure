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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.text")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local log = _2_[3]
local state = _2_[4]
local str = _2_[5]
local text = _2_[6]
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
local flatten_test_results = nil
do
  local v_23_0_ = nil
  local function flatten_test_results0(results)
    return a.concat(unpack(a.concat(unpack(a.map(a.vals, a.vals(results))))))
  end
  v_23_0_ = flatten_test_results0
  _0_0["aniseed/locals"]["flatten-test-results"] = v_23_0_
  flatten_test_results = v_23_0_
end
local display_test_result = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_test_result0(_3_0)
      local _4_ = _3_0
      local summary = _4_["summary"]
      local results = _4_["results"]
      local function _5_()
        if results then
          local function _5_(_6_0)
            local _7_ = _6_0
            local name = _7_["var"]
            local file = _7_["file"]
            local actual = _7_["actual"]
            local message = _7_["message"]
            local context = _7_["context"]
            local line = _7_["line"]
            local status = _7_["type"]
            local err = _7_["error"]
            local expected = _7_["expected"]
            local ns = _7_["ns"]
            local _8_
            if not a["empty?"](context) then
              _8_ = (" (" .. text["left-sample"](context, 32) .. ")")
            else
            _8_ = nil
            end
            local _10_
            if not a["empty?"](message) then
              _10_ = text["prefixed-lines"](message, "; ")
            else
            _10_ = nil
            end
            local function _12_()
              if err then
                return text["prefixed-lines"](err, "; ")
              elseif (expected ~= actual) then
                return a.concat({"; Expected:"}, text["split-lines"](expected), {""}, {"; Actual:"}, text["split-lines"](actual), {""})
              end
            end
            return a.concat({str.join({"; [", ns, "/", name, "] ", string.upper(status), _8_, " ", file, ":", line})}, _10_, _12_())
          end
          local function _7_(_241)
            return ("pass" ~= a.get(_241, "type"))
          end
          local function _8_()
            if (0 == summary.fail) then
              return "OK"
            else
              return "FAILED"
            end
          end
          return a.concat(a.concat(unpack(a.map(_5_, a.filter(_7_, flatten_test_results(results))))), {("; [total] " .. _8_() .. " " .. summary.pass .. "/" .. summary.test .. " assertions passed (" .. summary.var .. " tests, " .. summary.error .. " errors)")})
        else
          return {"; No results"}
        end
      end
      return display(_5_())
    end
    v_23_0_0 = display_test_result0
    _0_0["display-test-result"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-test-result"] = v_23_0_
  display_test_result = v_23_0_
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