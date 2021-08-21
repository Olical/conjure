local _2afile_2a = "fnl/conjure/client/clojure/nrepl/action.fnl"
local _1_
do
  local name_4_auto = "conjure.client.clojure.nrepl.action"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.aniseed.eval"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.linked-list"), autoload("conjure.log"), autoload("conjure.remote.nrepl"), autoload("conjure.aniseed.nvim"), autoload("conjure.client.clojure.nrepl.parse"), autoload("conjure.process"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.client.clojure.nrepl.ui"), autoload("conjure.aniseed.view")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", eval = "conjure.aniseed.eval", extract = "conjure.extract", fs = "conjure.fs", ll = "conjure.linked-list", log = "conjure.log", nrepl = "conjure.remote.nrepl", nvim = "conjure.aniseed.nvim", parse = "conjure.client.clojure.nrepl.parse", process = "conjure.process", server = "conjure.client.clojure.nrepl.server", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text", ui = "conjure.client.clojure.nrepl.ui", view = "conjure.aniseed.view"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nrepl = _local_4_[10]
local nvim = _local_4_[11]
local parse = _local_4_[12]
local process = _local_4_[13]
local server = _local_4_[14]
local state = _local_4_[15]
local str = _local_4_[16]
local text = _local_4_[17]
local ui = _local_4_[18]
local view = _local_4_[19]
local client = _local_4_[2]
local config = _local_4_[3]
local editor = _local_4_[4]
local eval = _local_4_[5]
local extract = _local_4_[6]
local fs = _local_4_[7]
local ll = _local_4_[8]
local log = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.clojure.nrepl.action"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local require_ns
do
  local v_23_auto
  local function require_ns0(ns)
    if ns then
      local function _8_()
      end
      return server.eval({code = ("(require '" .. ns .. ")")}, _8_)
    end
  end
  v_23_auto = require_ns0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["require-ns"] = v_23_auto
  require_ns = v_23_auto
end
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "clojure", "nrepl"})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
local passive_ns_require
do
  local v_23_auto
  do
    local v_25_auto
    local function passive_ns_require0()
      if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
        return require_ns(extract.context())
      end
    end
    v_25_auto = passive_ns_require0
    _1_["passive-ns-require"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["passive-ns-require"] = v_23_auto
  passive_ns_require = v_23_auto
end
local delete_auto_repl_port_file
do
  local v_23_auto
  do
    local v_25_auto
    local function delete_auto_repl_port_file0()
      local port_file = cfg({"connection", "auto_repl", "port_file"})
      local port = cfg({"connection", "auto_repl", "port"})
      if (port_file and port and (a.slurp(port_file) == port)) then
        return nvim.fn.delete(port_file)
      end
    end
    v_25_auto = delete_auto_repl_port_file0
    _1_["delete-auto-repl-port-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["delete-auto-repl-port-file"] = v_23_auto
  delete_auto_repl_port_file = v_23_auto
end
local upsert_auto_repl_proc
do
  local v_23_auto
  local function upsert_auto_repl_proc0()
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
      end
      log.append({("; Starting auto-repl: " .. cmd)})
      return proc
    end
  end
  v_23_auto = upsert_auto_repl_proc0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["upsert-auto-repl-proc"] = v_23_auto
  upsert_auto_repl_proc = v_23_auto
end
local connect_port_file
do
  local v_23_auto
  do
    local v_25_auto
    local function connect_port_file0(opts)
      local resolved
      do
        local _14_ = cfg({"connection", "port_files"})
        if _14_ then
          local _15_ = a.map(fs["resolve-above"], _14_)
          if _15_ then
            local function _16_(path)
              local port = a.slurp(path)
              if port then
                return {path = path, port = tonumber(port)}
              end
            end
            resolved = a.some(_16_, _15_)
          else
            resolved = _15_
          end
        else
          resolved = _14_
        end
      end
      if resolved then
        local function _20_()
          do
            local cb = a.get(opts, "cb")
            if cb then
              cb()
            end
          end
          return passive_ns_require()
        end
        local _23_
        do
          local t_22_ = resolved
          if (nil ~= t_22_) then
            t_22_ = (t_22_).port
          end
          _23_ = t_22_
        end
        local _26_
        do
          local t_25_ = resolved
          if (nil ~= t_25_) then
            t_25_ = (t_25_).path
          end
          _26_ = t_25_
        end
        return server.connect({cb = _20_, host = cfg({"connection", "default_host"}), port = _23_, port_file_path = _26_})
      else
        if not a.get(opts, "silent?") then
          log.append({"; No nREPL port file found"}, {["break?"] = true})
          return upsert_auto_repl_proc()
        end
      end
    end
    v_25_auto = connect_port_file0
    _1_["connect-port-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect-port-file"] = v_23_auto
  connect_port_file = v_23_auto
end
local try_ensure_conn
do
  local v_23_auto
  local function try_ensure_conn0(cb)
    if not server["connected?"]() then
      return connect_port_file({["silent?"] = true, cb = cb})
    else
      if cb then
        return cb()
      end
    end
  end
  v_23_auto = try_ensure_conn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["try-ensure-conn"] = v_23_auto
  try_ensure_conn = v_23_auto
end
local connect_host_port
do
  local v_23_auto
  do
    local v_25_auto
    local function connect_host_port0(opts)
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
          return server.connect({cb = passive_ns_require, host = (opts.host or cfg({"connection", "default_host"})), port = parsed_port})
        else
          return log.append({("; Could not parse '" .. opts.port .. "' as a port number")})
        end
      end
    end
    v_25_auto = connect_host_port0
    _1_["connect-host-port"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect-host-port"] = v_23_auto
  connect_host_port = v_23_auto
end
local eval_cb_fn
do
  local v_23_auto
  local function eval_cb_fn0(opts)
    local function _35_(resp)
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
    return _35_
  end
  v_23_auto = eval_cb_fn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-cb-fn"] = v_23_auto
  eval_cb_fn = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      local function _39_()
        local function _40_(conn)
          if (opts.context and not a["get-in"](conn, {"seen-ns", opts.context})) then
            local function _41_()
            end
            server.eval({code = ("(ns " .. opts.context .. ")")}, _41_)
            a["assoc-in"](conn, {"seen-ns", opts.context}, true)
          end
          return server.eval(opts, eval_cb_fn(opts))
        end
        return server["with-conn-or-warn"](_40_)
      end
      return try_ensure_conn(_39_)
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local with_info
do
  local v_23_auto
  local function with_info0(opts, f)
    local function _43_(conn)
      local function _44_(msg)
        local function _45_()
          if not msg.status["no-info"] then
            return msg
          end
        end
        return f(_45_())
      end
      return server.send({ns = (opts.context or "user"), op = "info", session = conn.session, symbol = opts.code}, _44_)
    end
    return server["with-conn-and-op-or-warn"]("info", _43_)
  end
  v_23_auto = with_info0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-info"] = v_23_auto
  with_info = v_23_auto
end
local java_info__3elines
do
  local v_23_auto
  local function java_info__3elines0(_46_)
    local _arg_47_ = _46_
    local arglists_str = _arg_47_["arglists-str"]
    local class = _arg_47_["class"]
    local javadoc = _arg_47_["javadoc"]
    local member = _arg_47_["member"]
    local function _48_()
      if member then
        return {"/", member}
      end
    end
    local _49_
    if not a["empty?"](arglists_str) then
      _49_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
    else
    _49_ = nil
    end
    local function _51_()
      if javadoc then
        return {("; " .. javadoc)}
      end
    end
    return a.concat({str.join(a.concat({"; ", class}, _48_()))}, _49_, _51_())
  end
  v_23_auto = java_info__3elines0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["java-info->lines"] = v_23_auto
  java_info__3elines = v_23_auto
end
local doc_str
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_str0(opts)
      local function _52_()
        require_ns("clojure.repl")
        local function _53_(msgs)
          local function _54_(msg)
            return (a.get(msg, "out") or a.get(msg, "err"))
          end
          if a.some(_54_, msgs) then
            local function _55_(_241)
              return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
            end
            return a["run!"](_55_, msgs)
          else
            log.append({"; No results, checking CIDER's info op"})
            local function _56_(info)
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
            return with_info(opts, _56_)
          end
        end
        return server.eval(a.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_53_))
      end
      return try_ensure_conn(_52_)
    end
    v_25_auto = doc_str0
    _1_["doc-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local nrepl__3envim_path
do
  local v_23_auto
  local function nrepl__3envim_path0(path)
    if text["starts-with"](path, "jar:file:") then
      local function _59_(zip, file)
        return ("zipfile:" .. zip .. "::" .. file)
      end
      return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _59_)
    elseif text["starts-with"](path, "file:") then
      local function _60_(file)
        return file
      end
      return string.gsub(path, "^file:(.+)$", _60_)
    else
      return path
    end
  end
  v_23_auto = nrepl__3envim_path0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["nrepl->nvim-path"] = v_23_auto
  nrepl__3envim_path = v_23_auto
end
local def_str
do
  local v_23_auto
  do
    local v_25_auto
    local function def_str0(opts)
      local function _62_()
        local function _63_(info)
          if a["nil?"](info) then
            return log.append({"; No definition information found"})
          elseif info.candidates then
            local function _64_(_241)
              return (_241 .. "/" .. opts.code)
            end
            return log.append(a.concat({"; Multiple candidates found"}, a.map(_64_, a.keys(info.candidates))))
          elseif info.javadoc then
            return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
          elseif info["special-form"] then
            local function _65_()
              if info.url then
                return ("; " .. info.url)
              end
            end
            return log.append({"; Can't open source, it's a special form", _65_()})
          elseif (info.file and info.line) then
            local column = (info.column or 1)
            local path = nrepl__3envim_path(info.file)
            editor["go-to"](path, info.line, column)
            return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
          else
            return log.append({"; Unsupported target", ("; " .. a["pr-str"](info))})
          end
        end
        return with_info(opts, _63_)
      end
      return try_ensure_conn(_62_)
    end
    v_25_auto = def_str0
    _1_["def-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["def-str"] = v_23_auto
  def_str = v_23_auto
end
local eval_file
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_file0(opts)
      local function _67_()
        return server.eval(a.assoc(opts, "code", ("(#?(:cljs cljs.core/load-file" .. " :default clojure.core/load-file)" .. " \"" .. opts["file-path"] .. "\")")), eval_cb_fn(opts))
      end
      return try_ensure_conn(_67_)
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local interrupt
do
  local v_23_auto
  do
    local v_25_auto
    local function interrupt0()
      local function _68_()
        local function _69_(conn)
          local msgs
          local function _70_(msg)
            return ("eval" == msg.msg.op)
          end
          msgs = a.filter(_70_, a.vals(conn.msgs))
          local order_66
          local function _73_(_71_)
            local _arg_72_ = _71_
            local code = _arg_72_["code"]
            local id = _arg_72_["id"]
            local session = _arg_72_["session"]
            server.send({["interrupt-id"] = id, op = "interrupt", session = session})
            local function _74_(sess)
              local _75_
              if code then
                _75_ = text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
              else
                _75_ = ("session: " .. sess.str() .. "")
              end
              return log.append({("; Interrupted: " .. _75_)}, {["break?"] = true})
            end
            return server["enrich-session-id"](session, _74_)
          end
          order_66 = _73_
          if a["empty?"](msgs) then
            return order_66({session = conn.session})
          else
            local function _77_(a0, b)
              return (a0["sent-at"] < b["sent-at"])
            end
            table.sort(msgs, _77_)
            return order_66(a.get(a.first(msgs), "msg"))
          end
        end
        return server["with-conn-or-warn"](_69_)
      end
      return try_ensure_conn(_68_)
    end
    v_25_auto = interrupt0
    _1_["interrupt"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["interrupt"] = v_23_auto
  interrupt = v_23_auto
end
local eval_str_fn
do
  local v_23_auto
  local function eval_str_fn0(code)
    local function _79_()
      return nvim.ex.ConjureEval(code)
    end
    return _79_
  end
  v_23_auto = eval_str_fn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str-fn"] = v_23_auto
  eval_str_fn = v_23_auto
end
local last_exception
do
  local v_23_auto
  do
    local v_25_auto = eval_str_fn("*e")
    do end (_1_)["last-exception"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["last-exception"] = v_23_auto
  last_exception = v_23_auto
end
local result_1
do
  local v_23_auto
  do
    local v_25_auto = eval_str_fn("*1")
    do end (_1_)["result-1"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["result-1"] = v_23_auto
  result_1 = v_23_auto
end
local result_2
do
  local v_23_auto
  do
    local v_25_auto = eval_str_fn("*2")
    do end (_1_)["result-2"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["result-2"] = v_23_auto
  result_2 = v_23_auto
end
local result_3
do
  local v_23_auto
  do
    local v_25_auto = eval_str_fn("*3")
    do end (_1_)["result-3"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["result-3"] = v_23_auto
  result_3 = v_23_auto
end
local view_source
do
  local v_23_auto
  do
    local v_25_auto
    local function view_source0()
      local function _80_()
        local word = a.get(extract.word(), "content")
        if not a["empty?"](word) then
          log.append({("; source (word): " .. word)}, {["break?"] = true})
          require_ns("clojure.repl")
          local function _81_(_241)
            return ui["display-result"](_241, {["ignore-nil?"] = true, ["raw-out?"] = true})
          end
          return eval_str({cb = _81_, code = ("(clojure.repl/source " .. word .. ")"), context = extract.context()})
        end
      end
      return try_ensure_conn(_80_)
    end
    v_25_auto = view_source0
    _1_["view-source"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["view-source"] = v_23_auto
  view_source = v_23_auto
end
local clone_current_session
do
  local v_23_auto
  do
    local v_25_auto
    local function clone_current_session0()
      local function _83_()
        local function _84_(conn)
          return server["enrich-session-id"](a.get(conn, "session"), server["clone-session"])
        end
        return server["with-conn-or-warn"](_84_)
      end
      return try_ensure_conn(_83_)
    end
    v_25_auto = clone_current_session0
    _1_["clone-current-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["clone-current-session"] = v_23_auto
  clone_current_session = v_23_auto
end
local clone_fresh_session
do
  local v_23_auto
  do
    local v_25_auto
    local function clone_fresh_session0()
      local function _85_()
        local function _86_(conn)
          return server["clone-session"]()
        end
        return server["with-conn-or-warn"](_86_)
      end
      return try_ensure_conn(_85_)
    end
    v_25_auto = clone_fresh_session0
    _1_["clone-fresh-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["clone-fresh-session"] = v_23_auto
  clone_fresh_session = v_23_auto
end
local close_current_session
do
  local v_23_auto
  do
    local v_25_auto
    local function close_current_session0()
      local function _87_()
        local function _88_(conn)
          local function _89_(sess)
            a.assoc(conn, "session", nil)
            log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
            local function _90_()
              return server["assume-or-create-session"]()
            end
            return server["close-session"](sess, _90_)
          end
          return server["enrich-session-id"](a.get(conn, "session"), _89_)
        end
        return server["with-conn-or-warn"](_88_)
      end
      return try_ensure_conn(_87_)
    end
    v_25_auto = close_current_session0
    _1_["close-current-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["close-current-session"] = v_23_auto
  close_current_session = v_23_auto
end
local display_sessions
do
  local v_23_auto
  do
    local v_25_auto
    local function display_sessions0(cb)
      local function _91_()
        local function _92_(sessions)
          return ui["display-sessions"](sessions, cb)
        end
        return server["with-sessions"](_92_)
      end
      return try_ensure_conn(_91_)
    end
    v_25_auto = display_sessions0
    _1_["display-sessions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-sessions"] = v_23_auto
  display_sessions = v_23_auto
end
local close_all_sessions
do
  local v_23_auto
  do
    local v_25_auto
    local function close_all_sessions0()
      local function _93_()
        local function _94_(sessions)
          a["run!"](server["close-session"], sessions)
          log.append({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
          return server["clone-session"]()
        end
        return server["with-sessions"](_94_)
      end
      return try_ensure_conn(_93_)
    end
    v_25_auto = close_all_sessions0
    _1_["close-all-sessions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["close-all-sessions"] = v_23_auto
  close_all_sessions = v_23_auto
end
local cycle_session
do
  local v_23_auto
  local function cycle_session0(f)
    local function _95_()
      local function _96_(conn)
        local function _97_(sessions)
          if (1 == a.count(sessions)) then
            return log.append({"; No other sessions"}, {["break?"] = true})
          else
            local session = a.get(conn, "session")
            local function _98_(_241)
              return f(session, _241)
            end
            return server["assume-session"](ll.val(ll["until"](_98_, ll.cycle(ll.create(sessions)))))
          end
        end
        return server["with-sessions"](_97_)
      end
      return server["with-conn-or-warn"](_96_)
    end
    return try_ensure_conn(_95_)
  end
  v_23_auto = cycle_session0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cycle-session"] = v_23_auto
  cycle_session = v_23_auto
end
local next_session
do
  local v_23_auto
  do
    local v_25_auto
    local function next_session0()
      local function _100_(current, node)
        return (current == a.get(ll.val(ll.prev(node)), "id"))
      end
      return cycle_session(_100_)
    end
    v_25_auto = next_session0
    _1_["next-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["next-session"] = v_23_auto
  next_session = v_23_auto
end
local prev_session
do
  local v_23_auto
  do
    local v_25_auto
    local function prev_session0()
      local function _101_(current, node)
        return (current == a.get(ll.val(ll.next(node)), "id"))
      end
      return cycle_session(_101_)
    end
    v_25_auto = prev_session0
    _1_["prev-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["prev-session"] = v_23_auto
  prev_session = v_23_auto
end
local select_session_interactive
do
  local v_23_auto
  do
    local v_25_auto
    local function select_session_interactive0()
      local function _102_()
        local function _103_(sessions)
          if (1 == a.count(sessions)) then
            return log.append({"; No other sessions"}, {["break?"] = true})
          else
            local function _104_()
              nvim.ex.redraw_()
              local n = nvim.fn.str2nr(extract.prompt("Session number: "))
              if (function(_105_,_106_,_107_) return (_105_ <= _106_) and (_106_ <= _107_) end)(1,n,a.count(sessions)) then
                return server["assume-session"](a.get(sessions, n))
              else
                return log.append({"; Invalid session number."})
              end
            end
            return ui["display-sessions"](sessions, _104_)
          end
        end
        return server["with-sessions"](_103_)
      end
      return try_ensure_conn(_102_)
    end
    v_25_auto = select_session_interactive0
    _1_["select-session-interactive"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["select-session-interactive"] = v_23_auto
  select_session_interactive = v_23_auto
end
local test_runners
do
  local v_23_auto = {clojure = {["all-fn"] = "run-all-tests", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", namespace = "clojure.test"}, kaocha = {["all-fn"] = "run-all", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = "", ["ns-fn"] = "run", ["single-fn"] = "run", namespace = "kaocha.repl"}}
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["test-runners"] = v_23_auto
  test_runners = v_23_auto
end
local test_cfg
do
  local v_23_auto
  local function test_cfg0(k)
    local runner = cfg({"test", "runner"})
    return (a["get-in"](test_runners, {runner, k}) or error(str.join({"No test-runners configuration for ", runner, " / ", k})))
  end
  v_23_auto = test_cfg0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["test-cfg"] = v_23_auto
  test_cfg = v_23_auto
end
local require_test_runner
do
  local v_23_auto
  local function require_test_runner0()
    return require_ns(test_cfg("namespace"))
  end
  v_23_auto = require_test_runner0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["require-test-runner"] = v_23_auto
  require_test_runner = v_23_auto
end
local test_runner_code
do
  local v_23_auto
  local function test_runner_code0(fn_config_name, ...)
    return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
  end
  v_23_auto = test_runner_code0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["test-runner-code"] = v_23_auto
  test_runner_code = v_23_auto
end
local run_all_tests
do
  local v_23_auto
  do
    local v_25_auto
    local function run_all_tests0()
      local function _110_()
        log.append({"; run-all-tests"}, {["break?"] = true})
        require_test_runner()
        local function _111_(_241)
          return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
        end
        return server.eval({code = test_runner_code("all")}, _111_)
      end
      return try_ensure_conn(_110_)
    end
    v_25_auto = run_all_tests0
    _1_["run-all-tests"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-all-tests"] = v_23_auto
  run_all_tests = v_23_auto
end
local run_ns_tests
do
  local v_23_auto
  local function run_ns_tests0(ns)
    local function _112_()
      if ns then
        log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
        require_test_runner()
        local function _113_(_241)
          return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
        end
        return server.eval({code = test_runner_code("ns", ("'" .. ns))}, _113_)
      end
    end
    return try_ensure_conn(_112_)
  end
  v_23_auto = run_ns_tests0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-ns-tests"] = v_23_auto
  run_ns_tests = v_23_auto
end
local run_current_ns_tests
do
  local v_23_auto
  do
    local v_25_auto
    local function run_current_ns_tests0()
      return run_ns_tests(extract.context())
    end
    v_25_auto = run_current_ns_tests0
    _1_["run-current-ns-tests"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-current-ns-tests"] = v_23_auto
  run_current_ns_tests = v_23_auto
end
local run_alternate_ns_tests
do
  local v_23_auto
  do
    local v_25_auto
    local function run_alternate_ns_tests0()
      local current_ns = extract.context()
      local function _115_()
        if text["ends-with"](current_ns, "-test") then
          return string.sub(current_ns, 1, -6)
        else
          return (current_ns .. "-test")
        end
      end
      return run_ns_tests(_115_())
    end
    v_25_auto = run_alternate_ns_tests0
    _1_["run-alternate-ns-tests"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-alternate-ns-tests"] = v_23_auto
  run_alternate_ns_tests = v_23_auto
end
local extract_test_name_from_form
do
  local v_23_auto
  do
    local v_25_auto
    local function extract_test_name_from_form0(form)
      local seen_deftest_3f = false
      local function _116_(part)
        local function _117_(config_current_form_name)
          return text["ends-with"](part, config_current_form_name)
        end
        if a.some(_117_, cfg({"test", "current_form_names"})) then
          seen_deftest_3f = true
          return false
        elseif seen_deftest_3f then
          return part
        end
      end
      return a.some(_116_, str.split(parse["strip-meta"](form), "%s+"))
    end
    v_25_auto = extract_test_name_from_form0
    _1_["extract-test-name-from-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["extract-test-name-from-form"] = v_23_auto
  extract_test_name_from_form = v_23_auto
end
local run_current_test
do
  local v_23_auto
  do
    local v_25_auto
    local function run_current_test0()
      local function _119_()
        local form = extract.form({["root?"] = true})
        if form then
          local test_name = extract_test_name_from_form(form.content)
          if test_name then
            log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
            require_test_runner()
            local function _120_(msgs)
              if ((2 == a.count(msgs)) and ("nil" == a.get(a.first(msgs), "value"))) then
                return log.append({"; Success!"})
              else
                local function _121_(_241)
                  return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
                end
                return a["run!"](_121_, msgs)
              end
            end
            return server.eval({code = test_runner_code("single", (test_cfg("name-prefix") .. test_name .. test_cfg("name-suffix"))), context = extract.context()}, nrepl["with-all-msgs-fn"](_120_))
          end
        end
      end
      return try_ensure_conn(_119_)
    end
    v_25_auto = run_current_test0
    _1_["run-current-test"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-current-test"] = v_23_auto
  run_current_test = v_23_auto
end
local refresh_impl
do
  local v_23_auto
  local function refresh_impl0(op)
    local function _125_(conn)
      local function _126_(msg)
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
      return server.send(a.merge({after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"}), op = op, session = conn.session}), _126_)
    end
    return server["with-conn-and-op-or-warn"](op, _125_)
  end
  v_23_auto = refresh_impl0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["refresh-impl"] = v_23_auto
  refresh_impl = v_23_auto
end
local refresh_changed
do
  local v_23_auto
  do
    local v_25_auto
    local function refresh_changed0()
      local function _128_()
        log.append({"; Refreshing changed namespaces"}, {["break?"] = true})
        return refresh_impl("refresh")
      end
      return try_ensure_conn(_128_)
    end
    v_25_auto = refresh_changed0
    _1_["refresh-changed"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["refresh-changed"] = v_23_auto
  refresh_changed = v_23_auto
end
local refresh_all
do
  local v_23_auto
  do
    local v_25_auto
    local function refresh_all0()
      local function _129_()
        log.append({"; Refreshing all namespaces"}, {["break?"] = true})
        return refresh_impl("refresh-all")
      end
      return try_ensure_conn(_129_)
    end
    v_25_auto = refresh_all0
    _1_["refresh-all"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["refresh-all"] = v_23_auto
  refresh_all = v_23_auto
end
local refresh_clear
do
  local v_23_auto
  do
    local v_25_auto
    local function refresh_clear0()
      local function _130_()
        log.append({"; Clearing refresh cache"}, {["break?"] = true})
        local function _131_(conn)
          local function _132_(msgs)
            return log.append({"; Clearing complete"})
          end
          return server.send({op = "refresh-clear", session = conn.session}, nrepl["with-all-msgs-fn"](_132_))
        end
        return server["with-conn-and-op-or-warn"]("refresh-clear", _131_)
      end
      return try_ensure_conn(_130_)
    end
    v_25_auto = refresh_clear0
    _1_["refresh-clear"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["refresh-clear"] = v_23_auto
  refresh_clear = v_23_auto
end
local shadow_select
do
  local v_23_auto
  do
    local v_25_auto
    local function shadow_select0(build)
      local function _133_()
        local function _134_(conn)
          log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
          server.eval({code = ("(shadow.cljs.devtools.api/nrepl-select :" .. build .. ")")}, ui["display-result"])
          return passive_ns_require()
        end
        return server["with-conn-or-warn"](_134_)
      end
      return try_ensure_conn(_133_)
    end
    v_25_auto = shadow_select0
    _1_["shadow-select"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["shadow-select"] = v_23_auto
  shadow_select = v_23_auto
end
local piggieback
do
  local v_23_auto
  do
    local v_25_auto
    local function piggieback0(code)
      local function _135_()
        local function _136_(conn)
          log.append({("; piggieback: " .. code)}, {["break?"] = true})
          require_ns("cider.piggieback")
          server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
          return passive_ns_require()
        end
        return server["with-conn-or-warn"](_136_)
      end
      return try_ensure_conn(_135_)
    end
    v_25_auto = piggieback0
    _1_["piggieback"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["piggieback"] = v_23_auto
  piggieback = v_23_auto
end
local clojure__3evim_completion
do
  local v_23_auto
  local function clojure__3evim_completion0(_137_)
    local _arg_138_ = _137_
    local arglists = _arg_138_["arglists"]
    local word = _arg_138_["candidate"]
    local info = _arg_138_["doc"]
    local ns = _arg_138_["ns"]
    local kind = _arg_138_["type"]
    local _139_
    if ("string" == type(info)) then
      _139_ = info
    else
    _139_ = nil
    end
    local _141_
    if not a["empty?"](kind) then
      _141_ = string.upper(string.sub(kind, 1, 1))
    else
    _141_ = nil
    end
    local function _143_()
      if arglists then
        return table.concat(arglists, " ")
      end
    end
    return {info = _139_, kind = _141_, menu = table.concat({ns, _143_()}, " "), word = word}
  end
  v_23_auto = clojure__3evim_completion0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["clojure->vim-completion"] = v_23_auto
  clojure__3evim_completion = v_23_auto
end
local extract_completion_context
do
  local v_23_auto
  local function extract_completion_context0(prefix)
    local root_form = extract.form({["root?"] = true})
    if root_form then
      local _let_144_ = root_form
      local content = _let_144_["content"]
      local range = _let_144_["range"]
      local lines = text["split-lines"](content)
      local _let_145_ = nvim.win_get_cursor(0)
      local row = _let_145_[1]
      local col = _let_145_[2]
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
    end
  end
  v_23_auto = extract_completion_context0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["extract-completion-context"] = v_23_auto
  extract_completion_context = v_23_auto
end
local enhanced_cljs_completion_3f
do
  local v_23_auto
  local function enhanced_cljs_completion_3f0()
    return cfg({"completion", "cljs", "use_suitable"})
  end
  v_23_auto = enhanced_cljs_completion_3f0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["enhanced-cljs-completion?"] = v_23_auto
  enhanced_cljs_completion_3f = v_23_auto
end
local completions
do
  local v_23_auto
  do
    local v_25_auto
    local function completions0(opts)
      local function _148_(conn)
        local _149_
        if enhanced_cljs_completion_3f() then
          _149_ = "t"
        else
        _149_ = nil
        end
        local _151_
        if cfg({"completion", "with_context"}) then
          _151_ = extract_completion_context(opts.prefix)
        else
        _151_ = nil
        end
        local function _153_(msgs)
          return opts.cb(a.map(clojure__3evim_completion, a.get(a.last(msgs), "completions")))
        end
        return server.send({["enhanced-cljs-completion?"] = _149_, ["extra-metadata"] = {"arglists", "doc"}, context = _151_, ns = opts.context, op = "complete", session = conn.session, symbol = opts.prefix}, nrepl["with-all-msgs-fn"](_153_))
      end
      return server["with-conn-and-op-or-warn"]("complete", _148_, {["else"] = opts.cb, ["silent?"] = true})
    end
    v_25_auto = completions0
    _1_["completions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["completions"] = v_23_auto
  completions = v_23_auto
end
local out_subscribe
do
  local v_23_auto
  do
    local v_25_auto
    local function out_subscribe0()
      try_ensure_conn()
      log.append({"; Subscribing to out"}, {["break?"] = true})
      local function _154_(conn)
        return server.send({op = "out-subscribe"})
      end
      return server["with-conn-and-op-or-warn"]("out-subscribe", _154_)
    end
    v_25_auto = out_subscribe0
    _1_["out-subscribe"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["out-subscribe"] = v_23_auto
  out_subscribe = v_23_auto
end
local out_unsubscribe
do
  local v_23_auto
  do
    local v_25_auto
    local function out_unsubscribe0()
      try_ensure_conn()
      log.append({"; Unsubscribing from out"}, {["break?"] = true})
      local function _155_(conn)
        return server.send({op = "out-unsubscribe"})
      end
      return server["with-conn-and-op-or-warn"]("out-unsubscribe", _155_)
    end
    v_25_auto = out_unsubscribe0
    _1_["out-unsubscribe"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["out-unsubscribe"] = v_23_auto
  out_unsubscribe = v_23_auto
end
return nil