local _2afile_2a = "fnl/conjure/client/guile/socket.fnl"
local _1_
do
  local name_4_auto = "conjure.client.guile.socket"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.socket"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", extract = "conjure.extract", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", socket = "conjure.remote.socket", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local text = _local_4_[10]
local client = _local_4_[2]
local config = _local_4_[3]
local extract = _local_4_[4]
local log = _local_4_[5]
local mapping = _local_4_[6]
local nvim = _local_4_[7]
local socket = _local_4_[8]
local str = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.guile.socket"
do local _ = ({nil, _1_, nil, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {guile = {socket = {mapping = {connect = "cc", disconnect = "cd"}, pipename = nil}}}})
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "guile", "socket"})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
local state
do
  local v_23_auto
  local function _8_()
    return {repl = nil}
  end
  v_23_auto = ((_1_)["aniseed/locals"].state or client["new-state"](_8_))
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local buf_suffix
do
  local v_23_auto
  do
    local v_25_auto = ".scm"
    _1_["buf-suffix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-suffix"] = v_23_auto
  buf_suffix = v_23_auto
end
local comment_prefix
do
  local v_23_auto
  do
    local v_25_auto = "; "
    _1_["comment-prefix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-prefix"] = v_23_auto
  comment_prefix = v_23_auto
end
local context_pattern
do
  local v_23_auto
  do
    local v_25_auto = "%(define%-module%s+(%([%g%s]-%))"
    _1_["context-pattern"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["context-pattern"] = v_23_auto
  context_pattern = v_23_auto
end
local with_repl_or_warn
do
  local v_23_auto
  local function with_repl_or_warn0(f, opts)
    local repl = state("repl")
    if (repl and ("connected" == repl.status)) then
      return f(repl)
    else
      return log.append({(comment_prefix .. "No REPL running")})
    end
  end
  v_23_auto = with_repl_or_warn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-repl-or-warn"] = v_23_auto
  with_repl_or_warn = v_23_auto
end
local format_message
do
  local v_23_auto
  local function format_message0(msg)
    if msg.out then
      return text["split-lines"](msg.out)
    elseif msg.err then
      return text["prefixed-lines"](string.gsub(msg.err, "%s*Entering a new prompt%. .*]>%s*", ""), comment_prefix)
    else
      return {(comment_prefix .. "Empty result")}
    end
  end
  v_23_auto = format_message0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["format-message"] = v_23_auto
  format_message = v_23_auto
end
local display_result
do
  local v_23_auto
  local function display_result0(msg)
    local function _11_(_241)
      return ("" ~= _241)
    end
    return log.append(a.filter(_11_, format_message(msg)))
  end
  v_23_auto = display_result0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-result"] = v_23_auto
  display_result = v_23_auto
end
local clean_input_code
do
  local v_23_auto
  local function clean_input_code0(code)
    local clean = str.trim(code)
    if not str["blank?"](clean) then
      return clean
    end
  end
  v_23_auto = clean_input_code0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["clean-input-code"] = v_23_auto
  clean_input_code = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      local function _13_(repl)
        local _14_ = opts.code
        if _14_ then
          local _15_ = clean_input_code(_14_)
          if _15_ then
            local function _16_(msgs)
              if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
                a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result"))
              end
              opts["on-result"](str.join("\n", format_message(a.last(msgs))))
              return a["run!"](display_result, msgs)
            end
            return repl.send(_15_, _16_, {["batch?"] = true})
          else
            return _15_
          end
        else
          return _14_
        end
      end
      return with_repl_or_warn(_13_)
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local eval_file
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_file0(opts)
      return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local doc_str
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_str0(opts)
      local function _20_(_241)
        return ("(procedure-documentation " .. _241 .. ")")
      end
      return eval_str(a.update(opts, "code", _20_))
    end
    v_25_auto = doc_str0
    _1_["doc-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local display_repl_status
do
  local v_23_auto
  local function display_repl_status0()
    local repl = state("repl")
    if repl then
      local _21_
      do
        local pipename = a["get-in"](repl, {"opts", "pipename"})
        if pipename then
          _21_ = (pipename .. " ")
        else
          _21_ = ""
        end
      end
      local _23_
      do
        local err = a.get(repl, "err")
        if err then
          _23_ = (" " .. err)
        else
          _23_ = ""
        end
      end
      return log.append({(comment_prefix .. _21_ .. "(" .. repl.status .. _23_ .. ")")}, {["break?"] = true})
    end
  end
  v_23_auto = display_repl_status0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-repl-status"] = v_23_auto
  display_repl_status = v_23_auto
end
local disconnect
do
  local v_23_auto
  do
    local v_25_auto
    local function disconnect0()
      local repl = state("repl")
      if repl then
        repl.destroy()
        a.assoc(repl, "status", "disconnected")
        display_repl_status()
        return a.assoc(state(), "repl", nil)
      end
    end
    v_25_auto = disconnect0
    _1_["disconnect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["disconnect"] = v_23_auto
  disconnect = v_23_auto
end
local parse_guile_result
do
  local v_23_auto
  local function parse_guile_result0(s)
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
  v_23_auto = parse_guile_result0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["parse-guile-result"] = v_23_auto
  parse_guile_result = v_23_auto
end
local enter
do
  local v_23_auto
  do
    local v_25_auto
    local function enter0()
      local repl = state("repl")
      local c = extract.context()
      if (repl and ("connected" == repl.status)) then
        local function _29_()
        end
        return repl.send((",m " .. (c or "(guile-user)") .. "\n"), _29_)
      end
    end
    v_25_auto = enter0
    _1_["enter"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["enter"] = v_23_auto
  enter = v_23_auto
end
local connect
do
  local v_23_auto
  do
    local v_25_auto
    local function connect0(opts)
      disconnect()
      local pipename = (cfg({"pipename"}) or a.get(opts, "port"))
      if ("string" ~= type(pipename)) then
        return log.append({(comment_prefix .. "g:conjure#client#guile#socket#pipename is not specified"), (comment_prefix .. "Please set it to the name of your Guile REPL pipe or pass it to :ConjureConnect [pipename]")})
      else
        local function _31_(msg, repl)
          display_result(msg)
          local function _32_()
          end
          return repl.send(",q\n", _32_)
        end
        local function _33_()
          display_repl_status()
          return enter()
        end
        return a.assoc(state(), "repl", socket.start({["on-close"] = disconnect, ["on-error"] = _31_, ["on-failure"] = disconnect, ["on-stray-output"] = display_result, ["on-success"] = _33_, ["parse-output"] = parse_guile_result, pipename = pipename}))
      end
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
local on_load
do
  local v_23_auto
  do
    local v_25_auto
    local function on_load0()
      do
        nvim.ex.augroup("conjure-guile-socket-bufenter")
        nvim.ex.autocmd_()
        nvim.ex.autocmd("BufEnter", ("*" .. buf_suffix), ("lua require('" .. _2amodule_name_2a .. "')['" .. "enter" .. "']()"))
        nvim.ex.augroup("END")
      end
      return connect()
    end
    v_25_auto = on_load0
    _1_["on-load"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-load"] = v_23_auto
  on_load = v_23_auto
end
local on_exit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_exit0()
      return disconnect()
    end
    v_25_auto = on_exit0
    _1_["on-exit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-exit"] = v_23_auto
  on_exit = v_23_auto
end
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
    local function on_filetype0()
      mapping.buf("n", "GuileConnect", cfg({"mapping", "connect"}), _2amodule_name_2a, "connect")
      return mapping.buf("n", "GuileDisconnect", cfg({"mapping", "disconnect"}), _2amodule_name_2a, "disconnect")
    end
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
end
return nil