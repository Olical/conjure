local _0_0 = nil
do
  local name_23_0_ = "conjure.lang.clojure-nrepl"
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
  _0_0["aniseed/local-fns"] = {require = {["bencode-stream"] = "conjure.bencode-stream", a = "conjure.aniseed.core", bencode = "conjure.bencode", bridge = "conjure.bridge", editor = "conjure.editor", eval = "conjure.aniseed.eval", extract = "conjure.extract", lang = "conjure.lang", ll = "conjure.linked-list", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", uuid = "conjure.uuid", view = "conjure.aniseed.view"}}
  return {require("conjure.aniseed.core"), require("conjure.bencode"), require("conjure.bencode-stream"), require("conjure.bridge"), require("conjure.editor"), require("conjure.aniseed.eval"), require("conjure.extract"), require("conjure.lang"), require("conjure.linked-list"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.uuid"), require("conjure.aniseed.view")}
end
local _2_ = _1_(...)
local a = _2_[1]
local bencode = _2_[2]
local bencode_stream = _2_[3]
local bridge = _2_[4]
local editor = _2_[5]
local eval = _2_[6]
local extract = _2_[7]
local lang = _2_[8]
local ll = _2_[9]
local log = _2_[10]
local mapping = _2_[11]
local nvim = _2_[12]
local str = _2_[13]
local text = _2_[14]
local uuid = _2_[15]
local view = _2_[16]
do local _ = ({nil, _0_0, nil})[2] end
local buf_suffix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = ".cljc"
    _0_0["buf-suffix"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf-suffix"] = v_23_0_
  buf_suffix = v_23_0_
end
local context_pattern = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = "[(]%s*ns%s*(.-)[%s){]"
    _0_0["context-pattern"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["context-pattern"] = v_23_0_
  context_pattern = v_23_0_
end
local comment_prefix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = "; "
    _0_0["comment-prefix"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["comment-prefix"] = v_23_0_
  comment_prefix = v_23_0_
end
local config = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["debug?"] = false, interrupt = {["sample-limit"] = 0.29999999999999999}, mappings = {["connect-port-file"] = "cf", ["last-exception"] = "ex", ["result-1"] = "e1", ["result-2"] = "e2", ["result-3"] = "e3", ["session-clone"] = "sc", ["session-close"] = "sq", ["session-close-all"] = "sQ", ["session-fresh"] = "sf", ["session-list"] = "sl", ["session-next"] = "sn", ["session-prev"] = "sp", ["session-select"] = "ss", ["session-type"] = "st", ["view-source"] = "es", disconnect = "cd", interrupt = "ei"}}
    _0_0["config"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["config"] = v_23_0_
  config = v_23_0_
end
local state = nil
do
  local v_23_0_ = (_0_0["aniseed/locals"].state or {["loaded?"] = false, conn = nil})
  _0_0["aniseed/locals"]["state"] = v_23_0_
  state = v_23_0_
end
local bs = nil
do
  local v_23_0_ = (_0_0["aniseed/locals"].bs or bencode_stream.new())
  _0_0["aniseed/locals"]["bs"] = v_23_0_
  bs = v_23_0_
end
local display = nil
do
  local v_23_0_ = nil
  local function display0(lines, opts)
    return lang["with-filetype"]("clojure", log.append, lines, opts)
  end
  v_23_0_ = display0
  _0_0["aniseed/locals"]["display"] = v_23_0_
  display = v_23_0_
end
local with_conn_or_warn = nil
do
  local v_23_0_ = nil
  local function with_conn_or_warn0(f)
    local conn = a.get(state, "conn")
    if conn then
      return f(conn)
    else
      return display({"; No connection"})
    end
  end
  v_23_0_ = with_conn_or_warn0
  _0_0["aniseed/locals"]["with-conn-or-warn"] = v_23_0_
  with_conn_or_warn = v_23_0_
end
local display_conn_status = nil
do
  local v_23_0_ = nil
  local function display_conn_status0(status)
    local function _3_(conn)
      return display({("; " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
    end
    return with_conn_or_warn(_3_)
  end
  v_23_0_ = display_conn_status0
  _0_0["aniseed/locals"]["display-conn-status"] = v_23_0_
  display_conn_status = v_23_0_
end
local dbg = nil
do
  local v_23_0_ = nil
  local function dbg0(desc, data)
    if config["debug?"] then
      display(a.concat({("; debug " .. desc)}, text["split-lines"](view.serialise(data))))
    end
    return data
  end
  v_23_0_ = dbg0
  _0_0["aniseed/locals"]["dbg"] = v_23_0_
  dbg = v_23_0_
end
local send = nil
do
  local v_23_0_ = nil
  local function send0(msg, cb)
    local conn = a.get(state, "conn")
    if conn then
      local msg_id = uuid.v4()
      a.assoc(msg, "id", msg_id)
      dbg("->", msg)
      local function _3_()
      end
      a["assoc-in"](conn, {"msgs", msg_id}, {["sent-at"] = os.time(), cb = (cb or _3_), msg = msg})
      do end (conn.sock):write(bencode.encode(msg))
      return nil
    end
  end
  v_23_0_ = send0
  _0_0["aniseed/locals"]["send"] = v_23_0_
  send = v_23_0_
end
local status_3d = nil
do
  local v_23_0_ = nil
  local function status_3d0(msg, state0)
    local function _3_(_241)
      return (state0 == _241)
    end
    return (msg and msg.status and a.some(_3_, msg.status))
  end
  v_23_0_ = status_3d0
  _0_0["aniseed/locals"]["status="] = v_23_0_
  status_3d = v_23_0_
end
local with_all_msgs_fn = nil
do
  local v_23_0_ = nil
  local function with_all_msgs_fn0(cb)
    local acc = {}
    local function _3_(msg)
      table.insert(acc, msg)
      if status_3d(msg, "done") then
        return cb(acc)
      end
    end
    return _3_
  end
  v_23_0_ = with_all_msgs_fn0
  _0_0["aniseed/locals"]["with-all-msgs-fn"] = v_23_0_
  with_all_msgs_fn = v_23_0_
end
local disconnect = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function disconnect0()
      local function _3_(conn)
        if not (conn.sock):is_closing() then
          do end (conn.sock):read_stop()
          do end (conn.sock):shutdown()
          do end (conn.sock):close()
        end
        display_conn_status("disconnected")
        return a.assoc(state, "conn", nil)
      end
      return with_conn_or_warn(_3_)
    end
    v_23_0_0 = disconnect0
    _0_0["disconnect"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["disconnect"] = v_23_0_
  disconnect = v_23_0_
end
local display_result = nil
do
  local v_23_0_ = nil
  local function display_result0(opts, resp)
    local lines = nil
    if resp.out then
      lines = text["prefixed-lines"](resp.out, "; (out) ")
    elseif resp.err then
      lines = text["prefixed-lines"](resp.err, "; (err) ")
    elseif resp.value then
      lines = text["split-lines"](resp.value)
    else
      lines = nil
    end
    return display(lines)
  end
  v_23_0_ = display_result0
  _0_0["aniseed/locals"]["display-result"] = v_23_0_
  display_result = v_23_0_
end
local assume_session = nil
do
  local v_23_0_ = nil
  local function assume_session0(session)
    a["assoc-in"](state, {"conn", "session"}, session)
    return display({("; Assumed session: " .. session)}, {["break?"] = true})
  end
  v_23_0_ = assume_session0
  _0_0["aniseed/locals"]["assume-session"] = v_23_0_
  assume_session = v_23_0_
end
local clone_session = nil
do
  local v_23_0_ = nil
  local function clone_session0(session)
    local function _3_(msgs)
      return assume_session(a.get(a.last(msgs), "new-session"))
    end
    return send({op = "clone", session = session}, with_all_msgs_fn(_3_))
  end
  v_23_0_ = clone_session0
  _0_0["aniseed/locals"]["clone-session"] = v_23_0_
  clone_session = v_23_0_
end
local with_sessions = nil
do
  local v_23_0_ = nil
  local function with_sessions0(cb)
    local function _3_(_)
      local function _4_(msg)
        local sessions = nil
        local function _5_(session)
          return (msg.session ~= session)
        end
        sessions = a.filter(_5_, a.get(msg, "sessions"))
        table.sort(sessions)
        return cb(sessions)
      end
      return send({op = "ls-sessions"}, _4_)
    end
    return with_conn_or_warn(_3_)
  end
  v_23_0_ = with_sessions0
  _0_0["aniseed/locals"]["with-sessions"] = v_23_0_
  with_sessions = v_23_0_
end
local eval_str_raw = nil
do
  local v_23_0_ = nil
  local function eval_str_raw0(opts, cb)
    local function _3_(_)
      local _5_
      do
        local _4_0 = a["get-in"](opts, {"range", "start", 2})
        if _4_0 then
          _5_ = a.inc(_4_0)
        else
          _5_ = _4_0
        end
      end
      return send({code = opts.code, column = _5_, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), op = "eval", session = a["get-in"](state, {"conn", "session"})}, cb)
    end
    return with_conn_or_warn(_3_)
  end
  v_23_0_ = eval_str_raw0
  _0_0["aniseed/locals"]["eval-str-raw"] = v_23_0_
  eval_str_raw = v_23_0_
end
local display_session_type = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_session_type0()
      local function _3_(msgs)
        return display({("; Session type: " .. a.get(a.first(msgs), "value"))}, {["break?"] = true})
      end
      return eval_str_raw({code = ("#?(" .. str.join(" ", {":clj 'Clojure", ":cljs 'ClojureScript", ":cljr 'ClojureCLR", ":default 'Unknown"}) .. ")")}, with_all_msgs_fn(_3_))
    end
    v_23_0_0 = display_session_type0
    _0_0["display-session-type"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-session-type"] = v_23_0_
  display_session_type = v_23_0_
end
local assume_or_create_session = nil
do
  local v_23_0_ = nil
  local function assume_or_create_session0()
    local function _3_(sessions)
      if a["empty?"](sessions) then
        return clone_session()
      else
        return assume_session(a.first(sessions))
      end
    end
    return with_sessions(_3_)
  end
  v_23_0_ = assume_or_create_session0
  _0_0["aniseed/locals"]["assume-or-create-session"] = v_23_0_
  assume_or_create_session = v_23_0_
end
local handle_read_fn = nil
do
  local v_23_0_ = nil
  local function handle_read_fn0()
    local function _3_(err, chunk)
      local conn = a.get(state, "conn")
      if err then
        return display_conn_status(err)
      elseif not chunk then
        return disconnect()
      else
        local function _4_(msg)
          dbg("<-", msg)
          do
            local cb = nil
            local function _5_(_241)
              return display_result(nil, _241)
            end
            cb = a["get-in"](conn, {"msgs", msg.id, "cb"}, _5_)
            local ok_3f, err0 = pcall(cb, msg)
            if not ok_3f then
              display({("; conjure.lang.clojure-nrepl error: " .. err0)})
            end
            if status_3d(msg, "unknown-session") then
              display({"; Unknown session, correcting"})
              assume_or_create_session()
            end
            if status_3d(msg, "done") then
              return a["assoc-in"](conn, {"msgs", msg.id}, nil)
            end
          end
        end
        return a["run!"](_4_, bencode_stream["decode-all"](bs, chunk))
      end
    end
    return vim.schedule_wrap(_3_)
  end
  v_23_0_ = handle_read_fn0
  _0_0["aniseed/locals"]["handle-read-fn"] = v_23_0_
  handle_read_fn = v_23_0_
end
local handle_connect_fn = nil
do
  local v_23_0_ = nil
  local function handle_connect_fn0()
    local function _3_(err)
      local conn = a.get(state, "conn")
      if err then
        display_conn_status(err)
        return disconnect()
      else
        do end (conn.sock):read_start(handle_read_fn())
        display_conn_status("connected")
        return assume_or_create_session()
      end
    end
    return vim.schedule_wrap(_3_)
  end
  v_23_0_ = handle_connect_fn0
  _0_0["aniseed/locals"]["handle-connect-fn"] = v_23_0_
  handle_connect_fn = v_23_0_
end
local connect = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect0(_3_0)
      local _4_ = _3_0
      local host = _4_["host"]
      local port = _4_["port"]
      do
        local conn = {host = host, msgs = {}, port = port, session = nil, sock = vim.loop.new_tcp()}
        if a.get(state, "conn") then
          disconnect()
        end
        a.assoc(state, "conn", conn)
        return (conn.sock):connect(host, port, handle_connect_fn())
      end
    end
    v_23_0_0 = connect0
    _0_0["connect"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_23_0_
  connect = v_23_0_
end
local connect_port_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect_port_file0()
      local port = nil
      do
        local _3_0 = a.slurp(".nrepl-port")
        if _3_0 then
          port = tonumber(_3_0)
        else
          port = _3_0
        end
      end
      if port then
        return connect({host = "127.0.0.1", port = port})
      else
        return display({"; No .nrepl-port file found"})
      end
    end
    v_23_0_0 = connect_port_file0
    _0_0["connect-port-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect-port-file"] = v_23_0_
  connect_port_file = v_23_0_
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
          local function _4_()
            if context then
              return ("(in-ns '" .. context .. ")")
            else
              return "(in-ns #?(:clj 'user, :cljs 'cljs.user))"
            end
          end
          local function _5_()
          end
          eval_str_raw({code = ("(do " .. _4_() .. " *1)")}, _5_)
        end
        local function _4_(_241)
          return display_result(opts, _241)
        end
        return eval_str_raw(opts, (opts.cb or _4_))
      end
      return with_conn_or_warn(_3_)
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
      local function _3_(msgs)
        local function _4_(_241)
          return a.get(_241, "out")
        end
        return display(text["prefixed-lines"](str.join("\n", a.rest(a.filter(a["string?"], a.map(_4_, msgs)))), "; "))
      end
      return eval_str(a.merge(opts, {cb = with_all_msgs_fn(_3_), code = ("(do (require 'clojure.repl)" .. "    (clojure.repl/doc " .. opts.code .. "))")}))
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
          return display({"; Couldn't find definition."})
        end
      end
      return eval_str(a.merge(opts, {cb = with_all_msgs_fn(_3_), code = ("(mapv #(% (meta #'" .. opts.code .. "))\n      [(comp #(.toString %)\n      (some-fn (comp #?(:clj clojure.java.io/resource :cljs identity)\n      :file) :file))\n      :line :column])")}))
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
        return display_result(opts, _241)
      end
      return eval_str_raw(a.assoc(opts, "code", ("(load-file \"" .. opts["file-path"] .. "\")")), _3_)
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
          return display({"; Nothing to interrupt"}, {["break?"] = true})
        else
          local function _5_(a0, b)
            return (a0["sent-at"] < b["sent-at"])
          end
          table.sort(msgs, _5_)
          do
            local oldest = a.first(msgs)
            send({id = oldest.msg.id, op = "interrupt", session = oldest.msg.session})
            return display({("; Interrupted: " .. text["left-sample"](oldest.msg.code, editor["percent-width"](config.interrupt["sample-limit"])))}, {["break?"] = true})
          end
        end
      end
      return with_conn_or_warn(_3_)
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
        display({("; source (word): " .. word)}, {["break?"] = true})
        local function _3_(msgs)
          local source = nil
          local function _4_(_241)
            return a.get(_241, "out")
          end
          source = str.join("\n", a.filter(a["string?"], a.map(_4_, msgs)))
          local function _5_()
            if ("Source not found\n" == source) then
              return ("; " .. source)
            else
              return source
            end
          end
          return display(text["split-lines"](_5_()))
        end
        return eval_str({cb = with_all_msgs_fn(_3_), code = ("(do (require 'clojure.repl)" .. "(clojure.repl/source " .. word .. "))"), context = extract.context()})
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
        return clone_session(a.get(conn, "session"))
      end
      return with_conn_or_warn(_3_)
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
        return clone_session()
      end
      return with_conn_or_warn(_3_)
    end
    v_23_0_0 = clone_fresh_session0
    _0_0["clone-fresh-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["clone-fresh-session"] = v_23_0_
  clone_fresh_session = v_23_0_
end
local close_session = nil
do
  local v_23_0_ = nil
  local function close_session0(session, cb)
    return send({op = "close", session = session}, cb)
  end
  v_23_0_ = close_session0
  _0_0["aniseed/locals"]["close-session"] = v_23_0_
  close_session = v_23_0_
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
        display({("; Closed current session: " .. session)}, {["break?"] = true})
        return close_session(session, assume_or_create_session)
      end
      return with_conn_or_warn(_3_)
    end
    v_23_0_0 = close_current_session0
    _0_0["close-current-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-current-session"] = v_23_0_
  close_current_session = v_23_0_
end
local display_given_sessions = nil
do
  local v_23_0_ = nil
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
  v_23_0_ = display_given_sessions0
  _0_0["aniseed/locals"]["display-given-sessions"] = v_23_0_
  display_given_sessions = v_23_0_
end
local display_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_sessions0(cb)
      local function _3_(sessions)
        return display_given_sessions(sessions, cb)
      end
      return with_sessions(_3_)
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
        a["run!"](close_session, sessions)
        display({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
        return clone_session()
      end
      return with_sessions(_3_)
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
          return display({"; No other sessions"}, {["break?"] = true})
        else
          local session = a.get(conn, "session")
          local function _5_(_241)
            return f(session, _241)
          end
          return assume_session(ll.val(ll["until"](_5_, ll.cycle(ll.create(sessions)))))
        end
      end
      return with_sessions(_4_)
    end
    return with_conn_or_warn(_3_)
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
          return display({"; No other sessions"}, {["break?"] = true})
        else
          local function _4_()
            nvim.ex.redraw_()
            do
              local n = nvim.fn.str2nr(extract.input("Session number: "))
              local _5_ = a.count(sessions)
              if ((1 <= n) and (n <= _5_)) then
                return assume_session(a.get(sessions, n))
              else
                return display({"; Invalid session number."})
              end
            end
          end
          return display_given_sessions(sessions, _4_)
        end
      end
      return with_sessions(_3_)
    end
    v_23_0_0 = select_session_interactive0
    _0_0["select-session-interactive"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["select-session-interactive"] = v_23_0_
  select_session_interactive = v_23_0_
end
local on_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", config.mappings.disconnect, "conjure.lang.clojure-nrepl", "disconnect")
      mapping.buf("n", config.mappings["connect-port-file"], "conjure.lang.clojure-nrepl", "connect-port-file")
      mapping.buf("n", config.mappings.interrupt, "conjure.lang.clojure-nrepl", "interrupt")
      mapping.buf("n", config.mappings["last-exception"], "conjure.lang.clojure-nrepl", "last-exception")
      mapping.buf("n", config.mappings["result-1"], "conjure.lang.clojure-nrepl", "result-1")
      mapping.buf("n", config.mappings["result-2"], "conjure.lang.clojure-nrepl", "result-2")
      mapping.buf("n", config.mappings["result-3"], "conjure.lang.clojure-nrepl", "result-3")
      mapping.buf("n", config.mappings["view-source"], "conjure.lang.clojure-nrepl", "view-source")
      mapping.buf("n", config.mappings["session-clone"], "conjure.lang.clojure-nrepl", "clone-current-session")
      mapping.buf("n", config.mappings["session-fresh"], "conjure.lang.clojure-nrepl", "clone-fresh-session")
      mapping.buf("n", config.mappings["session-close"], "conjure.lang.clojure-nrepl", "close-current-session")
      mapping.buf("n", config.mappings["session-close-all"], "conjure.lang.clojure-nrepl", "close-all-sessions")
      mapping.buf("n", config.mappings["session-list"], "conjure.lang.clojure-nrepl", "display-sessions")
      mapping.buf("n", config.mappings["session-next"], "conjure.lang.clojure-nrepl", "next-session")
      mapping.buf("n", config.mappings["session-prev"], "conjure.lang.clojure-nrepl", "prev-session")
      mapping.buf("n", config.mappings["session-select"], "conjure.lang.clojure-nrepl", "select-session-interactive")
      return mapping.buf("n", config.mappings["session-type"], "conjure.lang.clojure-nrepl", "display-session-type")
    end
    v_23_0_0 = on_filetype0
    _0_0["on-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_23_0_
  on_filetype = v_23_0_
end
if not state["loaded?"] then
  a.assoc(state, "loaded?", true)
  local function _3_()
    nvim.ex.augroup("conjure_clojure_nrepl_cleanup")
    nvim.ex.autocmd_()
    nvim.ex.autocmd("VimLeavePre *", bridge["viml->lua"]("conjure.lang.clojure-nrepl", "disconnect", {}))
    nvim.ex.augroup("END")
    return connect_port_file()
  end
  return vim.schedule(_3_)
end