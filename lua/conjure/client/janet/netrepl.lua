local _0_0 = nil
do
  local name_0_ = "conjure.client.janet.netrepl"
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
    return {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.client"), require("conjure.config"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.remote.netrepl"), require("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", remote = "conjure.remote.netrepl", text = "conjure.text"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local bridge = _1_[2]
local client = _1_[3]
local config = _1_[4]
local log = _1_[5]
local mapping = _1_[6]
local nvim = _1_[7]
local remote = _1_[8]
local text = _1_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.janet.netrepl"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local buf_suffix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = ".janet"
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
    local v_0_0 = "# "
    _0_0["comment-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
config.merge({client = {janet = {netrepl = {connection = {default_host = "127.0.0.1", default_port = "9365"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
local state = nil
do
  local v_0_ = nil
  local function _3_()
    return {conn = nil}
  end
  v_0_ = (_0_0["aniseed/locals"].state or client["new-state"](_3_))
  _0_0["aniseed/locals"]["state"] = v_0_
  state = v_0_
end
local with_conn_or_warn = nil
do
  local v_0_ = nil
  local function with_conn_or_warn0(f, opts)
    local conn = state("conn")
    if conn then
      return f(conn)
    else
      return log.append({"# No connection"})
    end
  end
  v_0_ = with_conn_or_warn0
  _0_0["aniseed/locals"]["with-conn-or-warn"] = v_0_
  with_conn_or_warn = v_0_
end
local connected_3f = nil
do
  local v_0_ = nil
  local function connected_3f0()
    if state("conn") then
      return true
    else
      return false
    end
  end
  v_0_ = connected_3f0
  _0_0["aniseed/locals"]["connected?"] = v_0_
  connected_3f = v_0_
end
local display_conn_status = nil
do
  local v_0_ = nil
  local function display_conn_status0(status)
    local function _3_(conn)
      return log.append({("# " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
    end
    return with_conn_or_warn(_3_)
  end
  v_0_ = display_conn_status0
  _0_0["aniseed/locals"]["display-conn-status"] = v_0_
  display_conn_status = v_0_
end
local disconnect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function disconnect0()
      local function _3_(conn)
        conn.destroy()
        display_conn_status("disconnected")
        return a.assoc(state(), "conn", nil)
      end
      return with_conn_or_warn(_3_)
    end
    v_0_0 = disconnect0
    _0_0["disconnect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["disconnect"] = v_0_
  disconnect = v_0_
end
local send = nil
do
  local v_0_ = nil
  local function send0(msg, cb)
    local function _3_(conn)
      return remote.send(conn, msg, cb)
    end
    return with_conn_or_warn(_3_)
  end
  v_0_ = send0
  _0_0["aniseed/locals"]["send"] = v_0_
  send = v_0_
end
local connect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect0(opts)
      local opts0 = (opts or {})
      local host = (opts0.host or config["get-in"]({"client", "janet", "netrepl", "connection", "default_host"}))
      local port = (opts0.port or config["get-in"]({"client", "janet", "netrepl", "connection", "default_port"}))
      if state("conn") then
        disconnect()
      end
      local function _4_(err)
        if err then
          return display_conn_status(err)
        else
          return disconnect()
        end
      end
      local function _5_(err)
        display_conn_status(err)
        return disconnect()
      end
      local function _6_()
        return display_conn_status("connected")
      end
      return a.assoc(state(), "conn", remote.connect({["on-error"] = _4_, ["on-failure"] = _5_, ["on-success"] = _6_, host = host, port = port}))
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_0_
  connect = v_0_
end
local try_ensure_conn = nil
do
  local v_0_ = nil
  local function try_ensure_conn0()
    if not connected_3f() then
      return connect({["silent?"] = true})
    end
  end
  v_0_ = try_ensure_conn0
  _0_0["aniseed/locals"]["try-ensure-conn"] = v_0_
  try_ensure_conn = v_0_
end
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
      try_ensure_conn()
      local function _3_(msg)
        local clean = text["trim-last-newline"](msg)
        if opts["on-result"] then
          opts["on-result"](text["strip-ansi-escape-sequences"](clean))
        end
        if not opts["passive?"] then
          return log.append(text["split-lines"](clean))
        end
      end
      return send((opts.code .. "\n"), _3_)
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
      try_ensure_conn()
      local function _3_(_241)
        return ("(doc " .. _241 .. ")")
      end
      return eval_str(a.update(opts, "code", _3_))
    end
    v_0_0 = doc_str0
    _0_0["doc-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_0_
  doc_str = v_0_
end
local eval_file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_file0(opts)
      try_ensure_conn()
      return eval_str(a.assoc(opts, "code", ("(do (dofile \"" .. opts["file-path"] .. "\" :env (fiber/getenv (fiber/current))) nil)")))
    end
    v_0_0 = eval_file0
    _0_0["eval-file"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_0_
  eval_file = v_0_
end
local on_filetype = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", "JanetDisconnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "disconnect"}), "conjure.client.janet.netrepl", "disconnect")
      return mapping.buf("n", "JanetConnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "connect"}), "conjure.client.janet.netrepl", "connect")
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
      return connect({})
    end
    v_0_0 = on_load0
    _0_0["on-load"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["on-load"] = v_0_
  on_load = v_0_
end
return nil