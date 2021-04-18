local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.guile.socket"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.extract"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.remote.socket"), require("conjure.aniseed.string"), require("conjure.text")}
local a = _local_0_[1]
local text = _local_0_[10]
local client = _local_0_[2]
local config = _local_0_[3]
local extract = _local_0_[4]
local log = _local_0_[5]
local mapping = _local_0_[6]
local nvim = _local_0_[7]
local socket = _local_0_[8]
local str = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.guile.socket"
do local _ = ({nil, _0_0, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {guile = {socket = {mapping = {connect = "cc", disconnect = "cd"}, pipename = nil}}}})
local cfg = config["get-in-fn"]({"client", "guile", "socket"})
local state
local function _1_()
  return {repl = nil}
end
state = client["new-state"](_1_)
local buf_suffix
do
  local v_0_ = ".scm"
  _0_0["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix
do
  local v_0_ = "; "
  _0_0["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
local context_pattern
do
  local v_0_ = "%(define%-module%s+(%([%g%s]-%))"
  _0_0["context-pattern"] = v_0_
  context_pattern = v_0_
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if (repl and ("connected" == repl.status)) then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local function format_message(msg)
  if msg.out then
    return text["split-lines"](msg.out)
  elseif msg.err then
    return text["prefixed-lines"](string.gsub(msg.err, "%s*Entering a new prompt%. .*]>%s*", ""), comment_prefix)
  else
    return {(comment_prefix .. "Empty result")}
  end
end
local function display_result(msg)
  local function _2_(_241)
    return ("" ~= _241)
  end
  return log.append(a.filter(_2_, format_message(msg)))
end
local function clean_input_code(code)
  local clean = str.trim(code)
  if not str["blank?"](clean) then
    return clean
  end
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    local function _2_(repl)
      local _3_0 = opts.code
      if _3_0 then
        local _4_0 = clean_input_code(_3_0)
        if _4_0 then
          local function _5_(msgs)
            if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
              a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result"))
            end
            opts["on-result"](str.join("\n", format_message(a.last(msgs))))
            return a["run!"](display_result, msgs)
          end
          return repl.send(_4_0, _5_, {["batch?"] = true})
        else
          return _4_0
        end
      else
        return _3_0
      end
    end
    return with_repl_or_warn(_2_)
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local eval_file
do
  local v_0_
  local function eval_file0(opts)
    return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local doc_str
do
  local v_0_
  local function doc_str0(opts)
    local function _2_(_241)
      return ("(procedure-documentation " .. _241 .. ")")
    end
    return eval_str(a.update(opts, "code", _2_))
  end
  v_0_ = doc_str0
  _0_0["doc-str"] = v_0_
  doc_str = v_0_
end
local function display_repl_status()
  local repl = state("repl")
  if repl then
    local _2_
    do
      local pipename = a["get-in"](repl, {"opts", "pipename"})
      if pipename then
        _2_ = (pipename .. " ")
      else
        _2_ = ""
      end
    end
    local _3_
    do
      local err = a.get(repl, "err")
      if err then
        _3_ = (" " .. err)
      else
        _3_ = ""
      end
    end
    return log.append({(comment_prefix .. _2_ .. "(" .. repl.status .. _3_ .. ")")}, {["break?"] = true})
  end
end
local disconnect
do
  local v_0_
  local function disconnect0()
    local repl = state("repl")
    if repl then
      repl.destroy()
      a.assoc(repl, "status", "disconnected")
      display_repl_status()
      return a.assoc(state(), "repl", nil)
    end
  end
  v_0_ = disconnect0
  _0_0["disconnect"] = v_0_
  disconnect = v_0_
end
local function parse_guile_result(s)
  if s:find("scheme@%([%w%-%s]+%)> ") then
    local ind1, ind2, result = s:find("%$%d+ = ([^\n]+)\n")
    return {["done?"] = true, ["error?"] = false, result = result}
  else
    if s:find("scheme@%([%w%-%s]+%) %[%d+%]>") then
      return {["done?"] = true, ["error?"] = true, result = nil}
    else
      return {["done?"] = false, ["error?"] = false, result = s}
    end
  end
end
local enter
do
  local v_0_
  local function enter0()
    local repl = state("repl")
    local c = extract.context()
    if (repl and ("connected" == repl.status)) then
      local function _2_()
      end
      return repl.send((",m " .. (c or "(guile-user)") .. "\n"), _2_)
    end
  end
  v_0_ = enter0
  _0_0["enter"] = v_0_
  enter = v_0_
end
local connect
do
  local v_0_
  local function connect0(opts)
    disconnect()
    local pipename = (cfg({"pipename"}) or a.get(opts, "port"))
    if ("string" ~= type(pipename)) then
      return log.append({(comment_prefix .. "g:conjure#client#guile#socket#pipename is not specified"), (comment_prefix .. "Please set it to the name of your Guile REPL pipe or pass it to :ConjureConnect [pipename]")})
    else
      local function _2_(msg, repl)
        display_result(msg)
        local function _3_()
        end
        return repl.send(",q\n", _3_)
      end
      local function _3_()
        display_repl_status()
        return enter()
      end
      return a.assoc(state(), "repl", socket.start({["on-close"] = disconnect, ["on-error"] = _2_, ["on-failure"] = disconnect, ["on-stray-output"] = display_result, ["on-success"] = _3_, ["parse-output"] = parse_guile_result, pipename = pipename}))
    end
  end
  v_0_ = connect0
  _0_0["connect"] = v_0_
  connect = v_0_
end
local on_load
do
  local v_0_
  local function on_load0()
    do
      nvim.ex.augroup("conjure-guile-socket-bufenter")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("BufEnter", ("*" .. buf_suffix), ("lua require('" .. _2amodule_name_2a .. "')['" .. "enter" .. "']()"))
      nvim.ex.augroup("END")
    end
    return connect()
  end
  v_0_ = on_load0
  _0_0["on-load"] = v_0_
  on_load = v_0_
end
local on_exit
do
  local v_0_
  local function on_exit0()
    return disconnect()
  end
  v_0_ = on_exit0
  _0_0["on-exit"] = v_0_
  on_exit = v_0_
end
local on_filetype
do
  local v_0_
  local function on_filetype0()
    mapping.buf("n", "GuileConnect", cfg({"mapping", "connect"}), _2amodule_name_2a, "connect")
    return mapping.buf("n", "GuileDisconnect", cfg({"mapping", "disconnect"}), _2amodule_name_2a, "disconnect")
  end
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
return nil