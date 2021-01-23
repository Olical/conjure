local _0_0 = nil
do
  local name_0_ = "conjure.client.clojure.nrepl"
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
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.client.clojure.nrepl.action"), require("conjure.bridge"), require("conjure.client"), require("conjure.config"), require("conjure.eval"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", action = "conjure.client.clojure.nrepl.action", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", eval = "conjure.eval", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local action = _1_[2]
local bridge = _1_[3]
local client = _1_[4]
local config = _1_[5]
local eval = _1_[6]
local mapping = _1_[7]
local nvim = _1_[8]
local str = _1_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local buf_suffix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = ".cljc"
    _0_0["buf-suffix"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = "; "
    _0_0["comment-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
local cfg = nil
do
  local v_0_ = config["get-in-fn"]({"client", "clojure", "nrepl"})
  _0_0["aniseed/locals"]["cfg"] = v_0_
  cfg = v_0_
end
config.merge({client = {clojure = {nrepl = {completion = {cljs = {use_suitable = true}, with_context = false}, connection = {default_host = "localhost", port_files = {".nrepl-port", ".shadow-cljs/nrepl.port"}}, eval = {auto_require = true, pretty_print = true, print_function = "conjure.internal/pprint", print_options = {length = 500, level = 50}, print_quota = nil}, interrupt = {sample_limit = 0.29999999999999999}, mapping = {connect_port_file = "cf", disconnect = "cd", interrupt = "ei", last_exception = "ve", refresh_all = "ra", refresh_changed = "rr", refresh_clear = "rc", result_1 = "v1", result_2 = "v2", result_3 = "v3", run_all_tests = "ta", run_alternate_ns_tests = "tN", run_current_ns_tests = "tn", run_current_test = "tc", session_clone = "sc", session_close = "sq", session_close_all = "sQ", session_fresh = "sf", session_list = "sl", session_next = "sn", session_prev = "sp", session_select = "ss", view_source = "vs"}, refresh = {after = nil, before = nil, dirs = nil}}}}})
local context = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function context0(header)
      local _3_0 = header
      if _3_0 then
        local _4_0 = string.match(_3_0, "%(%s*ns%s+([^)]*)")
        if _4_0 then
          local _5_0 = string.gsub(_4_0, "%^:.-%s+", "")
          if _5_0 then
            local _6_0 = string.gsub(_5_0, "%^%b{}%s+", "")
            if _6_0 then
              local _7_0 = str.split(_6_0, "%s+")
              if _7_0 then
                return a.first(_7_0)
              else
                return _7_0
              end
            else
              return _6_0
            end
          else
            return _5_0
          end
        else
          return _4_0
        end
      else
        return _3_0
      end
    end
    v_0_0 = context0
    _0_0["context"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["context"] = v_0_
  context = v_0_
end
local eval_file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_file0(opts)
      return action["eval-file"](opts)
    end
    v_0_0 = eval_file0
    _0_0["eval-file"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_0_
  eval_file = v_0_
end
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
      return action["eval-str"](opts)
    end
    v_0_0 = eval_str0
    _0_0["eval-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_str0(opts)
      return action["doc-str"](opts)
    end
    v_0_0 = doc_str0
    _0_0["doc-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_0_
  doc_str = v_0_
end
local def_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function def_str0(opts)
      return action["def-str"](opts)
    end
    v_0_0 = def_str0
    _0_0["def-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["def-str"] = v_0_
  def_str = v_0_
end
local completions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function completions0(opts)
      return action.completions(opts)
    end
    v_0_0 = completions0
    _0_0["completions"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["completions"] = v_0_
  completions = v_0_
end
local connect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect0(opts)
      return action["connect-host-port"](opts)
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_0_
  connect = v_0_
end
local on_filetype = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", "CljDisconnect", cfg({"mapping", "disconnect"}), "conjure.client.clojure.nrepl.server", "disconnect")
      mapping.buf("n", "CljConnectPortFile", cfg({"mapping", "connect_port_file"}), "conjure.client.clojure.nrepl.action", "connect-port-file")
      mapping.buf("n", "CljInterrupt", cfg({"mapping", "interrupt"}), "conjure.client.clojure.nrepl.action", "interrupt")
      mapping.buf("n", "CljLastException", cfg({"mapping", "last_exception"}), "conjure.client.clojure.nrepl.action", "last-exception")
      mapping.buf("n", "CljResult1", cfg({"mapping", "result_1"}), "conjure.client.clojure.nrepl.action", "result-1")
      mapping.buf("n", "CljResult2", cfg({"mapping", "result_2"}), "conjure.client.clojure.nrepl.action", "result-2")
      mapping.buf("n", "CljResult3", cfg({"mapping", "result_3"}), "conjure.client.clojure.nrepl.action", "result-3")
      mapping.buf("n", "CljViewSource", cfg({"mapping", "view_source"}), "conjure.client.clojure.nrepl.action", "view-source")
      mapping.buf("n", "CljSessionClone", cfg({"mapping", "session_clone"}), "conjure.client.clojure.nrepl.action", "clone-current-session")
      mapping.buf("n", "CljSessionFresh", cfg({"mapping", "session_fresh"}), "conjure.client.clojure.nrepl.action", "clone-fresh-session")
      mapping.buf("n", "CljSessionClose", cfg({"mapping", "session_close"}), "conjure.client.clojure.nrepl.action", "close-current-session")
      mapping.buf("n", "CljSessionCloseAll", cfg({"mapping", "session_close_all"}), "conjure.client.clojure.nrepl.action", "close-all-sessions")
      mapping.buf("n", "CljSessionList", cfg({"mapping", "session_list"}), "conjure.client.clojure.nrepl.action", "display-sessions")
      mapping.buf("n", "CljSessionNext", cfg({"mapping", "session_next"}), "conjure.client.clojure.nrepl.action", "next-session")
      mapping.buf("n", "CljSessionPrev", cfg({"mapping", "session_prev"}), "conjure.client.clojure.nrepl.action", "prev-session")
      mapping.buf("n", "CljSessionSelect", cfg({"mapping", "session_select"}), "conjure.client.clojure.nrepl.action", "select-session-interactive")
      mapping.buf("n", "CljRunAllTests", cfg({"mapping", "run_all_tests"}), "conjure.client.clojure.nrepl.action", "run-all-tests")
      mapping.buf("n", "CljRunCurrentNsTests", cfg({"mapping", "run_current_ns_tests"}), "conjure.client.clojure.nrepl.action", "run-current-ns-tests")
      mapping.buf("n", "CljRunAlternateNsTests", cfg({"mapping", "run_alternate_ns_tests"}), "conjure.client.clojure.nrepl.action", "run-alternate-ns-tests")
      mapping.buf("n", "CljRunCurrentTests", cfg({"mapping", "run_current_test"}), "conjure.client.clojure.nrepl.action", "run-current-test")
      mapping.buf("n", "CljRefreshChanged", cfg({"mapping", "refresh_changed"}), "conjure.client.clojure.nrepl.action", "refresh-changed")
      mapping.buf("n", "CljRefreshAll", cfg({"mapping", "refresh_all"}), "conjure.client.clojure.nrepl.action", "refresh-all")
      mapping.buf("n", "CljRefreshClear", cfg({"mapping", "refresh_clear"}), "conjure.client.clojure.nrepl.action", "refresh-clear")
      nvim.ex.command_("-nargs=1 -buffer ConjureShadowSelect", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "shadow-select", {args = "<f-args>"}))
      nvim.ex.command_("-nargs=1 -buffer ConjurePiggieback", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "piggieback", {args = "<f-args>"}))
      nvim.ex.command_("-nargs=0 -buffer ConjureOutSubscribe", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "out-subscribe", {}))
      nvim.ex.command_("-nargs=0 -buffer ConjureOutUnsubscribe", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "out-unsubscribe", {}))
      return action["passive-ns-require"]()
    end
    v_0_0 = on_filetype0
    _0_0["on-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_load = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function on_load0()
      return action["connect-port-file"]()
    end
    v_0_0 = on_load0
    _0_0["on-load"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["on-load"] = v_0_
  on_load = v_0_
end
return nil