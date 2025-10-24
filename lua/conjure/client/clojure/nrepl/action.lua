-- [nfnl] fnl/conjure/client/clojure/nrepl/action.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local auto_repl = autoload("conjure.client.clojure.nrepl.auto-repl")
local config = autoload("conjure.config")
local editor = autoload("conjure.editor")
local extract = autoload("conjure.extract")
local fs = autoload("conjure.fs")
local hook = autoload("conjure.hook")
local ll = autoload("conjure.linked-list")
local log = autoload("conjure.log")
local nrepl = autoload("conjure.remote.nrepl")
local parse = autoload("conjure.client.clojure.nrepl.parse")
local server = autoload("conjure.client.clojure.nrepl.server")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local ui = autoload("conjure.client.clojure.nrepl.ui")
local M = define("conjure.client.clojure.nrepl.action")
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
M["passive-ns-require"] = function()
  if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
    return require_ns(extract.context())
  else
    return nil
  end
end
M["connect-port-file"] = function(opts)
  local resolved_path
  do
    local tmp_6_ = cfg({"connection", "port_files"})
    if (tmp_6_ ~= nil) then
      resolved_path = fs["resolve-above"](tmp_6_)
    else
      resolved_path = nil
    end
  end
  local resolved
  if resolved_path then
    local port = core.slurp(resolved_path)
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
        local cb = core.get(opts, "cb")
        if cb then
          cb()
        else
        end
      end
      return M["passive-ns-require"]()
    end
    return server.connect({host = cfg({"connection", "default_host"}), port_file_path = _9_, port = _12_, cb = _14_, ["connect-opts"] = core.get(opts, "connect-opts")})
  else
    if not core.get(opts, "silent?") then
      log.append({"; No nREPL port file found"}, {["break?"] = true})
      return auto_repl["upsert-auto-repl-proc"]()
    else
      return nil
    end
  end
end
local function _18_(cb)
  return M["connect-port-file"]({["silent?"] = true, cb = cb})
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
M["connect-host-port"] = function(opts)
  if (not opts.host and not opts.port) then
    return M["connect-port-file"]()
  else
    local parsed_port
    if ("string" == type(opts.port)) then
      parsed_port = tonumber(opts.port)
    else
      parsed_port = nil
    end
    if parsed_port then
      return server.connect({host = (opts.host or cfg({"connection", "default_host"})), port = parsed_port, cb = M["passive-ns-require"]})
    else
      return log.append({str.join({"; Could not parse '", (opts.port or "nil"), "' as a port number"})})
    end
  end
end
local function eval_cb_fn(opts)
  local function _24_(resp)
    if (core.get(opts, "on-result") and core.get(resp, "value")) then
      opts["on-result"](resp.value)
    else
    end
    local cb = core.get(opts, "cb")
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
M["eval-str"] = function(opts)
  local function _28_()
    local function _29_(conn)
      if (opts.context and not core["get-in"](conn, {"seen-ns", opts.context})) then
        local function _30_()
        end
        server.eval({code = ("(ns " .. opts.context .. ")")}, _30_)
        core["assoc-in"](conn, {"seen-ns", opts.context}, true)
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
      _33_ = {op = "info", ns = (opts.context or "user"), symbol = opts.code, session = conn.session, ["download-sources-jar"] = 1}
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
  local class = _37_.class
  local member = _37_.member
  local javadoc = _37_.javadoc
  local function _38_()
    if member then
      return {"/", member}
    else
      return nil
    end
  end
  local _39_
  if not core["empty?"](arglists_str) then
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
  return core.concat({str.join(core.concat({"; ", class}, _38_()))}, _39_, _41_())
end
M["doc-str"] = function(opts)
  local function _42_()
    require_ns("clojure.repl")
    local function _43_(msgs)
      local function _44_(msg)
        return (core.get(msg, "out") or core.get(msg, "err"))
      end
      if core.some(_44_, msgs) then
        local function _45_(_241)
          return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true})
        end
        return core["run!"](_45_, msgs)
      else
        log.append({"; No results for (doc ...), checking nREPL info ops"})
        local function _46_(info)
          if core["nil?"](info) then
            return log.append({"; No information found, all I can do is wish you good luck and point you to https://duckduckgo.com/"})
          elseif ("string" == type(info.javadoc)) then
            return log.append(java_info__3elines(info))
          elseif ("string" == type(info.doc)) then
            return log.append(core.concat({str.join({"; ", info.ns, "/", info.name}), str.join({"; ", info["arglists-str"]})}, text["prefixed-lines"](info.doc, "; ")))
          else
            return log.append(core.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](core["pr-str"](info), "; ")))
          end
        end
        return with_info(opts, _46_)
      end
    end
    return server.eval(core.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_43_))
  end
  return try_ensure_conn(_42_)
end
local function nrepl__3envim_path(path)
  if text["starts-with"](path, "jar:file:") then
    local function _49_(zip, file)
      if (tonumber(string.sub(vim.g.loaded_zipPlugin, 2)) > 31) then
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
M["def-str"] = function(opts)
  local function _53_()
    local function _54_(info)
      if core["nil?"](info) then
        return log.append({"; No definition information found"})
      elseif info.candidates then
        local function _55_(_241)
          return (_241 .. "/" .. opts.code)
        end
        return log.append(core.concat({"; Multiple candidates found"}, core.map(_55_, core.keys(info.candidates))))
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
        return log.append({"; Unsupported target", ("; " .. core["pr-str"](info))})
      end
    end
    return with_info(opts, _54_)
  end
  return try_ensure_conn(_53_)
end
M["escape-backslashes"] = function(s)
  return s:gsub("\\", "\\\\")
end
M["eval-file"] = function(opts)
  local function _58_()
    local function _59_(conn)
      return server["load-file"](core.assoc(opts, "code", core.slurp(opts["file-path"])), eval_cb_fn(opts))
    end
    return server["with-conn-or-warn"](_59_)
  end
  return try_ensure_conn(_58_)
end
M.interrupt = function()
  local function _60_()
    local function _61_(conn)
      local msgs
      local function _62_(msg)
        return ("eval" == msg.msg.op)
      end
      msgs = core.filter(_62_, core.vals(conn.msgs))
      local order_66
      local function _64_(_63_)
        local id = _63_.id
        local session = _63_.session
        local code = _63_.code
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
      if core["empty?"](msgs) then
        return order_66({session = conn.session})
      else
        local function _68_(a, b)
          return (a["sent-at"] < b["sent-at"])
        end
        table.sort(msgs, _68_)
        return order_66(core.get(core.first(msgs), "msg"))
      end
    end
    return server["with-conn-or-warn"](_61_)
  end
  return try_ensure_conn(_60_)
end
local function eval_str_fn(code)
  local function _70_()
    return vim.api.nvim_exec2(("ConjureEval " .. code), {})
  end
  return _70_
end
M["last-exception"] = eval_str_fn("*e")
M["result-1"] = eval_str_fn("*1")
M["result-2"] = eval_str_fn("*2")
M["result-3"] = eval_str_fn("*3")
M["view-tap"] = eval_str_fn("(conjure.internal/dump-tap-queue!)")
M["view-source"] = function()
  local function _71_()
    local word = core.get(extract.word(), "content")
    if not core["empty?"](word) then
      log.append({("; source (word): " .. word)}, {["break?"] = true})
      require_ns("clojure.repl")
      local function _72_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return M["eval-str"]({code = ("(clojure.repl/source " .. word .. ")"), context = extract.context(), cb = _72_})
    else
      return nil
    end
  end
  return try_ensure_conn(_71_)
end
local function eval_macro_expand(expander)
  local function _74_()
    local form = core.get(extract.form({}), "content")
    if not core["empty?"](form) then
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
      return M["eval-str"]({code = (_75_ .. "(" .. expander .. " '" .. form .. ")"), context = extract.context(), cb = _77_})
    else
      return nil
    end
  end
  return try_ensure_conn(_74_)
end
M["macro-expand-1"] = function()
  return eval_macro_expand("macroexpand-1")
end
M["macro-expand"] = function()
  return eval_macro_expand("macroexpand")
end
M["macro-expand-all"] = function()
  return eval_macro_expand("clojure.walk/macroexpand-all")
end
M["clone-current-session"] = function()
  local function _79_()
    local function _80_(conn)
      return server["enrich-session-id"](core.get(conn, "session"), server["clone-session"])
    end
    return server["with-conn-or-warn"](_80_)
  end
  return try_ensure_conn(_79_)
end
M["clone-fresh-session"] = function()
  local function _81_()
    local function _82_(conn)
      return server["clone-session"]()
    end
    return server["with-conn-or-warn"](_82_)
  end
  return try_ensure_conn(_81_)
end
M["close-current-session"] = function()
  local function _83_()
    local function _84_(conn)
      local function _85_(sess)
        core.assoc(conn, "session", nil)
        log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
        local function _86_()
          return server["assume-or-create-session"]()
        end
        return server["close-session"](sess, _86_)
      end
      return server["enrich-session-id"](core.get(conn, "session"), _85_)
    end
    return server["with-conn-or-warn"](_84_)
  end
  return try_ensure_conn(_83_)
end
M["display-sessions"] = function(cb)
  local function _87_()
    local function _88_(sessions)
      return ui["display-sessions"](sessions, cb)
    end
    return server["with-sessions"](_88_)
  end
  return try_ensure_conn(_87_)
end
M["close-all-sessions"] = function()
  local function _89_()
    local function _90_(sessions)
      core["run!"](server["close-session"], sessions)
      log.append({("; Closed all sessions (" .. core.count(sessions) .. ")")}, {["break?"] = true})
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
        if (1 == core.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
        else
          local session = core.get(conn, "session")
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
M["next-session"] = function()
  local function _96_(current, node)
    return (current == core.get(ll.val(ll.prev(node)), "id"))
  end
  return cycle_session(_96_)
end
M["prev-session"] = function()
  local function _97_(current, node)
    return (current == core.get(ll.val(ll.next(node)), "id"))
  end
  return cycle_session(_97_)
end
M["select-session-interactive"] = function()
  local function _98_()
    local function _99_(sessions)
      if (1 == core.count(sessions)) then
        return log.append({"; No other sessions"}, {["break?"] = true})
      else
        local function _100_(_241)
          return (_241.name .. " (" .. _241["pretty-type"] .. ", " .. _241.id .. ")")
        end
        local function _101_(session)
          return server["assume-session"](session)
        end
        return vim.ui.select(sessions, {prompt = "Select an nREPL session:", format_item = _100_}, _101_)
      end
    end
    return server["with-sessions"](_99_)
  end
  return try_ensure_conn(_98_)
end
M["test-runners"] = {clojure = {namespace = "clojure.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, clojurescript = {namespace = "cljs.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, kaocha = {namespace = "kaocha.repl", ["all-fn"] = "run-all", ["ns-fn"] = "run", ["single-fn"] = "run", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = ""}}
local function test_cfg(k)
  local runner = cfg({"test", "runner"})
  return (core["get-in"](M["test-runners"], {runner, k}) or error(str.join({"No test-runners configuration for ", runner, " / ", k})))
end
local function require_test_runner()
  return require_ns(test_cfg("namespace"))
end
local function test_runner_code(fn_config_name, ...)
  return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
end
M["run-all-tests"] = function()
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
M["run-current-ns-tests"] = function()
  return run_ns_tests(extract.context())
end
M["run-alternate-ns-tests"] = function()
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
M["extract-test-name-from-form"] = function(form)
  local seen_deftest_3f = false
  local function _109_(part)
    local function _110_(config_current_form_name)
      return text["ends-with"](part, config_current_form_name)
    end
    if core.some(_110_, cfg({"test", "current_form_names"})) then
      seen_deftest_3f = true
      return false
    elseif seen_deftest_3f then
      return part
    else
      return nil
    end
  end
  return core.some(_109_, str.split(parse["strip-meta"](form), "%s+"))
end
M["run-current-test"] = function()
  local function _112_()
    local form = extract.form({["root?"] = true})
    if form then
      local test_name = M["extract-test-name-from-form"](form.content)
      if test_name then
        log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
        require_test_runner()
        local function _113_(msgs)
          if ((2 == core.count(msgs)) and ("nil" == core.get(core.first(msgs), "value"))) then
            return log.append({"; Success!"})
          else
            local function _114_(_241)
              return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
            end
            return core["run!"](_114_, msgs)
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
    return server.send(core.merge({op = op, session = conn.session, after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"})}), _119_)
  end
  return server["with-conn-and-ops-or-warn"]({op}, _118_)
end
local function use_clj_reload_backend_3f()
  return (cfg({"refresh", "backend"}) == "clj-reload")
end
M["refresh-changed"] = function()
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
M["refresh-all"] = function()
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
M["refresh-clear"] = function()
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
M["shadow-select"] = function(build)
  local function _136_()
    local function _137_(conn)
      log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
      server.eval({code = ("#?(:clj (shadow.cljs.devtools.api/nrepl-select :" .. build .. ") :cljs :already-selected)")}, ui["display-result"])
      return M["passive-ns-require"]()
    end
    return server["with-conn-or-warn"](_137_)
  end
  return try_ensure_conn(_136_)
end
M.piggieback = function(code)
  local function _138_()
    local function _139_(conn)
      log.append({("; piggieback: " .. code)}, {["break?"] = true})
      require_ns("cider.piggieback")
      server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
      return M["passive-ns-require"]()
    end
    return server["with-conn-or-warn"](_139_)
  end
  return try_ensure_conn(_138_)
end
local function clojure__3evim_completion(_140_)
  local word = _140_.candidate
  local kind = _140_.type
  local ns = _140_.ns
  local info = _140_.doc
  local arglists = _140_.arglists
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
  if not core["empty?"](kind) then
    _144_ = string.upper(string.sub(kind, 1, 1))
  else
    _144_ = nil
  end
  return {word = word, menu = str.join(" ", {ns, _141_()}), info = _142_, kind = _144_}
end
local function extract_completion_context(prefix)
  local root_form = extract.form({["root?"] = true})
  if root_form then
    local content = root_form.content
    local range = root_form.range
    local lines = text["split-lines"](content)
    local _let_146_ = vim.api.nvim_win_get_cursor(0)
    local row = _let_146_[1]
    local col = _let_146_[2]
    local lrow = (row - core["get-in"](range, {"start", 1}))
    local line_index = core.inc(lrow)
    local lcol
    if (lrow == 0) then
      lcol = (col - core["get-in"](range, {"start", 2}))
    else
      lcol = col
    end
    local original = core.get(lines, line_index)
    local spliced = (string.sub(original, 1, lcol) .. "__prefix__" .. string.sub(original, core.inc(lcol)))
    return str.join("\n", core.assoc(lines, line_index, spliced))
  else
    return nil
  end
end
local function enhanced_cljs_completion_3f()
  return cfg({"completion", "cljs", "use_suitable"})
end
M.completions = function(opts)
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
      return opts.cb(core.map(clojure__3evim_completion, core.get(core.last(msgs), "completions")))
    end
    return server.send(_150_, nrepl["with-all-msgs-fn"](_156_))
  end
  return server["with-conn-and-ops-or-warn"]({"complete", "completions"}, _149_, {["silent?"] = true, ["else"] = opts.cb})
end
M["out-subscribe"] = function()
  try_ensure_conn()
  log.append({"; Subscribing to out"}, {["break?"] = true})
  local function _157_(conn)
    return server.send({op = "out-subscribe"})
  end
  return server["with-conn-and-ops-or-warn"]({"out-subscribe"}, _157_)
end
M["out-unsubscribe"] = function()
  try_ensure_conn()
  log.append({"; Unsubscribing from out"}, {["break?"] = true})
  local function _158_(conn)
    return server.send({op = "out-unsubscribe"})
  end
  return server["with-conn-and-ops-or-warn"]({"out-unsubscribe"}, _158_)
end
return M
