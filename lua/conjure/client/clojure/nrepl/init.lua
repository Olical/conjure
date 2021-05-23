local _2afile_2a = "fnl/conjure/client/clojure/nrepl/init.fnl"
local _0_
do
  local name_0_ = "conjure.client.clojure.nrepl"
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
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_ = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.client.clojure.nrepl.parse"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", action = "conjure.client.clojure.nrepl.action", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", eval = "conjure.eval", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", parse = "conjure.client.clojure.nrepl.parse", server = "conjure.client.clojure.nrepl.server", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local server = _local_0_[10]
local str = _local_0_[11]
local action = _local_0_[2]
local bridge = _local_0_[3]
local client = _local_0_[4]
local config = _local_0_[5]
local eval = _local_0_[6]
local mapping = _local_0_[7]
local nvim = _local_0_[8]
local parse = _local_0_[9]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.client.clojure.nrepl"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_0_
  do
    local v_0_0 = ".cljc"
    _0_["buf-suffix"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix
do
  local v_0_
  do
    local v_0_0 = "; "
    _0_["comment-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
local cfg
do
  local v_0_ = config["get-in-fn"]({"client", "clojure", "nrepl"})
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["cfg"] = v_0_
  cfg = v_0_
end
config.merge({client = {clojure = {nrepl = {completion = {cljs = {use_suitable = true}, with_context = false}, connection = {auto_repl = {cmd = "bb nrepl-server localhost:8794", enabled = true, port = "8794", port_file = ".nrepl-port"}, default_host = "localhost", port_files = {".nrepl-port", ".shadow-cljs/nrepl.port"}}, eval = {auto_require = true, pretty_print = true, print_function = "conjure.internal/pprint", print_options = {length = 500, level = 50}, print_quota = nil, raw_out = false}, interrupt = {sample_limit = 0.3}, mapping = {connect_port_file = "cf", disconnect = "cd", interrupt = "ei", last_exception = "ve", refresh_all = "ra", refresh_changed = "rr", refresh_clear = "rc", result_1 = "v1", result_2 = "v2", result_3 = "v3", run_all_tests = "ta", run_alternate_ns_tests = "tN", run_current_ns_tests = "tn", run_current_test = "tc", session_clone = "sc", session_close = "sq", session_close_all = "sQ", session_fresh = "sf", session_list = "sl", session_next = "sn", session_prev = "sp", session_select = "ss", view_source = "vs"}, refresh = {after = nil, before = nil, dirs = nil}, test = {call_suffix = nil, current_form_names = {"deftest"}, runner = "clojure"}}}}})
local context
do
  local v_0_
  do
    local v_0_0
    local function context0(header)
      local _2_ = header
      if _2_ then
        local _3_ = parse["strip-meta"](_2_)
        if _3_ then
          local _4_ = parse["strip-comments"](_3_)
          if _4_ then
            local _5_ = string.match(_4_, "%(%s*ns%s+([^)]*)")
            if _5_ then
              local _6_ = str.split(_5_, "%s+")
              if _6_ then
                return a.first(_6_)
              else
                return _6_
              end
            else
              return _5_
            end
          else
            return _4_
          end
        else
          return _3_
        end
      else
        return _2_
      end
    end
    v_0_0 = context0
    _0_["context"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["context"] = v_0_
  context = v_0_
end
local eval_file
do
  local v_0_
  do
    local v_0_0
    local function eval_file0(opts)
      return action["eval-file"](opts)
    end
    v_0_0 = eval_file0
    _0_["eval-file"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["eval-file"] = v_0_
  eval_file = v_0_
end
local eval_str
do
  local v_0_
  do
    local v_0_0
    local function eval_str0(opts)
      return action["eval-str"](opts)
    end
    v_0_0 = eval_str0
    _0_["eval-str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str
do
  local v_0_
  do
    local v_0_0
    local function doc_str0(opts)
      return action["doc-str"](opts)
    end
    v_0_0 = doc_str0
    _0_["doc-str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["doc-str"] = v_0_
  doc_str = v_0_
end
local def_str
do
  local v_0_
  do
    local v_0_0
    local function def_str0(opts)
      return action["def-str"](opts)
    end
    v_0_0 = def_str0
    _0_["def-str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["def-str"] = v_0_
  def_str = v_0_
end
local completions
do
  local v_0_
  do
    local v_0_0
    local function completions0(opts)
      return action.completions(opts)
    end
    v_0_0 = completions0
    _0_["completions"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["completions"] = v_0_
  completions = v_0_
end
local connect
do
  local v_0_
  do
    local v_0_0
    local function connect0(opts)
      return action["connect-host-port"](opts)
    end
    v_0_0 = connect0
    _0_["connect"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["connect"] = v_0_
  connect = v_0_
end
local on_filetype
do
  local v_0_
  do
    local v_0_0
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
      mapping.buf("n", "CljRunCurrentTest", cfg({"mapping", "run_current_test"}), "conjure.client.clojure.nrepl.action", "run-current-test")
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
    _0_["on-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_load
do
  local v_0_
  do
    local v_0_0
    local function on_load0()
      return action["connect-port-file"]()
    end
    v_0_0 = on_load0
    _0_["on-load"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-load"] = v_0_
  on_load = v_0_
end
local on_exit
do
  local v_0_
  do
    local v_0_0
    local function on_exit0()
      action["delete-auto-repl-port-file"]()
      return server.disconnect()
    end
    v_0_0 = on_exit0
    _0_["on-exit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-exit"] = v_0_
  on_exit = v_0_
end
return nil