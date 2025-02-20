-- [nfnl] Compiled from fnl/conjure/client/clojure/nrepl/action.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local auto_repl = autoload("conjure.client.clojure.nrepl.auto-repl")
local config = autoload("conjure.config")
local editor = autoload("conjure.editor")
local extract = autoload("conjure.extract")
local fs = autoload("conjure.fs")
local hook = autoload("conjure.hook")
local ll = autoload("conjure.linked-list")
local log = autoload("conjure.log")
local nrepl = autoload("conjure.remote.nrepl")
local nvim = autoload("conjure.aniseed.nvim")
local parse = autoload("conjure.client.clojure.nrepl.parse")
local server = autoload("conjure.client.clojure.nrepl.server")
local str = autoload("conjure.aniseed.string")
local text = autoload("conjure.text")
local ui = autoload("conjure.client.clojure.nrepl.ui")
local view = autoload("conjure.aniseed.view")
local function require_ns(ns)
  if ns then
    local function _2_()
    end
    return server.eval({code = ("(require '" .. ns .. ")")}, _2_)
  else
    return nil
  end
end
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
local function passive_ns_require()
  if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
    return require_ns(extract.context())
  else
    return nil
  end
end
local function connect_port_file(opts)
  local resolved_path
  do
    local tmp_6_auto = cfg({"connection", "port_files"})
    if (tmp_6_auto ~= nil) then
      resolved_path = fs["resolve-above"](tmp_6_auto)
    else
      resolved_path = nil
    end
  end
  local resolved
  if resolved_path then
    local port = a.slurp(resolved_path)
    if port then
      resolved = {path = resolved_path, port = tonumber(port)}
    else
      resolved = nil
    end
  else
    resolved = nil
  end
  if resolved then
    local _9_
    do
      local t_8_ = resolved
      if (nil ~= t_8_) then
        t_8_ = t_8_.path
      else
      end
      _9_ = t_8_
    end
    local _12_
    do
      local t_11_ = resolved
      if (nil ~= t_11_) then
        t_11_ = t_11_.port
      else
      end
      _12_ = t_11_
    end
    local function _14_()
      do
        local cb = a.get(opts, "cb")
        if cb then
          cb()
        else
        end
      end
      return passive_ns_require()
    end
    return server.connect({host = cfg({"connection", "default_host"}), port_file_path = _9_, port = _12_, cb = _14_, ["connect-opts"] = a.get(opts, "connect-opts")})
  else
    if not a.get(opts, "silent?") then
      log.append({"; No nREPL port file found"}, {["break?"] = true})
      return auto_repl["upsert-auto-repl-proc"]()
    else
      return nil
    end
  end
end
local function _18_(cb)
  return connect_port_file({["silent?"] = true, cb = cb})
end
hook.define("client-clojure-nrepl-passive-connect", _18_)
local function try_ensure_conn(cb)
  if not server["connected?"]() then
    return hook.exec("client-clojure-nrepl-passive-connect", cb)
  else
    if cb then
      return cb()
    else
      return nil
    end
  end
end
local function connect_host_port(opts)
  if (not opts.host and not opts.port) then
    return connect_port_file()
  else
    local parsed_port
    if ("string" == type(opts.port)) then
      parsed_port = tonumber(opts.port)
    else
      parsed_port = nil
    end
    if parsed_port then
      return server.connect({host = (opts.host or cfg({"connection", "default_host"})), port = parsed_port, cb = passive_ns_require})
    else
      return log.append({str.join({"; Could not parse '", (opts.port or "nil"), "' as a port number"})})
    end
  end
end
local function eval_cb_fn(opts)
  local function _24_(resp)
    if (a.get(opts, "on-result") and a.get(resp, "value")) then
      opts["on-result"](resp.value)
    else
    end
    local cb = a.get(opts, "cb")
    if cb then
      return cb(resp)
    else
      if not opts["passive?"] then
        return ui["display-result"](resp, opts)
      else
        return nil
      end
    end
  end
  return _24_
end
local function eval_str(opts)
  local function _28_()
    local function _29_(conn)
      if (opts.context and not a["get-in"](conn, {"seen-ns", opts.context})) then
        local function _30_()
        end
        server.eval({code = ("(ns " .. opts.context .. ")")}, _30_)
        a["assoc-in"](conn, {"seen-ns", opts.context}, true)
      else
      end
      return server.eval(opts, eval_cb_fn(opts))
    end
    return server["with-conn-or-warn"](_29_)
  end
  return try_ensure_conn(_28_)
end
local function with_info(opts, f)
  local function _32_(conn, ops)
    local _33_
    if ops.info then
      _33_ = {op = "info", ns = (opts.context or "user"), symbol = opts.code, session = conn.session}
    elseif ops.lookup then
      _33_ = {op = "lookup", ns = (opts.context or "user"), sym = opts.code, session = conn.session}
    else
      _33_ = nil
    end
    local function _35_(msg)
      local function _36_()
        if not msg.status["no-info"] then
          return (msg.info or msg)
        else
          return nil
        end
      end
      return f(_36_())
    end
    return server.send(_33_, _35_)
  end
  return server["with-conn-and-ops-or-warn"]({"info", "lookup"}, _32_)
end
local function java_info__3elines(_37_)
  local arglists_str = _37_["arglists-str"]
  local class = _37_["class"]
  local member = _37_["member"]
  local javadoc = _37_["javadoc"]
  local function _38_()
    if member then
      return {"/", member}
    else
      return nil
    end
  end
  local _39_
  if not a["empty?"](arglists_str) then
    _39_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
  else
    _39_ = nil
  end
  local function _41_()
    if javadoc then
      return {("; " .. javadoc)}
    else
      return nil
    end
  end
  return a.concat({str.join(a.concat({"; ", class}, _38_()))}, _39_, _41_())
end
local function doc_str(opts)
  local function _42_()
    require_ns("clojure.repl")
    local function _43_(msgs)
      local function _44_(msg)
        return (a.get(msg, "out") or a.get(msg, "err"))
      end
      if a.some(_44_, msgs) then
        local function _45_(_241)
          return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true})
        end
        return a["run!"](_45_, msgs)
      else
        log.append({"; No results for (doc ...), checking nREPL info ops"})
        local function _46_(info)
          if a["nil?"](info) then
            return log.append({"; No information found, all I can do is wish you good luck and point you to https://duckduckgo.com/"})
          elseif ("string" == type(info.javadoc)) then
            return log.append(java_info__3elines(info))
          elseif ("string" == type(info.doc)) then
            return log.append(a.concat({str.join({"; ", info.ns, "/", info.name}), str.join({"; ", info["arglists-str"]})}, text["prefixed-lines"](info.doc, "; ")))
          else
            return log.append(a.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](view.serialise(info), "; ")))
          end
        end
        return with_info(opts, _46_)
      end
    end
    return server.eval(a.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_43_))
  end
  return try_ensure_conn(_42_)
end
local function nrepl__3envim_path(path)
  if text["starts-with"](path, "jar:file:") then
    local function _49_(zip, file)
      if (tonumber(string.sub(nvim.g.loaded_zipPlugin, 2)) > 31) then
        return ("zipfile://" .. zip .. "::" .. file)
      else
        return ("zipfile:" .. zip .. "::" .. file)
      end
    end
    return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _49_)
  elseif text["starts-with"](path, "file:") then
    local function _51_(file)
      return file
    end
    return string.gsub(path, "^file:(.+)$", _51_)
  else
    return path
  end
end
local function def_str(opts)
  local function _53_()
    local function _54_(info)
      if a["nil?"](info) then
        return log.append({"; No definition information found"})
      elseif info.candidates then
        local function _55_(_241)
          return (_241 .. "/" .. opts.code)
        end
        return log.append(a.concat({"; Multiple candidates found"}, a.map(_55_, a.keys(info.candidates))))
      elseif (info.file and info.line) then
        local column = (info.column or 1)
        local path = nrepl__3envim_path(info.file)
        editor["go-to"](path, info.line, column)
        return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
      elseif info.javadoc then
        return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
      elseif info["special-form"] then
        local function _56_()
          if info.url then
            return ("; " .. info.url)
          else
            return nil
          end
        end
        return log.append({"; Can't open source, it's a special form", _56_()})
      else
        return log.append({"; Unsupported target", ("; " .. a["pr-str"](info))})
      end
    end
    return with_info(opts, _54_)
  end
  return try_ensure_conn(_53_)
end
local function escape_backslashes(s)
  return s:gsub("\\", "\\\\")
end
local function eval_file(opts)
  local function _58_()
    local function _59_(conn)
      return server["load-file"](a.assoc(opts, "code", a.slurp(opts["file-path"])), eval_cb_fn(opts))
    end
    return server["with-conn-or-warn"](_59_)
  end
  return try_ensure_conn(_58_)
end
local function interrupt()
  local function _60_()
    local function _61_(conn)
      local msgs
      local function _62_(msg)
        return ("eval" == msg.msg.op)
      end
      msgs = a.filter(_62_, a.vals(conn.msgs))
      local order_66
      local function _64_(_63_)
        local id = _63_["id"]
        local session = _63_["session"]
        local code = _63_["code"]
        server.send({op = "interrupt", ["interrupt-id"] = id, session = session})
        local function _65_(sess)
          local _66_
          if code then
            _66_ = text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
          else
            _66_ = ("session: " .. sess.str() .. "")
          end
          return log.append({("; Interrupted: " .. _66_)}, {["break?"] = true})
        end
        return server["enrich-session-id"](session, _65_)
      end
      order_66 = _64_
      if a["empty?"](msgs) then
        return order_66({session = conn.session})
      else
        local function _68_(a0, b)
          return (a0["sent-at"] < b["sent-at"])
        end
        table.sort(msgs, _68_)
        return order_66(a.get(a.first(msgs), "msg"))
      end
    end
    return server["with-conn-or-warn"](_61_)
  end
  return try_ensure_conn(_60_)
end
local function eval_str_fn(code)
  local function _70_()
    return nvim.ex.ConjureEval(code)
  end
  return _70_
end
local last_exception = eval_str_fn("*e")
local result_1 = eval_str_fn("*1")
local result_2 = eval_str_fn("*2")
local result_3 = eval_str_fn("*3")
local view_tap = eval_str_fn("(conjure.internal/dump-tap-queue!)")
local function view_source()
  local function _71_()
    local word = a.get(extract.word(), "content")
    if not a["empty?"](word) then
      log.append({("; source (word): " .. word)}, {["break?"] = true})
      require_ns("clojure.repl")
      local function _72_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return eval_str({code = ("(clojure.repl/source " .. word .. ")"), context = extract.context(), cb = _72_})
    else
      return nil
    end
  end
  return try_ensure_conn(_71_)
end
local function eval_macro_expand(expander)
  local function _74_()
    local form = a.get(extract.form({}), "content")
    if not a["empty?"](form) then
      log.append({("; " .. expander .. " (form): " .. form)}, {["break?"] = true})
      local _75_
      if ("clojure.walk/macroexpand-all" == expander) then
        _75_ = "(require 'clojure.walk) "
      else
        _75_ = ""
      end
      local function _77_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return eval_str({code = (_75_ .. "(" .. expander .. " '" .. form .. ")"), context = extract.context(), cb = _77_})
    else
      return nil
    end
  end
  return try_ensure_conn(_74_)
end
local function macro_expand_1()
  return eval_macro_expand("macroexpand-1")
end
local function macro_expand()
  return eval_macro_expand("macroexpand")
end
local function macro_expand_all()
  return eval_macro_expand("clojure.walk/macroexpand-all")
end
local function clone_current_session()
  local function _79_()
    local function _80_(conn)
      return server["enrich-session-id"](a.get(conn, "session"), server["clone-session"])
    end
    return server["with-conn-or-warn"](_80_)
  end
  return try_ensure_conn(_79_)
end
local function clone_fresh_session()
  local function _81_()
    local function _82_(conn)
      return server["clone-session"]()
    end
    return server["with-conn-or-warn"](_82_)
  end
  return try_ensure_conn(_81_)
end
local function close_current_session()
  local function _83_()
    local function _84_(conn)
      local function _85_(sess)
        a.assoc(conn, "session", nil)
        log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
        local function _86_()
          return server["assume-or-create-session"]()
        end
        return server["close-session"](sess, _86_)
      end
      return server["enrich-session-id"](a.get(conn, "session"), _85_)
    end
    return server["with-conn-or-warn"](_84_)
  end
  return try_ensure_conn(_83_)
end
local function display_sessions(cb)
  local function _87_()
    local function _88_(sessions)
      return ui["display-sessions"](sessions, cb)
    end
    return server["with-sessions"](_88_)
  end
  return try_ensure_conn(_87_)
end
local function close_all_sessions()
  local function _89_()
    local function _90_(sessions)
      a["run!"](server["close-session"], sessions)
      log.append({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
      return server["clone-session"]()
    end
    return server["with-sessions"](_90_)
  end
  return try_ensure_conn(_89_)
end
local function cycle_session(f)
  local function _91_()
    local function _92_(conn)
      local function _93_(sessions)
        if (1 == a.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
        else
          local session = a.get(conn, "session")
          local function _94_(_241)
            return f(session, _241)
          end
          return server["assume-session"](ll.val(ll["until"](_94_, ll.cycle(ll.create(sessions)))))
        end
      end
      return server["with-sessions"](_93_)
    end
    return server["with-conn-or-warn"](_92_)
  end
  return try_ensure_conn(_91_)
end
local function next_session()
  local function _96_(current, node)
    return (current == a.get(ll.val(ll.prev(node)), "id"))
  end
  return cycle_session(_96_)
end
local function prev_session()
  local function _97_(current, node)
    return (current == a.get(ll.val(ll.next(node)), "id"))
  end
  return cycle_session(_97_)
end
local function select_session_interactive()
  local function _98_()
    local function _99_(sessions)
      if (1 == a.count(sessions)) then
        return log.append({"; No other sessions"}, {["break?"] = true})
      else
        local function _100_()
          nvim.ex.redraw_()
          local n = nvim.fn.str2nr(extract.prompt("Session number: "))
          if ((1 <= n) and (n <= a.count(sessions))) then
            return server["assume-session"](a.get(sessions, n))
          else
            return log.append({"; Invalid session number."})
          end
        end
        return ui["display-sessions"](sessions, _100_)
      end
    end
    return server["with-sessions"](_99_)
  end
  return try_ensure_conn(_98_)
end
local test_runners = {clojure = {namespace = "clojure.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, clojurescript = {namespace = "cljs.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, kaocha = {namespace = "kaocha.repl", ["all-fn"] = "run-all", ["ns-fn"] = "run", ["single-fn"] = "run", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = ""}}
local function test_cfg(k)
  local runner = cfg({"test", "runner"})
  return (a["get-in"](test_runners, {runner, k}) or error(str.join({"No test-runners configuration for ", runner, " / ", k})))
end
local function require_test_runner()
  return require_ns(test_cfg("namespace"))
end
local function test_runner_code(fn_config_name, ...)
  return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
end
local function run_all_tests()
  local function _103_()
    log.append({"; run-all-tests"}, {["break?"] = true})
    require_test_runner()
    local function _104_(_241)
      return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
    end
    return server.eval({code = test_runner_code("all")}, _104_)
  end
  return try_ensure_conn(_103_)
end
local function run_ns_tests(ns)
  local function _105_()
    if ns then
      log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      require_test_runner()
      local function _106_(_241)
        return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
      end
      return server.eval({code = test_runner_code("ns", ("'" .. ns))}, _106_)
    else
      return nil
    end
  end
  return try_ensure_conn(_105_)
end
local function run_current_ns_tests()
  return run_ns_tests(extract.context())
end
local function run_alternate_ns_tests()
  local current_ns = extract.context()
  local function _108_()
    if text["ends-with"](current_ns, "-test") then
      return current_ns
    else
      return (current_ns .. "-test")
    end
  end
  return run_ns_tests(_108_())
end
local function extract_test_name_from_form(form)
  local seen_deftest_3f = false
  local function _109_(part)
    local function _110_(config_current_form_name)
      return text["ends-with"](part, config_current_form_name)
    end
    if a.some(_110_, cfg({"test", "current_form_names"})) then
      seen_deftest_3f = true
      return false
    elseif seen_deftest_3f then
      return part
    else
      return nil
    end
  end
  return a.some(_109_, str.split(parse["strip-meta"](form), "%s+"))
end
local function run_current_test()
  local function _112_()
    local form = extract.form({["root?"] = true})
    if form then
      local test_name = extract_test_name_from_form(form.content)
      if test_name then
        log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
        require_test_runner()
        local function _113_(msgs)
          if ((2 == a.count(msgs)) and ("nil" == a.get(a.first(msgs), "value"))) then
            return log.append({"; Success!"})
          else
            local function _114_(_241)
              return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
            end
            return a["run!"](_114_, msgs)
          end
        end
        return server.eval({code = test_runner_code("single", (test_cfg("name-prefix") .. test_name .. test_cfg("name-suffix"))), context = extract.context()}, nrepl["with-all-msgs-fn"](_113_))
      else
        return nil
      end
    else
      return nil
    end
  end
  return try_ensure_conn(_112_)
end
local function refresh_impl(op)
  local function _118_(conn)
    local function _119_(msg)
      if msg.reloading then
        return log.append(msg.reloading)
      elseif msg.error then
        return log.append({str.join(" ", {"; Error while reloading", msg["error-ns"]})})
      elseif msg.status.ok then
        return log.append({"; Refresh complete"})
      elseif msg.status.done then
        return nil
      else
        return ui["display-result"](msg)
      end
    end
    return server.send(a.merge({op = op, session = conn.session, after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"})}), _119_)
  end
  return server["with-conn-and-ops-or-warn"]({op}, _118_)
end
local function use_clj_reload_backend_3f()
  return (cfg({"refresh", "backend"}) == "clj-reload")
end
local function refresh_changed()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _121_()
    local _122_
    if use_clj_reload_3f then
      _122_ = "clj-reload"
    else
      _122_ = "tools.namespace"
    end
    log.append({str.join({"; Refreshing changed namespaces using '", _122_, "'"})}, {["break?"] = true})
    local function _124_()
      if use_clj_reload_3f then
        return "cider.clj-reload/reload"
      else
        return "refresh"
      end
    end
    return refresh_impl(_124_())
  end
  return try_ensure_conn(_121_)
end
local function refresh_all()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _125_()
    local _126_
    if use_clj_reload_3f then
      _126_ = "clj-reload"
    else
      _126_ = "tools.namespace"
    end
    log.append({str.join({"; Refreshing all namespaces using '", _126_, "'"})}, {["break?"] = true})
    local function _128_()
      if use_clj_reload_3f then
        return "cider.clj-reload/reload-all"
      else
        return "refresh-all"
      end
    end
    return refresh_impl(_128_())
  end
  return try_ensure_conn(_125_)
end
local function refresh_clear()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _129_()
    local _130_
    if use_clj_reload_3f then
      _130_ = "clj-reload"
    else
      _130_ = "tools.namespace"
    end
    log.append({str.join({"; Clearning reload cache using '", _130_, "'"})}, {["break?"] = true})
    local function _132_(conn)
      local _133_
      if use_clj_reload_3f then
        _133_ = "cider.clj-reload/reload-clear"
      else
        _133_ = "refresh-clear"
      end
      local function _135_(msgs)
        return log.append({"; Clearing complete"})
      end
      return server.send({op = _133_, session = conn.session}, nrepl["with-all-msgs-fn"](_135_))
    end
    return server["with-conn-and-ops-or-warn"]({"refresh-clear"}, _132_)
  end
  return try_ensure_conn(_129_)
end
local function shadow_select(build)
  local function _136_()
    local function _137_(conn)
      log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
      server.eval({code = ("#?(:clj (shadow.cljs.devtools.api/nrepl-select :" .. build .. ") :cljs :already-selected)")}, ui["display-result"])
      return passive_ns_require()
    end
    return server["with-conn-or-warn"](_137_)
  end
  return try_ensure_conn(_136_)
end
local function piggieback(code)
  local function _138_()
    local function _139_(conn)
      log.append({("; piggieback: " .. code)}, {["break?"] = true})
      require_ns("cider.piggieback")
      server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
      return passive_ns_require()
    end
    return server["with-conn-or-warn"](_139_)
  end
  return try_ensure_conn(_138_)
end
local function clojure__3evim_completion(_140_)
  local word = _140_["candidate"]
  local kind = _140_["type"]
  local ns = _140_["ns"]
  local info = _140_["doc"]
  local arglists = _140_["arglists"]
  local function _141_()
    if arglists then
      return str.join(" ", arglists)
    else
      return nil
    end
  end
  local _142_
  if ("string" == type(info)) then
    _142_ = info
  else
    _142_ = nil
  end
  local _144_
  if not a["empty?"](kind) then
    _144_ = string.upper(string.sub(kind, 1, 1))
  else
    _144_ = nil
  end
  return {word = word, menu = str.join(" ", {ns, _141_()}), info = _142_, kind = _144_}
end
local function extract_completion_context(prefix)
  local root_form = extract.form({["root?"] = true})
  if root_form then
    local content = root_form["content"]
    local range = root_form["range"]
    local lines = text["split-lines"](content)
    local _let_146_ = nvim.win_get_cursor(0)
    local row = _let_146_[1]
    local col = _let_146_[2]
    local lrow = (row - a["get-in"](range, {"start", 1}))
    local line_index = a.inc(lrow)
    local lcol
    if (lrow == 0) then
      lcol = (col - a["get-in"](range, {"start", 2}))
    else
      lcol = col
    end
    local original = a.get(lines, line_index)
    local spliced = (string.sub(original, 1, lcol) .. "__prefix__" .. string.sub(original, a.inc(lcol)))
    return str.join("\n", a.assoc(lines, line_index, spliced))
  else
    return nil
  end
end
local function enhanced_cljs_completion_3f()
  return cfg({"completion", "cljs", "use_suitable"})
end
local function completions(opts)
  local function _149_(conn, ops)
    local _150_
    if ops.complete then
      local _151_
      if cfg({"completion", "with_context"}) then
        _151_ = extract_completion_context(opts.prefix)
      else
        _151_ = nil
      end
      local _153_
      if enhanced_cljs_completion_3f() then
        _153_ = "t"
      else
        _153_ = nil
      end
      _150_ = {op = "complete", session = conn.session, ns = opts.context, symbol = opts.prefix, context = _151_, ["extra-metadata"] = {"arglists", "doc"}, ["enhanced-cljs-completion?"] = _153_}
    elseif ops.completions then
      _150_ = {op = "completions", session = conn.session, ns = opts.context, prefix = opts.prefix}
    else
      _150_ = nil
    end
    local function _156_(msgs)
      return opts.cb(a.map(clojure__3evim_completion, a.get(a.last(msgs), "completions")))
    end
    return server.send(_150_, nrepl["with-all-msgs-fn"](_156_))
  end
  return server["with-conn-and-ops-or-warn"]({"complete", "completions"}, _149_, {["silent?"] = true, ["else"] = opts.cb})
end
local function out_subscribe()
  try_ensure_conn()
  log.append({"; Subscribing to out"}, {["break?"] = true})
  local function _157_(conn)
    return server.send({op = "out-subscribe"})
  end
  return server["with-conn-and-ops-or-warn"]({"out-subscribe"}, _157_)
end
local function out_unsubscribe()
  try_ensure_conn()
  log.append({"; Unsubscribing from out"}, {["break?"] = true})
  local function _158_(conn)
    return server.send({op = "out-unsubscribe"})
  end
  return server["with-conn-and-ops-or-warn"]({"out-unsubscribe"}, _158_)
end
return {["clone-current-session"] = clone_current_session, ["clone-fresh-session"] = clone_fresh_session, ["close-all-sessions"] = close_all_sessions, ["close-current-session"] = close_current_session, completions = completions, ["connect-host-port"] = connect_host_port, ["connect-port-file"] = connect_port_file, ["def-str"] = def_str, ["display-sessions"] = display_sessions, ["doc-str"] = doc_str, ["escape-backslashes"] = escape_backslashes, ["eval-file"] = eval_file, ["eval-str"] = eval_str, ["extract-test-name-from-form"] = extract_test_name_from_form, interrupt = interrupt, ["last-exception"] = last_exception, ["next-session"] = next_session, ["out-subscribe"] = out_subscribe, ["out-unsubscribe"] = out_unsubscribe, ["passive-ns-require"] = passive_ns_require, piggieback = piggieback, ["prev-session"] = prev_session, ["refresh-all"] = refresh_all, ["refresh-changed"] = refresh_changed, ["refresh-clear"] = refresh_clear, ["result-1"] = result_1, ["result-2"] = result_2, ["result-3"] = result_3, ["run-all-tests"] = run_all_tests, ["run-alternate-ns-tests"] = run_alternate_ns_tests, ["run-current-ns-tests"] = run_current_ns_tests, ["run-current-test"] = run_current_test, ["select-session-interactive"] = select_session_interactive, ["shadow-select"] = shadow_select, ["test-runners"] = test_runners, ["view-source"] = view_source, ["view-tap"] = view_tap, ["macro-expand-1"] = macro_expand_1, ["macro-expand"] = macro_expand, ["macro-expand-all"] = macro_expand_all}
