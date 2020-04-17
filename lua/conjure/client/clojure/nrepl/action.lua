local _0_0 = nil
do
  local name_23_0_ = "conjure.client.clojure.nrepl.action"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.client.clojure.nrepl.config", editor = "conjure.editor", eval = "conjure.aniseed.eval", extract = "conjure.extract", ll = "conjure.linked-list", nvim = "conjure.aniseed.nvim", server = "conjure.client.clojure.nrepl.server", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text", ui = "conjure.client.clojure.nrepl.ui"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.client.clojure.nrepl.config"), require("conjure.editor"), require("conjure.aniseed.eval"), require("conjure.extract"), require("conjure.linked-list"), require("conjure.aniseed.nvim"), require("conjure.client.clojure.nrepl.server"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.client.clojure.nrepl.ui")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local config = _2_[3]
local editor = _2_[4]
local eval = _2_[5]
local extract = _2_[6]
local ll = _2_[7]
local nvim = _2_[8]
local server = _2_[9]
local state = _2_[10]
local str = _2_[11]
local text = _2_[12]
local ui = _2_[13]
do local _ = ({nil, _0_0, nil})[2] end
local display_session_type = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_session_type0()
      local function _3_(msgs)
        return ui.display({("; Session type: " .. a.get(a.first(msgs), "value"))}, {["break?"] = true})
      end
      return server.eval({code = ("#?(" .. str.join(" ", {":clj 'Clojure", ":cljs 'ClojureScript", ":cljr 'ClojureCLR", ":default 'Unknown"}) .. ")")}, server["with-all-msgs-fn"](_3_))
    end
    v_23_0_0 = display_session_type0
    _0_0["display-session-type"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-session-type"] = v_23_0_
  display_session_type = v_23_0_
end
local connect_port_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect_port_file0()
      local port = nil
      do
        local _3_0 = a.some(a.slurp, {".nrepl-port", ".shadow-cljs/nrepl.port"})
        if _3_0 then
          port = tonumber(_3_0)
        else
          port = _3_0
        end
      end
      if port then
        return server.connect({host = config.connection["default-host"], port = port})
      else
        return ui.display({"; No nREPL port file found"}, {["break?"] = true})
      end
    end
    v_23_0_0 = connect_port_file0
    _0_0["connect-port-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect-port-file"] = v_23_0_
  connect_port_file = v_23_0_
end
local connect_host_port = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect_host_port0(...)
      local args = {...}
      local _3_
      if (1 == a.count(args)) then
        _3_ = config.connection["default-host"]
      else
        _3_ = a.first(args)
      end
      return server.connect({host = _3_, port = tonumber(a.last(args))})
    end
    v_23_0_0 = connect_host_port0
    _0_0["connect-host-port"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect-host-port"] = v_23_0_
  connect_host_port = v_23_0_
end
local eval_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_str0(opts)
      local function _3_(_)
        do
          local context = a.get(opts, "context")
          local _4_
          if context then
            _4_ = ("(in-ns '" .. context .. ")")
          else
            _4_ = "(in-ns #?(:clj 'user, :cljs 'cljs.user))"
          end
          local function _6_()
          end
          server.eval({code = _4_}, _6_)
        end
        local function _4_(_241)
          return ui["display-result"](_241, opts)
        end
        return server.eval(opts, (opts.cb or _4_))
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = eval_str0
    _0_0["eval-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_23_0_
  eval_str = v_23_0_
end
local doc_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function doc_str0(opts)
      local function _3_(_241)
        return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
      end
      return eval_str(a.merge(opts, {cb = _3_, code = ("(do (require 'clojure.repl)" .. "    (clojure.repl/doc " .. opts.code .. "))")}))
    end
    v_23_0_0 = doc_str0
    _0_0["doc-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_23_0_
  doc_str = v_23_0_
end
local jar__3ezip = nil
do
  local v_23_0_ = nil
  local function jar__3ezip0(path)
    if text["starts-with"](path, "jar:file:") then
      local function _3_(zip, file)
        return ("zipfile:" .. zip .. "::" .. file)
      end
      return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _3_)
    else
      return path
    end
  end
  v_23_0_ = jar__3ezip0
  _0_0["aniseed/locals"]["jar->zip"] = v_23_0_
  jar__3ezip = v_23_0_
end
local def_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function def_str0(opts)
      local function _3_(msgs)
        local val = a.get(a.first(msgs), "value")
        local ok_3f, res = nil, nil
        if val then
          ok_3f, res = eval.str(val)
        else
        ok_3f, res = nil
        end
        if ok_3f then
          local _5_ = res
          local path = _5_[1]
          local line = _5_[2]
          local column = _5_[3]
          return editor["go-to"](jar__3ezip(path), line, column)
        else
          return ui.display({"; Couldn't find definition."})
        end
      end
      return eval_str(a.merge(opts, {cb = server["with-all-msgs-fn"](_3_), code = ("(mapv #(% (meta #'" .. opts.code .. "))\n      [(comp #(.toString %)\n      (some-fn (comp #?(:clj clojure.java.io/resource :cljs identity)\n      :file) :file))\n      :line :column])")}))
    end
    v_23_0_0 = def_str0
    _0_0["def-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["def-str"] = v_23_0_
  def_str = v_23_0_
end
local eval_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_file0(opts)
      local function _3_(_241)
        return ui["display-result"](_241, opts)
      end
      return server.eval(a.assoc(opts, "code", ("(load-file \"" .. opts["file-path"] .. "\")")), _3_)
    end
    v_23_0_0 = eval_file0
    _0_0["eval-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_23_0_
  eval_file = v_23_0_
end
local interrupt = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function interrupt0()
      local function _3_(conn)
        local msgs = nil
        local function _4_(msg)
          return ("eval" == msg.msg.op)
        end
        msgs = a.filter(_4_, a.vals(conn.msgs))
        if a["empty?"](msgs) then
          return ui.display({"; Nothing to interrupt"}, {["break?"] = true})
        else
          local function _5_(a0, b)
            return (a0["sent-at"] < b["sent-at"])
          end
          table.sort(msgs, _5_)
          do
            local oldest = a.first(msgs)
            server.send({id = oldest.msg.id, op = "interrupt", session = oldest.msg.session})
            return ui.display({("; Interrupted: " .. text["left-sample"](oldest.msg.code, editor["percent-width"](config.interrupt["sample-limit"])))}, {["break?"] = true})
          end
        end
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = interrupt0
    _0_0["interrupt"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["interrupt"] = v_23_0_
  interrupt = v_23_0_
end
local eval_str_fn = nil
do
  local v_23_0_ = nil
  local function eval_str_fn0(code)
    local function _3_()
      return nvim.ex.ConjureEval(code)
    end
    return _3_
  end
  v_23_0_ = eval_str_fn0
  _0_0["aniseed/locals"]["eval-str-fn"] = v_23_0_
  eval_str_fn = v_23_0_
end
local last_exception = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*e")
    _0_0["last-exception"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["last-exception"] = v_23_0_
  last_exception = v_23_0_
end
local result_1 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*1")
    _0_0["result-1"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["result-1"] = v_23_0_
  result_1 = v_23_0_
end
local result_2 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*2")
    _0_0["result-2"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["result-2"] = v_23_0_
  result_2 = v_23_0_
end
local result_3 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*3")
    _0_0["result-3"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["result-3"] = v_23_0_
  result_3 = v_23_0_
end
local view_source = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function view_source0()
      local word = a.get(extract.word(), "content")
      if not a["empty?"](word) then
        ui.display({("; source (word): " .. word)}, {["break?"] = true})
        local function _3_(_241)
          return ui["display-result"](_241, {["ignore-nil?"] = true, ["raw-out?"] = true})
        end
        return eval_str({cb = _3_, code = ("(do (require 'clojure.repl)" .. "(clojure.repl/source " .. word .. "))"), context = extract.context()})
      end
    end
    v_23_0_0 = view_source0
    _0_0["view-source"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["view-source"] = v_23_0_
  view_source = v_23_0_
end
local clone_current_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function clone_current_session0()
      local function _3_(conn)
        return server["clone-session"](a.get(conn, "session"))
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = clone_current_session0
    _0_0["clone-current-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["clone-current-session"] = v_23_0_
  clone_current_session = v_23_0_
end
local clone_fresh_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function clone_fresh_session0()
      local function _3_(conn)
        return server["clone-session"]()
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = clone_fresh_session0
    _0_0["clone-fresh-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["clone-fresh-session"] = v_23_0_
  clone_fresh_session = v_23_0_
end
local close_current_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function close_current_session0()
      local function _3_(conn)
        local session = a.get(conn, "session")
        a.assoc(conn, "session", nil)
        ui.display({("; Closed current session: " .. session)}, {["break?"] = true})
        return server["close-session"](session, server["assume-or-create-session"])
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = close_current_session0
    _0_0["close-current-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-current-session"] = v_23_0_
  close_current_session = v_23_0_
end
local display_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_sessions0(cb)
      local function _3_(sessions)
        return ui["display-given-sessions"](sessions, cb)
      end
      return server["with-sessions"](_3_)
    end
    v_23_0_0 = display_sessions0
    _0_0["display-sessions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-sessions"] = v_23_0_
  display_sessions = v_23_0_
end
local close_all_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function close_all_sessions0()
      local function _3_(sessions)
        a["run!"](server["close-session"], sessions)
        ui.display({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
        return server["clone-session"]()
      end
      return server["with-sessions"](_3_)
    end
    v_23_0_0 = close_all_sessions0
    _0_0["close-all-sessions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-all-sessions"] = v_23_0_
  close_all_sessions = v_23_0_
end
local cycle_session = nil
do
  local v_23_0_ = nil
  local function cycle_session0(f)
    local function _3_(conn)
      local function _4_(sessions)
        if (1 == a.count(sessions)) then
          return ui.display({"; No other sessions"}, {["break?"] = true})
        else
          local session = a.get(conn, "session")
          local function _5_(_241)
            return f(session, _241)
          end
          return server["assume-session"](ll.val(ll["until"](_5_, ll.cycle(ll.create(sessions)))))
        end
      end
      return server["with-sessions"](_4_)
    end
    return server["with-conn-or-warn"](_3_)
  end
  v_23_0_ = cycle_session0
  _0_0["aniseed/locals"]["cycle-session"] = v_23_0_
  cycle_session = v_23_0_
end
local next_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function next_session0()
      local function _3_(current, node)
        return (current == ll.val(ll.prev(node)))
      end
      return cycle_session(_3_)
    end
    v_23_0_0 = next_session0
    _0_0["next-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["next-session"] = v_23_0_
  next_session = v_23_0_
end
local prev_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function prev_session0()
      local function _3_(current, node)
        return (current == ll.val(ll.next(node)))
      end
      return cycle_session(_3_)
    end
    v_23_0_0 = prev_session0
    _0_0["prev-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["prev-session"] = v_23_0_
  prev_session = v_23_0_
end
local select_session_interactive = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function select_session_interactive0()
      local function _3_(sessions)
        if (1 == a.count(sessions)) then
          return ui.display({"; No other sessions"}, {["break?"] = true})
        else
          local function _4_()
            nvim.ex.redraw_()
            do
              local n = nvim.fn.str2nr(extract.prompt("Session number: "))
              local _5_ = a.count(sessions)
              if ((1 <= n) and (n <= _5_)) then
                return server["assume-session"](a.get(sessions, n))
              else
                return ui.display({"; Invalid session number."})
              end
            end
          end
          return ui["display-given-sessions"](sessions, _4_)
        end
      end
      return server["with-sessions"](_3_)
    end
    v_23_0_0 = select_session_interactive0
    _0_0["select-session-interactive"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["select-session-interactive"] = v_23_0_
  select_session_interactive = v_23_0_
end
local run_all_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_all_tests0()
      ui.display({"; run-all-tests"}, {["break?"] = true})
      local function _3_(_241)
        return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
      end
      return server.eval({code = "(require 'clojure.test) (clojure.test/run-all-tests)"}, _3_)
    end
    v_23_0_0 = run_all_tests0
    _0_0["run-all-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-all-tests"] = v_23_0_
  run_all_tests = v_23_0_
end
local run_ns_tests = nil
do
  local v_23_0_ = nil
  local function run_ns_tests0(ns)
    if ns then
      ui.display({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      local function _3_(_241)
        return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
      end
      return server.eval({code = ("(require 'clojure.test)" .. "(clojure.test/run-tests '" .. ns .. ")")}, _3_)
    end
  end
  v_23_0_ = run_ns_tests0
  _0_0["aniseed/locals"]["run-ns-tests"] = v_23_0_
  run_ns_tests = v_23_0_
end
local run_current_ns_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_current_ns_tests0()
      return run_ns_tests(extract.context())
    end
    v_23_0_0 = run_current_ns_tests0
    _0_0["run-current-ns-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-current-ns-tests"] = v_23_0_
  run_current_ns_tests = v_23_0_
end
local run_alternate_ns_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_alternate_ns_tests0()
      local current_ns = extract.context()
      local function _3_()
        if text["ends-with"](current_ns, "-test") then
          return string.sub(current_ns, 1, -6)
        else
          return (current_ns .. "-test")
        end
      end
      return run_ns_tests(_3_())
    end
    v_23_0_0 = run_alternate_ns_tests0
    _0_0["run-alternate-ns-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-alternate-ns-tests"] = v_23_0_
  run_alternate_ns_tests = v_23_0_
end
local run_current_test = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_current_test0()
      local form = extract.form({["root?"] = true})
      if form then
        local test_name, sub_count = string.gsub(form.content, ".*deftest%s+(.-)%s+.*", "%1")
        if (not a["empty?"](test_name) and (1 == sub_count)) then
          ui.display({("; run-current-test: " .. test_name)}, {["break?"] = true})
          local function _3_(msgs)
            if ((2 == a.count(msgs)) and ("nil" == a.get(a.first(msgs), "value"))) then
              return ui.display({"; Success!"})
            else
              local function _4_(_241)
                return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
              end
              return a["run!"](_4_, msgs)
            end
          end
          return server.eval({code = ("(do (require 'clojure.test)" .. "(clojure.test/test-var" .. "  (resolve '" .. test_name .. ")))")}, server["with-all-msgs-fn"](_3_))
        end
      end
    end
    v_23_0_0 = run_current_test0
    _0_0["run-current-test"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-current-test"] = v_23_0_
  run_current_test = v_23_0_
end
return nil