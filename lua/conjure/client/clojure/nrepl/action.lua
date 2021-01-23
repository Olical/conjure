local _0_0 = nil
do
  local name_0_ = "conjure.client.clojure.nrepl.action"
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
    return {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.editor"), require("conjure.aniseed.eval"), require("conjure.extract"), require("conjure.fs"), require("conjure.linked-list"), require("conjure.log"), require("conjure.remote.nrepl"), require("conjure.aniseed.nvim"), require("conjure.client.clojure.nrepl.server"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.client.clojure.nrepl.ui"), require("conjure.aniseed.view")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", config = "conjure.config", editor = "conjure.editor", eval = "conjure.aniseed.eval", extract = "conjure.extract", fs = "conjure.fs", ll = "conjure.linked-list", log = "conjure.log", nrepl = "conjure.remote.nrepl", nvim = "conjure.aniseed.nvim", server = "conjure.client.clojure.nrepl.server", str = "conjure.aniseed.string", text = "conjure.text", ui = "conjure.client.clojure.nrepl.ui", view = "conjure.aniseed.view"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local nvim = _1_[10]
local server = _1_[11]
local str = _1_[12]
local text = _1_[13]
local ui = _1_[14]
local view = _1_[15]
local config = _1_[2]
local editor = _1_[3]
local eval = _1_[4]
local extract = _1_[5]
local fs = _1_[6]
local ll = _1_[7]
local log = _1_[8]
local nrepl = _1_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.action"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local require_ns = nil
do
  local v_0_ = nil
  local function require_ns0(ns)
    if ns then
      local function _3_()
      end
      return server.eval({code = ("(require '" .. ns .. ")")}, _3_)
    end
  end
  v_0_ = require_ns0
  _0_0["aniseed/locals"]["require-ns"] = v_0_
  require_ns = v_0_
end
local cfg = nil
do
  local v_0_ = config["get-in-fn"]({"client", "clojure", "nrepl"})
  _0_0["aniseed/locals"]["cfg"] = v_0_
  cfg = v_0_
end
local passive_ns_require = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function passive_ns_require0()
      if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
        return require_ns(extract.context())
      end
    end
    v_0_0 = passive_ns_require0
    _0_0["passive-ns-require"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["passive-ns-require"] = v_0_
  passive_ns_require = v_0_
end
local connect_port_file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect_port_file0(opts)
      local port = nil
      do
        local _3_0 = cfg({"connection", "port_files"})
        if _3_0 then
          local _4_0 = a.map(fs["resolve-above"], _3_0)
          if _4_0 then
            local _5_0 = a.some(a.slurp, _4_0)
            if _5_0 then
              port = tonumber(_5_0)
            else
              port = _5_0
            end
          else
            port = _4_0
          end
        else
          port = _3_0
        end
      end
      if port then
        local function _4_()
          do
            local cb = a.get(opts, "cb")
            if cb then
              cb()
            end
          end
          return passive_ns_require()
        end
        return server.connect({cb = _4_, host = cfg({"connection", "default_host"}), port = port})
      else
        if not a.get(opts, "silent?") then
          return log.append({"; No nREPL port file found"}, {["break?"] = true})
        end
      end
    end
    v_0_0 = connect_port_file0
    _0_0["connect-port-file"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect-port-file"] = v_0_
  connect_port_file = v_0_
end
local try_ensure_conn = nil
do
  local v_0_ = nil
  local function try_ensure_conn0(cb)
    if not server["connected?"]() then
      return connect_port_file({["silent?"] = true, cb = cb})
    else
      if cb then
        return cb()
      end
    end
  end
  v_0_ = try_ensure_conn0
  _0_0["aniseed/locals"]["try-ensure-conn"] = v_0_
  try_ensure_conn = v_0_
end
local connect_host_port = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect_host_port0(opts)
      if (not opts.host and not opts.port) then
        return connect_port_file()
      else
        local parsed_port = nil
        if ("string" == type(opts.port)) then
          parsed_port = tonumber(opts.port)
        else
        parsed_port = nil
        end
        if parsed_port then
          return server.connect({cb = passive_ns_require, host = (opts.host or cfg({"connection", "default_host"})), port = parsed_port})
        else
          return log.append({("; Could not parse '" .. opts.port .. "' as a port number")})
        end
      end
    end
    v_0_0 = connect_host_port0
    _0_0["connect-host-port"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect-host-port"] = v_0_
  connect_host_port = v_0_
end
local eval_cb_fn = nil
do
  local v_0_ = nil
  local function eval_cb_fn0(opts)
    local function _3_(resp)
      if (a.get(opts, "on-result") and a.get(resp, "value")) then
        opts["on-result"](resp.value)
      end
      local cb = a.get(opts, "cb")
      if cb then
        return cb(resp)
      else
        if not opts["passive?"] then
          return ui["display-result"](resp, opts)
        end
      end
    end
    return _3_
  end
  v_0_ = eval_cb_fn0
  _0_0["aniseed/locals"]["eval-cb-fn"] = v_0_
  eval_cb_fn = v_0_
end
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
      local function _3_()
        local function _4_(conn)
          if (opts.context and not a["get-in"](conn, {"seen-ns", opts.context})) then
            local function _5_()
            end
            server.eval({code = ("(ns " .. opts.context .. ")")}, _5_)
            a["assoc-in"](conn, {"seen-ns", opts.context}, true)
          end
          return server.eval(opts, eval_cb_fn(opts))
        end
        return server["with-conn-or-warn"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = eval_str0
    _0_0["eval-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_0_
  eval_str = v_0_
end
local with_info = nil
do
  local v_0_ = nil
  local function with_info0(opts, f)
    local function _3_(conn)
      local function _4_(msg)
        local function _5_()
          if not msg.status["no-info"] then
            return msg
          end
        end
        return f(_5_())
      end
      return server.send({ns = (opts.context or "user"), op = "info", session = conn.session, symbol = opts.code}, _4_)
    end
    return server["with-conn-and-op-or-warn"]("info", _3_)
  end
  v_0_ = with_info0
  _0_0["aniseed/locals"]["with-info"] = v_0_
  with_info = v_0_
end
local java_info__3elines = nil
do
  local v_0_ = nil
  local function java_info__3elines0(_3_0)
    local _4_ = _3_0
    local arglists_str = _4_["arglists-str"]
    local class = _4_["class"]
    local javadoc = _4_["javadoc"]
    local member = _4_["member"]
    local function _5_()
      if member then
        return {"/", member}
      end
    end
    local _6_
    if not a["empty?"](arglists_str) then
      _6_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
    else
    _6_ = nil
    end
    local function _8_()
      if javadoc then
        return {("; " .. javadoc)}
      end
    end
    return a.concat({str.join(a.concat({"; ", class}, _5_()))}, _6_, _8_())
  end
  v_0_ = java_info__3elines0
  _0_0["aniseed/locals"]["java-info->lines"] = v_0_
  java_info__3elines = v_0_
end
local doc_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_str0(opts)
      local function _3_()
        require_ns("clojure.repl")
        local function _4_(msgs)
          local function _5_(msg)
            return (a.get(msg, "out") or a.get(msg, "err"))
          end
          if a.some(_5_, msgs) then
            local function _6_(_241)
              return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
            end
            return a["run!"](_6_, msgs)
          else
            log.append({"; No results, checking CIDER's info op"})
            local function _6_(info)
              if a["nil?"](info) then
                return log.append({"; Nothing found via CIDER's info either"})
              elseif info.javadoc then
                return log.append(java_info__3elines(info))
              elseif info.doc then
                return log.append(a.concat({("; " .. info.ns .. "/" .. info.name), ("; (" .. info["arglists-str"] .. ")")}, text["prefixed-lines"](info.doc, "; ")))
              else
                return log.append(a.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](view.serialise(info), "; ")))
              end
            end
            return with_info(opts, _6_)
          end
        end
        return server.eval(a.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_4_))
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = doc_str0
    _0_0["doc-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_0_
  doc_str = v_0_
end
local nrepl__3envim_path = nil
do
  local v_0_ = nil
  local function nrepl__3envim_path0(path)
    if text["starts-with"](path, "jar:file:") then
      local function _3_(zip, file)
        return ("zipfile:" .. zip .. "::" .. file)
      end
      return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _3_)
    elseif text["starts-with"](path, "file:") then
      local function _3_(file)
        return file
      end
      return string.gsub(path, "^file:(.+)$", _3_)
    else
      return path
    end
  end
  v_0_ = nrepl__3envim_path0
  _0_0["aniseed/locals"]["nrepl->nvim-path"] = v_0_
  nrepl__3envim_path = v_0_
end
local def_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function def_str0(opts)
      local function _3_()
        local function _4_(info)
          if a["nil?"](info) then
            return log.append({"; No definition information found"})
          elseif info.candidates then
            local function _5_(_241)
              return (_241 .. "/" .. opts.code)
            end
            return log.append(a.concat({"; Multiple candidates found"}, a.map(_5_, a.keys(info.candidates))))
          elseif info.javadoc then
            return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
          elseif info["special-form"] then
            local function _5_()
              if info.url then
                return ("; " .. info.url)
              end
            end
            return log.append({"; Can't open source, it's a special form", _5_()})
          elseif (info.file and info.line) then
            local column = (info.column or 1)
            local path = nrepl__3envim_path(info.file)
            editor["go-to"](path, info.line, column)
            return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
          else
            return log.append({"; Unsupported target", ("; " .. a["pr-str"](info))})
          end
        end
        return with_info(opts, _4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = def_str0
    _0_0["def-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["def-str"] = v_0_
  def_str = v_0_
end
local eval_file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_file0(opts)
      local function _3_()
        return server.eval(a.assoc(opts, "code", ("(#?(:cljs cljs.core/load-file" .. " :default clojure.core/load-file)" .. " \"" .. opts["file-path"] .. "\")")), eval_cb_fn(opts))
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = eval_file0
    _0_0["eval-file"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_0_
  eval_file = v_0_
end
local interrupt = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function interrupt0()
      local function _3_()
        local function _4_(conn)
          local msgs = nil
          local function _5_(msg)
            return ("eval" == msg.msg.op)
          end
          msgs = a.filter(_5_, a.vals(conn.msgs))
          local order_66 = nil
          local function _6_(_7_0)
            local _8_ = _7_0
            local code = _8_["code"]
            local id = _8_["id"]
            local session = _8_["session"]
            server.send({["interrupt-id"] = id, op = "interrupt", session = session})
            local function _9_(sess)
              local function _10_()
                if code then
                  return text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
                else
                  return ("session: " .. sess.str() .. "")
                end
              end
              return log.append({("; Interrupted: " .. _10_())}, {["break?"] = true})
            end
            return server["enrich-session-id"](session, _9_)
          end
          order_66 = _6_
          if a["empty?"](msgs) then
            return order_66({session = conn.session})
          else
            local function _8_(a0, b)
              return (a0["sent-at"] < b["sent-at"])
            end
            table.sort(msgs, _8_)
            return order_66(a.get(a.first(msgs), "msg"))
          end
        end
        return server["with-conn-or-warn"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = interrupt0
    _0_0["interrupt"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["interrupt"] = v_0_
  interrupt = v_0_
end
local eval_str_fn = nil
do
  local v_0_ = nil
  local function eval_str_fn0(code)
    local function _3_()
      return nvim.ex.ConjureEval(code)
    end
    return _3_
  end
  v_0_ = eval_str_fn0
  _0_0["aniseed/locals"]["eval-str-fn"] = v_0_
  eval_str_fn = v_0_
end
local last_exception = nil
do
  local v_0_ = nil
  do
    local v_0_0 = eval_str_fn("*e")
    _0_0["last-exception"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["last-exception"] = v_0_
  last_exception = v_0_
end
local result_1 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = eval_str_fn("*1")
    _0_0["result-1"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["result-1"] = v_0_
  result_1 = v_0_
end
local result_2 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = eval_str_fn("*2")
    _0_0["result-2"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["result-2"] = v_0_
  result_2 = v_0_
end
local result_3 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = eval_str_fn("*3")
    _0_0["result-3"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["result-3"] = v_0_
  result_3 = v_0_
end
local view_source = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function view_source0()
      local function _3_()
        local word = a.get(extract.word(), "content")
        if not a["empty?"](word) then
          log.append({("; source (word): " .. word)}, {["break?"] = true})
          require_ns("clojure.repl")
          local function _4_(_241)
            return ui["display-result"](_241, {["ignore-nil?"] = true, ["raw-out?"] = true})
          end
          return eval_str({cb = _4_, code = ("(clojure.repl/source " .. word .. ")"), context = extract.context()})
        end
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = view_source0
    _0_0["view-source"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["view-source"] = v_0_
  view_source = v_0_
end
local clone_current_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function clone_current_session0()
      local function _3_()
        local function _4_(conn)
          return server["enrich-session-id"](a.get(conn, "session"), server["clone-session"])
        end
        return server["with-conn-or-warn"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = clone_current_session0
    _0_0["clone-current-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["clone-current-session"] = v_0_
  clone_current_session = v_0_
end
local clone_fresh_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function clone_fresh_session0()
      local function _3_()
        local function _4_(conn)
          return server["clone-session"]()
        end
        return server["with-conn-or-warn"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = clone_fresh_session0
    _0_0["clone-fresh-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["clone-fresh-session"] = v_0_
  clone_fresh_session = v_0_
end
local close_current_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function close_current_session0()
      local function _3_()
        local function _4_(conn)
          local function _5_(sess)
            a.assoc(conn, "session", nil)
            log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
            local function _6_()
              return server["assume-or-create-session"]()
            end
            return server["close-session"](sess, _6_)
          end
          return server["enrich-session-id"](a.get(conn, "session"), _5_)
        end
        return server["with-conn-or-warn"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = close_current_session0
    _0_0["close-current-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["close-current-session"] = v_0_
  close_current_session = v_0_
end
local display_sessions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display_sessions0(cb)
      local function _3_()
        local function _4_(sessions)
          return ui["display-sessions"](sessions, cb)
        end
        return server["with-sessions"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = display_sessions0
    _0_0["display-sessions"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["display-sessions"] = v_0_
  display_sessions = v_0_
end
local close_all_sessions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function close_all_sessions0()
      local function _3_()
        local function _4_(sessions)
          a["run!"](server["close-session"], sessions)
          log.append({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
          return server["clone-session"]()
        end
        return server["with-sessions"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = close_all_sessions0
    _0_0["close-all-sessions"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["close-all-sessions"] = v_0_
  close_all_sessions = v_0_
end
local cycle_session = nil
do
  local v_0_ = nil
  local function cycle_session0(f)
    local function _3_()
      local function _4_(conn)
        local function _5_(sessions)
          if (1 == a.count(sessions)) then
            return log.append({"; No other sessions"}, {["break?"] = true})
          else
            local session = a.get(conn, "session")
            local function _6_(_241)
              return f(session, _241)
            end
            return server["assume-session"](ll.val(ll["until"](_6_, ll.cycle(ll.create(sessions)))))
          end
        end
        return server["with-sessions"](_5_)
      end
      return server["with-conn-or-warn"](_4_)
    end
    return try_ensure_conn(_3_)
  end
  v_0_ = cycle_session0
  _0_0["aniseed/locals"]["cycle-session"] = v_0_
  cycle_session = v_0_
end
local next_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function next_session0()
      local function _3_(current, node)
        return (current == a.get(ll.val(ll.prev(node)), "id"))
      end
      return cycle_session(_3_)
    end
    v_0_0 = next_session0
    _0_0["next-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["next-session"] = v_0_
  next_session = v_0_
end
local prev_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function prev_session0()
      local function _3_(current, node)
        return (current == a.get(ll.val(ll.next(node)), "id"))
      end
      return cycle_session(_3_)
    end
    v_0_0 = prev_session0
    _0_0["prev-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["prev-session"] = v_0_
  prev_session = v_0_
end
local select_session_interactive = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function select_session_interactive0()
      local function _3_()
        local function _4_(sessions)
          if (1 == a.count(sessions)) then
            return log.append({"; No other sessions"}, {["break?"] = true})
          else
            local function _5_()
              nvim.ex.redraw_()
              local n = nvim.fn.str2nr(extract.prompt("Session number: "))
              if (function(_6_,_7_,_8_) return (_6_ <= _7_) and (_7_ <= _8_) end)(1,n,a.count(sessions)) then
                return server["assume-session"](a.get(sessions, n))
              else
                return log.append({"; Invalid session number."})
              end
            end
            return ui["display-sessions"](sessions, _5_)
          end
        end
        return server["with-sessions"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = select_session_interactive0
    _0_0["select-session-interactive"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["select-session-interactive"] = v_0_
  select_session_interactive = v_0_
end
local run_all_tests = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function run_all_tests0()
      local function _3_()
        log.append({"; run-all-tests"}, {["break?"] = true})
        require_ns("clojure.test")
        local function _4_(_241)
          return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
        end
        return server.eval({code = "(clojure.test/run-all-tests)"}, _4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = run_all_tests0
    _0_0["run-all-tests"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["run-all-tests"] = v_0_
  run_all_tests = v_0_
end
local run_ns_tests = nil
do
  local v_0_ = nil
  local function run_ns_tests0(ns)
    local function _3_()
      if ns then
        log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
        require_ns("clojure.test")
        local function _4_(_241)
          return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
        end
        return server.eval({code = ("(clojure.test/run-tests '" .. ns .. ")")}, _4_)
      end
    end
    return try_ensure_conn(_3_)
  end
  v_0_ = run_ns_tests0
  _0_0["aniseed/locals"]["run-ns-tests"] = v_0_
  run_ns_tests = v_0_
end
local run_current_ns_tests = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function run_current_ns_tests0()
      return run_ns_tests(extract.context())
    end
    v_0_0 = run_current_ns_tests0
    _0_0["run-current-ns-tests"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["run-current-ns-tests"] = v_0_
  run_current_ns_tests = v_0_
end
local run_alternate_ns_tests = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    v_0_0 = run_alternate_ns_tests0
    _0_0["run-alternate-ns-tests"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["run-alternate-ns-tests"] = v_0_
  run_alternate_ns_tests = v_0_
end
local extract_test_name_from_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function extract_test_name_from_form0(form)
      local seen_deftest_3f = false
      local function _3_(part)
        if text["ends-with"](part, "deftest") then
          seen_deftest_3f = true
          return false
        elseif text["starts-with"](part, "^") then
          return false
        elseif seen_deftest_3f then
          return part
        end
      end
      return a.some(_3_, str.split(form, "%s+"))
    end
    v_0_0 = extract_test_name_from_form0
    _0_0["extract-test-name-from-form"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["extract-test-name-from-form"] = v_0_
  extract_test_name_from_form = v_0_
end
local run_current_test = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function run_current_test0()
      local function _3_()
        local form = extract.form({["root?"] = true})
        if form then
          local test_name = extract_test_name_from_form(form.content)
          if test_name then
            log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
            require_ns("clojure.test")
            local function _4_(msgs)
              if ((2 == a.count(msgs)) and ("nil" == a.get(a.first(msgs), "value"))) then
                return log.append({"; Success!"})
              else
                local function _5_(_241)
                  return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
                end
                return a["run!"](_5_, msgs)
              end
            end
            return server.eval({code = ("(clojure.test/test-vars" .. "  [(doto (resolve '" .. test_name .. ")" .. "     (assert \"" .. test_name .. " is not a var\"))])"), context = extract.context()}, nrepl["with-all-msgs-fn"](_4_))
          end
        end
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = run_current_test0
    _0_0["run-current-test"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["run-current-test"] = v_0_
  run_current_test = v_0_
end
local refresh_impl = nil
do
  local v_0_ = nil
  local function refresh_impl0(op)
    local function _3_(conn)
      local function _4_(msg)
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
      return server.send(a.merge({after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"}), op = op, session = conn.session}), _4_)
    end
    return server["with-conn-and-op-or-warn"](op, _3_)
  end
  v_0_ = refresh_impl0
  _0_0["aniseed/locals"]["refresh-impl"] = v_0_
  refresh_impl = v_0_
end
local refresh_changed = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function refresh_changed0()
      local function _3_()
        log.append({"; Refreshing changed namespaces"}, {["break?"] = true})
        return refresh_impl("refresh")
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = refresh_changed0
    _0_0["refresh-changed"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["refresh-changed"] = v_0_
  refresh_changed = v_0_
end
local refresh_all = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function refresh_all0()
      local function _3_()
        log.append({"; Refreshing all namespaces"}, {["break?"] = true})
        return refresh_impl("refresh-all")
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = refresh_all0
    _0_0["refresh-all"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["refresh-all"] = v_0_
  refresh_all = v_0_
end
local refresh_clear = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function refresh_clear0()
      local function _3_()
        log.append({"; Clearing refresh cache"}, {["break?"] = true})
        local function _4_(conn)
          local function _5_(msgs)
            return log.append({"; Clearing complete"})
          end
          return server.send({op = "refresh-clear", session = conn.session}, nrepl["with-all-msgs-fn"](_5_))
        end
        return server["with-conn-and-op-or-warn"]("refresh-clear", _4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = refresh_clear0
    _0_0["refresh-clear"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["refresh-clear"] = v_0_
  refresh_clear = v_0_
end
local shadow_select = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function shadow_select0(build)
      local function _3_()
        local function _4_(conn)
          log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
          server.eval({code = ("(shadow.cljs.devtools.api/nrepl-select :" .. build .. ")")}, ui["display-result"])
          return passive_ns_require()
        end
        return server["with-conn-or-warn"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = shadow_select0
    _0_0["shadow-select"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["shadow-select"] = v_0_
  shadow_select = v_0_
end
local piggieback = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function piggieback0(code)
      local function _3_()
        local function _4_(conn)
          log.append({("; piggieback: " .. code)}, {["break?"] = true})
          require_ns("cider.piggieback")
          server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
          return passive_ns_require()
        end
        return server["with-conn-or-warn"](_4_)
      end
      return try_ensure_conn(_3_)
    end
    v_0_0 = piggieback0
    _0_0["piggieback"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["piggieback"] = v_0_
  piggieback = v_0_
end
local clojure__3evim_completion = nil
do
  local v_0_ = nil
  local function clojure__3evim_completion0(_3_0)
    local _4_ = _3_0
    local arglists = _4_["arglists"]
    local word = _4_["candidate"]
    local info = _4_["doc"]
    local ns = _4_["ns"]
    local kind = _4_["type"]
    local _5_
    if not a["empty?"](kind) then
      _5_ = string.upper(string.sub(kind, 1, 1))
    else
    _5_ = nil
    end
    local function _7_()
      if arglists then
        return table.concat(arglists, " ")
      end
    end
    return {info = info, kind = _5_, menu = table.concat({ns, _7_()}, " "), word = word}
  end
  v_0_ = clojure__3evim_completion0
  _0_0["aniseed/locals"]["clojure->vim-completion"] = v_0_
  clojure__3evim_completion = v_0_
end
local extract_completion_context = nil
do
  local v_0_ = nil
  local function extract_completion_context0(prefix)
    local root_form = extract.form({["root?"] = true})
    if root_form then
      local _3_ = root_form
      local content = _3_["content"]
      local range = _3_["range"]
      local lines = text["split-lines"](content)
      local _4_ = nvim.win_get_cursor(0)
      local row = _4_[1]
      local col = _4_[2]
      local lrow = (row - a["get-in"](range, {"start", 1}))
      local line_index = a.inc(lrow)
      local lcol = nil
      if (lrow == 0) then
        lcol = (col - a["get-in"](range, {"start", 2}))
      else
        lcol = col
      end
      local original = a.get(lines, line_index)
      local spliced = (string.sub(original, 1, lcol) .. "__prefix__" .. string.sub(original, a.inc(lcol)))
      return str.join("\n", a.assoc(lines, line_index, spliced))
    end
  end
  v_0_ = extract_completion_context0
  _0_0["aniseed/locals"]["extract-completion-context"] = v_0_
  extract_completion_context = v_0_
end
local enhanced_cljs_completion_3f = nil
do
  local v_0_ = nil
  local function enhanced_cljs_completion_3f0()
    return cfg({"completion", "cljs", "use_suitable"})
  end
  v_0_ = enhanced_cljs_completion_3f0
  _0_0["aniseed/locals"]["enhanced-cljs-completion?"] = v_0_
  enhanced_cljs_completion_3f = v_0_
end
local completions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function completions0(opts)
      local function _3_(conn)
        local _4_
        if enhanced_cljs_completion_3f() then
          _4_ = "t"
        else
        _4_ = nil
        end
        local _6_
        if cfg({"completion", "with_context"}) then
          _6_ = extract_completion_context(opts.prefix)
        else
        _6_ = nil
        end
        local function _8_(msgs)
          return opts.cb(a.map(clojure__3evim_completion, a.get(a.last(msgs), "completions")))
        end
        return server.send({["enhanced-cljs-completion?"] = _4_, ["extra-metadata"] = {"arglists", "doc"}, context = _6_, ns = opts.context, op = "complete", session = conn.session, symbol = opts.prefix}, nrepl["with-all-msgs-fn"](_8_))
      end
      return server["with-conn-and-op-or-warn"]("complete", _3_, {["else"] = opts.cb, ["silent?"] = true})
    end
    v_0_0 = completions0
    _0_0["completions"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["completions"] = v_0_
  completions = v_0_
end
local out_subscribe = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function out_subscribe0()
      try_ensure_conn()
      log.append({"; Subscribing to out"}, {["break?"] = true})
      local function _3_(conn)
        return server.send({op = "out-subscribe"})
      end
      return server["with-conn-and-op-or-warn"]("out-subscribe", _3_)
    end
    v_0_0 = out_subscribe0
    _0_0["out-subscribe"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["out-subscribe"] = v_0_
  out_subscribe = v_0_
end
local out_unsubscribe = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function out_unsubscribe0()
      try_ensure_conn()
      log.append({"; Unsubscribing from out"}, {["break?"] = true})
      local function _3_(conn)
        return server.send({op = "out-unsubscribe"})
      end
      return server["with-conn-and-op-or-warn"]("out-unsubscribe", _3_)
    end
    v_0_0 = out_unsubscribe0
    _0_0["out-unsubscribe"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["out-unsubscribe"] = v_0_
  out_unsubscribe = v_0_
end
return nil