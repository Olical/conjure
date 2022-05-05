local _2afile_2a = "fnl/conjure/client/clojure/nrepl/action.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.action"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, client, config, editor, eval, extract, fs, ll, log, nrepl, nvim, parse, process, server, state, str, text, ui, view = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.aniseed.eval"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.linked-list"), autoload("conjure.log"), autoload("conjure.remote.nrepl"), autoload("conjure.aniseed.nvim"), autoload("conjure.client.clojure.nrepl.parse"), autoload("conjure.process"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.client.clojure.nrepl.ui"), autoload("conjure.aniseed.view")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["editor"] = editor
_2amodule_locals_2a["eval"] = eval
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["ll"] = ll
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nrepl"] = nrepl
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["parse"] = parse
_2amodule_locals_2a["process"] = process
_2amodule_locals_2a["server"] = server
_2amodule_locals_2a["state"] = state
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ui"] = ui
_2amodule_locals_2a["view"] = view
local function require_ns(ns)
  if ns then
    local function _1_()
    end
    return server.eval({code = ("(require '" .. ns .. ")")}, _1_)
  else
    return nil
  end
end
_2amodule_locals_2a["require-ns"] = require_ns
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local function passive_ns_require()
  if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
    return require_ns(extract.context())
  else
    return nil
  end
end
_2amodule_2a["passive-ns-require"] = passive_ns_require
local function delete_auto_repl_port_file()
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local port = cfg({"connection", "auto_repl", "port"})
  if (port_file and port and (a.slurp(port_file) == port)) then
    return nvim.fn.delete(port_file)
  else
    return nil
  end
end
_2amodule_2a["delete-auto-repl-port-file"] = delete_auto_repl_port_file
local function upsert_auto_repl_proc()
  local cmd = cfg({"connection", "auto_repl", "cmd"})
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local port = cfg({"connection", "auto_repl", "port"})
  local enabled_3f = cfg({"connection", "auto_repl", "enabled"})
  local hidden_3f = cfg({"connection", "auto_repl", "hidden"})
  if (enabled_3f and not process["running?"](state.get("auto-repl-proc")) and process["executable?"](cmd)) then
    local proc = process.execute(cmd, {["hidden?"] = hidden_3f, ["on-exit"] = client.wrap(delete_auto_repl_port_file)})
    a.assoc(state.get(), "auto-repl-proc", proc)
    if (port_file and port) then
      a.spit(port_file, port)
    else
    end
    log.append({("; Starting auto-repl: " .. cmd)})
    return proc
  else
    return nil
  end
end
_2amodule_locals_2a["upsert-auto-repl-proc"] = upsert_auto_repl_proc
local function connect_port_file(opts)
  local resolved_path
  do
    local _7_ = cfg({"connection", "port_files"})
    if (_7_ ~= nil) then
      resolved_path = fs["resolve-above"](_7_)
    else
      resolved_path = _7_
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
    local _12_
    do
      local t_11_ = resolved
      if (nil ~= t_11_) then
        t_11_ = (t_11_).path
      else
      end
      _12_ = t_11_
    end
    local _15_
    do
      local t_14_ = resolved
      if (nil ~= t_14_) then
        t_14_ = (t_14_).port
      else
      end
      _15_ = t_14_
    end
    local function _17_()
      do
        local cb = a.get(opts, "cb")
        if cb then
          cb()
        else
        end
      end
      return passive_ns_require()
    end
    return server.connect({host = cfg({"connection", "default_host"}), port_file_path = _12_, port = _15_, cb = _17_})
  else
    if not a.get(opts, "silent?") then
      log.append({"; No nREPL port file found"}, {["break?"] = true})
      return upsert_auto_repl_proc()
    else
      return nil
    end
  end
end
_2amodule_2a["connect-port-file"] = connect_port_file
local function try_ensure_conn(cb)
  if not server["connected?"]() then
    return connect_port_file({["silent?"] = true, cb = cb})
  else
    if cb then
      return cb()
    else
      return nil
    end
  end
end
_2amodule_locals_2a["try-ensure-conn"] = try_ensure_conn
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
      return log.append({("; Could not parse '" .. opts.port .. "' as a port number")})
    end
  end
end
_2amodule_2a["connect-host-port"] = connect_host_port
local function eval_cb_fn(opts)
  local function _26_(resp)
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
  return _26_
end
_2amodule_locals_2a["eval-cb-fn"] = eval_cb_fn
local function eval_str(opts)
  local function _30_()
    local function _31_(conn)
      if (opts.context and not a["get-in"](conn, {"seen-ns", opts.context})) then
        local function _32_()
        end
        server.eval({code = ("(ns " .. opts.context .. ")")}, _32_)
        a["assoc-in"](conn, {"seen-ns", opts.context}, true)
      else
      end
      return server.eval(opts, eval_cb_fn(opts))
    end
    return server["with-conn-or-warn"](_31_)
  end
  return try_ensure_conn(_30_)
end
_2amodule_2a["eval-str"] = eval_str
local function with_info(opts, f)
  local function _34_(conn)
    local function _35_(msg)
      local function _36_()
        if not msg.status["no-info"] then
          return msg
        else
          return nil
        end
      end
      return f(_36_())
    end
    return server.send({op = "info", ns = (opts.context or "user"), symbol = opts.code, session = conn.session}, _35_)
  end
  return server["with-conn-and-op-or-warn"]("info", _34_)
end
_2amodule_locals_2a["with-info"] = with_info
local function java_info__3elines(_37_)
  local _arg_38_ = _37_
  local arglists_str = _arg_38_["arglists-str"]
  local class = _arg_38_["class"]
  local member = _arg_38_["member"]
  local javadoc = _arg_38_["javadoc"]
  local function _39_()
    if member then
      return {"/", member}
    else
      return nil
    end
  end
  local _40_
  if not a["empty?"](arglists_str) then
    _40_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
  else
    _40_ = nil
  end
  local function _42_()
    if javadoc then
      return {("; " .. javadoc)}
    else
      return nil
    end
  end
  return a.concat({str.join(a.concat({"; ", class}, _39_()))}, _40_, _42_())
end
_2amodule_locals_2a["java-info->lines"] = java_info__3elines
local function doc_str(opts)
  local function _43_()
    require_ns("clojure.repl")
    local function _44_(msgs)
      local function _45_(msg)
        return (a.get(msg, "out") or a.get(msg, "err"))
      end
      if a.some(_45_, msgs) then
        local function _46_(_241)
          return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true})
        end
        return a["run!"](_46_, msgs)
      else
        log.append({"; No results, checking CIDER's info op"})
        local function _47_(info)
          if a["nil?"](info) then
            return log.append({"; Nothing found via CIDER's info either"})
          elseif ("table" == type(info.javadoc)) then
            return log.append(java_info__3elines(info))
          elseif ("string" == type(info.doc)) then
            return log.append(a.concat({("; " .. info.ns .. "/" .. info.name), ("; (" .. info["arglists-str"] .. ")")}, text["prefixed-lines"](info.doc, "; ")))
          else
            return log.append(a.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](view.serialise(info), "; ")))
          end
        end
        return with_info(opts, _47_)
      end
    end
    return server.eval(a.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_44_))
  end
  return try_ensure_conn(_43_)
end
_2amodule_2a["doc-str"] = doc_str
local function nrepl__3envim_path(path)
  if text["starts-with"](path, "jar:file:") then
    local function _50_(zip, file)
      if (tonumber(string.sub(nvim.g.loaded_zipPlugin, 2)) > 31) then
        return ("zipfile://" .. zip .. "::" .. file)
      else
        return ("zipfile:" .. zip .. "::" .. file)
      end
    end
    return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _50_)
  elseif text["starts-with"](path, "file:") then
    local function _52_(file)
      return file
    end
    return string.gsub(path, "^file:(.+)$", _52_)
  else
    return path
  end
end
_2amodule_locals_2a["nrepl->nvim-path"] = nrepl__3envim_path
local function def_str(opts)
  local function _54_()
    local function _55_(info)
      if a["nil?"](info) then
        return log.append({"; No definition information found"})
      elseif info.candidates then
        local function _56_(_241)
          return (_241 .. "/" .. opts.code)
        end
        return log.append(a.concat({"; Multiple candidates found"}, a.map(_56_, a.keys(info.candidates))))
      elseif info.javadoc then
        return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
      elseif info["special-form"] then
        local function _57_()
          if info.url then
            return ("; " .. info.url)
          else
            return nil
          end
        end
        return log.append({"; Can't open source, it's a special form", _57_()})
      elseif (info.file and info.line) then
        local column = (info.column or 1)
        local path = nrepl__3envim_path(info.file)
        editor["go-to"](path, info.line, column)
        return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
      else
        return log.append({"; Unsupported target", ("; " .. a["pr-str"](info))})
      end
    end
    return with_info(opts, _55_)
  end
  return try_ensure_conn(_54_)
end
_2amodule_2a["def-str"] = def_str
local function eval_file(opts)
  local function _59_()
    return server.eval(a.assoc(opts, "code", ("(#?(:cljs cljs.core/load-file" .. " :default clojure.core/load-file)" .. " \"" .. opts["file-path"] .. "\")")), eval_cb_fn(opts))
  end
  return try_ensure_conn(_59_)
end
_2amodule_2a["eval-file"] = eval_file
local function interrupt()
  local function _60_()
    local function _61_(conn)
      local msgs
      local function _62_(msg)
        return ("eval" == msg.msg.op)
      end
      msgs = a.filter(_62_, a.vals(conn.msgs))
      local order_66
      local function _65_(_63_)
        local _arg_64_ = _63_
        local id = _arg_64_["id"]
        local session = _arg_64_["session"]
        local code = _arg_64_["code"]
        server.send({op = "interrupt", ["interrupt-id"] = id, session = session})
        local function _66_(sess)
          local function _67_()
            if code then
              return text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
            else
              return ("session: " .. sess.str() .. "")
            end
          end
          return log.append({("; Interrupted: " .. _67_())}, {["break?"] = true})
        end
        return server["enrich-session-id"](session, _66_)
      end
      order_66 = _65_
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
_2amodule_2a["interrupt"] = interrupt
local function eval_str_fn(code)
  local function _70_()
    return nvim.ex.ConjureEval(code)
  end
  return _70_
end
_2amodule_locals_2a["eval-str-fn"] = eval_str_fn
local last_exception = eval_str_fn("*e")
do end (_2amodule_2a)["last-exception"] = last_exception
local result_1 = eval_str_fn("*1")
do end (_2amodule_2a)["result-1"] = result_1
local result_2 = eval_str_fn("*2")
do end (_2amodule_2a)["result-2"] = result_2
local result_3 = eval_str_fn("*3")
do end (_2amodule_2a)["result-3"] = result_3
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
_2amodule_2a["view-source"] = view_source
local function clone_current_session()
  local function _74_()
    local function _75_(conn)
      return server["enrich-session-id"](a.get(conn, "session"), server["clone-session"])
    end
    return server["with-conn-or-warn"](_75_)
  end
  return try_ensure_conn(_74_)
end
_2amodule_2a["clone-current-session"] = clone_current_session
local function clone_fresh_session()
  local function _76_()
    local function _77_(conn)
      return server["clone-session"]()
    end
    return server["with-conn-or-warn"](_77_)
  end
  return try_ensure_conn(_76_)
end
_2amodule_2a["clone-fresh-session"] = clone_fresh_session
local function close_current_session()
  local function _78_()
    local function _79_(conn)
      local function _80_(sess)
        a.assoc(conn, "session", nil)
        log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
        local function _81_()
          return server["assume-or-create-session"]()
        end
        return server["close-session"](sess, _81_)
      end
      return server["enrich-session-id"](a.get(conn, "session"), _80_)
    end
    return server["with-conn-or-warn"](_79_)
  end
  return try_ensure_conn(_78_)
end
_2amodule_2a["close-current-session"] = close_current_session
local function display_sessions(cb)
  local function _82_()
    local function _83_(sessions)
      return ui["display-sessions"](sessions, cb)
    end
    return server["with-sessions"](_83_)
  end
  return try_ensure_conn(_82_)
end
_2amodule_2a["display-sessions"] = display_sessions
local function close_all_sessions()
  local function _84_()
    local function _85_(sessions)
      a["run!"](server["close-session"], sessions)
      log.append({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
      return server["clone-session"]()
    end
    return server["with-sessions"](_85_)
  end
  return try_ensure_conn(_84_)
end
_2amodule_2a["close-all-sessions"] = close_all_sessions
local function cycle_session(f)
  local function _86_()
    local function _87_(conn)
      local function _88_(sessions)
        if (1 == a.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
        else
          local session = a.get(conn, "session")
          local function _89_(_241)
            return f(session, _241)
          end
          return server["assume-session"](ll.val(ll["until"](_89_, ll.cycle(ll.create(sessions)))))
        end
      end
      return server["with-sessions"](_88_)
    end
    return server["with-conn-or-warn"](_87_)
  end
  return try_ensure_conn(_86_)
end
_2amodule_locals_2a["cycle-session"] = cycle_session
local function next_session()
  local function _91_(current, node)
    return (current == a.get(ll.val(ll.prev(node)), "id"))
  end
  return cycle_session(_91_)
end
_2amodule_2a["next-session"] = next_session
local function prev_session()
  local function _92_(current, node)
    return (current == a.get(ll.val(ll.next(node)), "id"))
  end
  return cycle_session(_92_)
end
_2amodule_2a["prev-session"] = prev_session
local function select_session_interactive()
  local function _93_()
    local function _94_(sessions)
      if (1 == a.count(sessions)) then
        return log.append({"; No other sessions"}, {["break?"] = true})
      else
        local function _95_()
          nvim.ex.redraw_()
          local n = nvim.fn.str2nr(extract.prompt("Session number: "))
          if (function(_96_,_97_,_98_) return (_96_ <= _97_) and (_97_ <= _98_) end)(1,n,a.count(sessions)) then
            return server["assume-session"](a.get(sessions, n))
          else
            return log.append({"; Invalid session number."})
          end
        end
        return ui["display-sessions"](sessions, _95_)
      end
    end
    return server["with-sessions"](_94_)
  end
  return try_ensure_conn(_93_)
end
_2amodule_2a["select-session-interactive"] = select_session_interactive
local test_runners = {clojure = {namespace = "clojure.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, clojurescript = {namespace = "cljs.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, kaocha = {namespace = "kaocha.repl", ["all-fn"] = "run-all", ["ns-fn"] = "run", ["single-fn"] = "run", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = ""}}
_2amodule_locals_2a["test-runners"] = test_runners
local function test_cfg(k)
  local runner = cfg({"test", "runner"})
  return (a["get-in"](test_runners, {runner, k}) or error(str.join({"No test-runners configuration for ", runner, " / ", k})))
end
_2amodule_locals_2a["test-cfg"] = test_cfg
local function require_test_runner()
  return require_ns(test_cfg("namespace"))
end
_2amodule_locals_2a["require-test-runner"] = require_test_runner
local function test_runner_code(fn_config_name, ...)
  return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
end
_2amodule_locals_2a["test-runner-code"] = test_runner_code
local function run_all_tests()
  local function _101_()
    log.append({"; run-all-tests"}, {["break?"] = true})
    require_test_runner()
    local function _102_(_241)
      return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
    end
    return server.eval({code = test_runner_code("all")}, _102_)
  end
  return try_ensure_conn(_101_)
end
_2amodule_2a["run-all-tests"] = run_all_tests
local function run_ns_tests(ns)
  local function _103_()
    if ns then
      log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      require_test_runner()
      local function _104_(_241)
        return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
      end
      return server.eval({code = test_runner_code("ns", ("'" .. ns))}, _104_)
    else
      return nil
    end
  end
  return try_ensure_conn(_103_)
end
_2amodule_locals_2a["run-ns-tests"] = run_ns_tests
local function run_current_ns_tests()
  return run_ns_tests(extract.context())
end
_2amodule_2a["run-current-ns-tests"] = run_current_ns_tests
local function run_alternate_ns_tests()
  local current_ns = extract.context()
  local function _106_()
    if text["ends-with"](current_ns, "-test") then
      return string.sub(current_ns, 1, -6)
    else
      return (current_ns .. "-test")
    end
  end
  return run_ns_tests(_106_())
end
_2amodule_2a["run-alternate-ns-tests"] = run_alternate_ns_tests
local function extract_test_name_from_form(form)
  local seen_deftest_3f = false
  local function _107_(part)
    local function _108_(config_current_form_name)
      return text["ends-with"](part, config_current_form_name)
    end
    if a.some(_108_, cfg({"test", "current_form_names"})) then
      seen_deftest_3f = true
      return false
    elseif seen_deftest_3f then
      return part
    else
      return nil
    end
  end
  return a.some(_107_, str.split(parse["strip-meta"](form), "%s+"))
end
_2amodule_2a["extract-test-name-from-form"] = extract_test_name_from_form
local function run_current_test()
  local function _110_()
    local form = extract.form({["root?"] = true})
    if form then
      local test_name = extract_test_name_from_form(form.content)
      if test_name then
        log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
        require_test_runner()
        local function _111_(msgs)
          if ((2 == a.count(msgs)) and ("nil" == a.get(a.first(msgs), "value"))) then
            return log.append({"; Success!"})
          else
            local function _112_(_241)
              return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
            end
            return a["run!"](_112_, msgs)
          end
        end
        return server.eval({code = test_runner_code("single", (test_cfg("name-prefix") .. test_name .. test_cfg("name-suffix"))), context = extract.context()}, nrepl["with-all-msgs-fn"](_111_))
      else
        return nil
      end
    else
      return nil
    end
  end
  return try_ensure_conn(_110_)
end
_2amodule_2a["run-current-test"] = run_current_test
local function refresh_impl(op)
  local function _116_(conn)
    local function _117_(msg)
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
    return server.send(a.merge({op = op, session = conn.session, after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"})}), _117_)
  end
  return server["with-conn-and-op-or-warn"](op, _116_)
end
_2amodule_locals_2a["refresh-impl"] = refresh_impl
local function refresh_changed()
  local function _119_()
    log.append({"; Refreshing changed namespaces"}, {["break?"] = true})
    return refresh_impl("refresh")
  end
  return try_ensure_conn(_119_)
end
_2amodule_2a["refresh-changed"] = refresh_changed
local function refresh_all()
  local function _120_()
    log.append({"; Refreshing all namespaces"}, {["break?"] = true})
    return refresh_impl("refresh-all")
  end
  return try_ensure_conn(_120_)
end
_2amodule_2a["refresh-all"] = refresh_all
local function refresh_clear()
  local function _121_()
    log.append({"; Clearing refresh cache"}, {["break?"] = true})
    local function _122_(conn)
      local function _123_(msgs)
        return log.append({"; Clearing complete"})
      end
      return server.send({op = "refresh-clear", session = conn.session}, nrepl["with-all-msgs-fn"](_123_))
    end
    return server["with-conn-and-op-or-warn"]("refresh-clear", _122_)
  end
  return try_ensure_conn(_121_)
end
_2amodule_2a["refresh-clear"] = refresh_clear
local function shadow_select(build)
  local function _124_()
    local function _125_(conn)
      log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
      server.eval({code = ("#?(:clj (shadow.cljs.devtools.api/nrepl-select :" .. build .. ") :cljs :already-selected)")}, ui["display-result"])
      return passive_ns_require()
    end
    return server["with-conn-or-warn"](_125_)
  end
  return try_ensure_conn(_124_)
end
_2amodule_2a["shadow-select"] = shadow_select
local function piggieback(code)
  local function _126_()
    local function _127_(conn)
      log.append({("; piggieback: " .. code)}, {["break?"] = true})
      require_ns("cider.piggieback")
      server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
      return passive_ns_require()
    end
    return server["with-conn-or-warn"](_127_)
  end
  return try_ensure_conn(_126_)
end
_2amodule_2a["piggieback"] = piggieback
local function clojure__3evim_completion(_128_)
  local _arg_129_ = _128_
  local word = _arg_129_["candidate"]
  local kind = _arg_129_["type"]
  local ns = _arg_129_["ns"]
  local info = _arg_129_["doc"]
  local arglists = _arg_129_["arglists"]
  local function _130_()
    if arglists then
      return table.concat(arglists, " ")
    else
      return nil
    end
  end
  local _131_
  if ("string" == type(info)) then
    _131_ = info
  else
    _131_ = nil
  end
  local _133_
  if not a["empty?"](kind) then
    _133_ = string.upper(string.sub(kind, 1, 1))
  else
    _133_ = nil
  end
  return {word = word, menu = table.concat({ns, _130_()}, " "), info = _131_, kind = _133_}
end
_2amodule_locals_2a["clojure->vim-completion"] = clojure__3evim_completion
local function extract_completion_context(prefix)
  local root_form = extract.form({["root?"] = true})
  if root_form then
    local _let_135_ = root_form
    local content = _let_135_["content"]
    local range = _let_135_["range"]
    local lines = text["split-lines"](content)
    local _let_136_ = nvim.win_get_cursor(0)
    local row = _let_136_[1]
    local col = _let_136_[2]
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
_2amodule_locals_2a["extract-completion-context"] = extract_completion_context
local function enhanced_cljs_completion_3f()
  return cfg({"completion", "cljs", "use_suitable"})
end
_2amodule_locals_2a["enhanced-cljs-completion?"] = enhanced_cljs_completion_3f
local function completions(opts)
  local function _139_(conn)
    local _140_
    if cfg({"completion", "with_context"}) then
      _140_ = extract_completion_context(opts.prefix)
    else
      _140_ = nil
    end
    local _142_
    if enhanced_cljs_completion_3f() then
      _142_ = "t"
    else
      _142_ = nil
    end
    local function _144_(msgs)
      return opts.cb(a.map(clojure__3evim_completion, a.get(a.last(msgs), "completions")))
    end
    return server.send({op = "complete", session = conn.session, ns = opts.context, symbol = opts.prefix, context = _140_, ["extra-metadata"] = {"arglists", "doc"}, ["enhanced-cljs-completion?"] = _142_}, nrepl["with-all-msgs-fn"](_144_))
  end
  return server["with-conn-and-op-or-warn"]("complete", _139_, {["silent?"] = true, ["else"] = opts.cb})
end
_2amodule_2a["completions"] = completions
local function out_subscribe()
  try_ensure_conn()
  log.append({"; Subscribing to out"}, {["break?"] = true})
  local function _145_(conn)
    return server.send({op = "out-subscribe"})
  end
  return server["with-conn-and-op-or-warn"]("out-subscribe", _145_)
end
_2amodule_2a["out-subscribe"] = out_subscribe
local function out_unsubscribe()
  try_ensure_conn()
  log.append({"; Unsubscribing from out"}, {["break?"] = true})
  local function _146_(conn)
    return server.send({op = "out-unsubscribe"})
  end
  return server["with-conn-and-op-or-warn"]("out-unsubscribe", _146_)
end
_2amodule_2a["out-unsubscribe"] = out_unsubscribe
return _2amodule_2a