local _0_0 = nil
do
  local name_23_0_ = "conjure.client.janet.netrepl"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bit = "bit", bridge = "conjure.bridge", client = "conjure.client", log = "conjure.log", mapping = "conjure.mapping", net = "conjure.net", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", view = "conjure.aniseed.view"}}
  return {require("conjure.aniseed.core"), require("bit"), require("conjure.bridge"), require("conjure.client"), require("conjure.log"), require("conjure.mapping"), require("conjure.net"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.aniseed.view")}
end
local _2_ = _1_(...)
local a = _2_[1]
local text = _2_[10]
local view = _2_[11]
local bit = _2_[2]
local bridge = _2_[3]
local client = _2_[4]
local log = _2_[5]
local mapping = _2_[6]
local net = _2_[7]
local nvim = _2_[8]
local str = _2_[9]
do local _ = ({nil, _0_0, nil})[2] end
local buf_suffix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = ".janet"
    _0_0["buf-suffix"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf-suffix"] = v_23_0_
  buf_suffix = v_23_0_
end
local comment_prefix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = "# "
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
    local v_23_0_0 = {["debug?"] = false, connection = {["default-host"] = "127.0.0.1", ["default-port"] = "9365"}, mappings = {connect = "cc", disconnect = "cd"}}
    _0_0["config"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["config"] = v_23_0_
  config = v_23_0_
end
local state = nil
do
  local v_23_0_ = (_0_0["aniseed/locals"].state or {conn = nil})
  _0_0["aniseed/locals"]["state"] = v_23_0_
  state = v_23_0_
end
local display = nil
do
  local v_23_0_ = nil
  local function display0(lines, opts)
    return client["with-filetype"]("janet", log.append, lines, opts)
  end
  v_23_0_ = display0
  _0_0["aniseed/locals"]["display"] = v_23_0_
  display = v_23_0_
end
local dbg = nil
do
  local v_23_0_ = nil
  local function dbg0(desc, data)
    if config["debug?"] then
      display(a.concat({("# debug: " .. desc)}, text["split-lines"](view.serialise(data))))
    end
    return data
  end
  v_23_0_ = dbg0
  _0_0["aniseed/locals"]["dbg"] = v_23_0_
  dbg = v_23_0_
end
local encode = nil
do
  local v_23_0_ = nil
  local function encode0(msg)
    local n = a.count(msg)
    return (string.char(bit.band(n, 255), bit.band(bit.rshift(n, 8), 255), bit.band(bit.rshift(n, 16), 255), bit.band(bit.rshift(n, 24), 255)) .. msg)
  end
  v_23_0_ = encode0
  _0_0["aniseed/locals"]["encode"] = v_23_0_
  encode = v_23_0_
end
local decode_one = nil
do
  local v_23_0_ = nil
  local function decode_one0(chunk)
    local expecting = a["get-in"](state, {"conn", "expecting"})
    if expecting then
      local part = (a["get-in"](state, {"conn", "part"}) .. chunk)
      local part_n = a.count(part)
      if (part_n >= expecting) then
        a["assoc-in"](state, {"conn", "expecting"}, nil)
        a["assoc-in"](state, {"conn", "part"}, nil)
        local function _3_()
          if (part_n > expecting) then
            return string.sub(part, a.inc(expecting))
          end
        end
        return {string.sub(part, 1, expecting), _3_()}
      else
        a["assoc-in"](state, {"conn", "part"}, part)
        return nil
      end
    else
      local n = nil
      local function _3_(_241, _242)
        return (_241 + _242)
      end
      local function _4_(c)
        return string.byte(string.sub(chunk, c, c))
      end
      n = a.reduce(_3_, 0, a.map(_4_, {1, 2, 3, 4}))
      local part = string.sub(chunk, 5)
      local part_n = a.count(part)
      if (part_n >= n) then
        local function _5_()
          if (part_n > n) then
            return string.sub(part, a.inc(n))
          end
        end
        return {string.sub(part, 1, n), _5_()}
      else
        a["assoc-in"](state, {"conn", "expecting"}, n)
        a["assoc-in"](state, {"conn", "part"}, part)
        return nil
      end
    end
  end
  v_23_0_ = decode_one0
  _0_0["aniseed/locals"]["decode-one"] = v_23_0_
  decode_one = v_23_0_
end
local decode_all = nil
do
  local v_23_0_ = nil
  local function decode_all0(chunk, acc)
    local acc0 = (acc or {})
    local res = decode_one(chunk)
    if res then
      local _3_ = res
      local msg = _3_[1]
      local rem = _3_[2]
      table.insert(acc0, msg)
      if rem then
        return decode_all0(rem, acc0)
      else
        return acc0
      end
    else
      return acc0
    end
  end
  v_23_0_ = decode_all0
  _0_0["aniseed/locals"]["decode-all"] = v_23_0_
  decode_all = v_23_0_
end
local with_conn_or_warn = nil
do
  local v_23_0_ = nil
  local function with_conn_or_warn0(f, opts)
    local conn = a.get(state, "conn")
    if conn then
      return f(conn)
    else
      if not a.get(opts, "silent?") then
        display({"# No connection"})
      end
      if a.get(opts, "else") then
        return opts["else"]()
      end
    end
  end
  v_23_0_ = with_conn_or_warn0
  _0_0["aniseed/locals"]["with-conn-or-warn"] = v_23_0_
  with_conn_or_warn = v_23_0_
end
local display_conn_status = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_conn_status0(status)
      local function _3_(conn)
        return display({("# " .. conn["raw-host"] .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
      end
      return with_conn_or_warn(_3_)
    end
    v_23_0_0 = display_conn_status0
    _0_0["display-conn-status"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-conn-status"] = v_23_0_
  display_conn_status = v_23_0_
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
local handle_message = nil
do
  local v_23_0_ = nil
  local function handle_message0(err, chunk)
    local conn = a.get(state, "conn")
    if err then
      return display_conn_status(err)
    elseif not chunk then
      return disconnect()
    else
      local function _3_(msg)
        dbg("receive", msg)
        local cb = table.remove(a["get-in"](state, {"conn", "queue"}))
        if cb then
          return cb(msg)
        end
      end
      return a["run!"](_3_, decode_all(chunk))
    end
  end
  v_23_0_ = handle_message0
  _0_0["aniseed/locals"]["handle-message"] = v_23_0_
  handle_message = v_23_0_
end
local send = nil
do
  local v_23_0_ = nil
  local function send0(msg, cb)
    dbg("send", msg)
    local function _3_(conn)
      table.insert(a["get-in"](state, {"conn", "queue"}), 1, (cb or false))
      return (conn.sock):write(encode(msg))
    end
    return with_conn_or_warn(_3_)
  end
  v_23_0_ = send0
  _0_0["aniseed/locals"]["send"] = v_23_0_
  send = v_23_0_
end
local handle_connect_fn = nil
do
  local v_23_0_ = nil
  local function handle_connect_fn0(cb)
    local function _3_(err)
      local conn = a.get(state, "conn")
      if err then
        display_conn_status(err)
        return disconnect()
      else
        do end (conn.sock):read_start(vim.schedule_wrap(handle_message))
        send("Conjure")
        return display_conn_status("connected")
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
    local function connect0(host, port)
      local host0 = (host or config.connection["default-host"])
      local port0 = (port or config.connection["default-port"])
      local resolved_host = net.resolve(host0)
      local conn = {["raw-host"] = host0, host = resolved_host, port = port0, queue = {}, sock = vim.loop.new_tcp()}
      if a.get(state, "conn") then
        disconnect()
      end
      a.assoc(state, "conn", conn)
      return (conn.sock):connect(resolved_host, port0, handle_connect_fn())
    end
    v_23_0_0 = connect0
    _0_0["connect"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_23_0_
  connect = v_23_0_
end
local parse_result = nil
do
  local v_23_0_ = nil
  local function parse_result0(msg)
    local lines = a["kv-pairs"](text["split-lines"](text["trim-last-newline"](text["strip-ansi-codes"](msg))))
    local total = a.count(lines)
    local head = a.second(a.first(lines))
    local function _3_(_241, _242)
      return (a.first(_241) > a.first(_242))
    end
    table.sort(lines, _3_)
    local text_lines = {}
    local data_lines = {}
    local data_3f = not (text["starts-with"](head, "error:") or text["starts-with"](head, "compile error:"))
    local function _4_(_5_0)
      local _6_ = _5_0
      local n = _6_[1]
      local line = _6_[2]
      if (data_3f and text["starts-with"](line, "(")) then
        local function _7_()
          if a["empty?"](data_lines) then
            return -2
          end
        end
        table.insert(data_lines, 1, string.sub(line, 2, _7_()))
        data_3f = false
        return nil
      elseif data_3f then
        local function _7_()
          if (n == total) then
            return -2
          end
        end
        return table.insert(data_lines, 1, string.sub(line, 3, _7_()))
      else
        return table.insert(text_lines, 1, ("# " .. line))
      end
    end
    a["run!"](_4_, lines)
    return {["data-lines"] = data_lines, ["text-lines"] = text_lines, data = str.join("\n", data_lines)}
  end
  v_23_0_ = parse_result0
  _0_0["aniseed/locals"]["parse-result"] = v_23_0_
  parse_result = v_23_0_
end
local display_result = nil
do
  local v_23_0_ = nil
  local function display_result0(_3_0)
    local _4_ = _3_0
    local data_lines = _4_["data-lines"]
    local text_lines = _4_["text-lines"]
    if text_lines then
      display(text_lines)
    end
    return display(data_lines)
  end
  v_23_0_ = display_result0
  _0_0["aniseed/locals"]["display-result"] = v_23_0_
  display_result = v_23_0_
end
local eval_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_str0(opts)
      local function _3_(msg)
        local res = parse_result(msg)
        opts["on-result"](res.data)
        return display_result(res)
      end
      return send(("[" .. opts.code .. "\n]\n"), _3_)
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
      return display({"# Not implemented yet."})
    end
    v_23_0_0 = doc_str0
    _0_0["doc-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_23_0_
  doc_str = v_23_0_
end
local eval_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_file0(opts)
      return display({"# Not implemented yet."})
    end
    v_23_0_0 = eval_file0
    _0_0["eval-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_23_0_
  eval_file = v_23_0_
end
local on_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", config.mappings.disconnect, "conjure.client.janet.netrepl", "disconnect")
      mapping.buf("n", config.mappings.connect, "conjure.client.janet.netrepl", "connect")
      return nvim.ex.command_("-nargs=+ -buffer ConjureConnect", bridge["viml->lua"]("conjure.client.janet.netrepl", "connect", {args = "<f-args>"}))
    end
    v_23_0_0 = on_filetype0
    _0_0["on-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_23_0_
  on_filetype = v_23_0_
end
local on_load = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_load0()
      nvim.ex.augroup("conjure_janet_netrepl_cleanup")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("VimLeavePre *", bridge["viml->lua"]("conjure.client.janet.netrepl", "disconnect", {}))
      nvim.ex.augroup("END")
      return connect()
    end
    v_23_0_0 = on_load0
    _0_0["on-load"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-load"] = v_23_0_
  on_load = v_23_0_
end
return nil