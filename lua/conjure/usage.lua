local _0_0 = nil
do
  local name_0_ = "conjure.usage"
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
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.client"), require("conjure.eval"), require("conjure.extract"), require("conjure.aniseed.fennel"), require("conjure.fs"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {["conjure-client"] = "conjure.client", a = "conjure.aniseed.core", config = "conjure.config", eval = "conjure.eval", extract = "conjure.extract", fennel = "conjure.aniseed.fennel", fs = "conjure.fs", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local config = _local_0_[2]
local conjure_client = _local_0_[3]
local eval = _local_0_[4]
local extract = _local_0_[5]
local fennel = _local_0_[6]
local fs = _local_0_[7]
local nvim = _local_0_[8]
local str = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.usage"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local clojure = nil
do
  local v_0_ = nil
  do
    local v_0_0 = {ft = "fennel", path = (fs["cache-dir"]() .. "/" .. "clj-docs.fnl"), url = ("https://gist.githubusercontent.com" .. "/tami5/" .. "14c0098691ce57b1c380c9c91dbdd322" .. "/raw/" .. "b859bd867115960bc72a49903e2b8de0ce249c31" .. "/" .. "clojure.docs.fnl")}
    _0_0["clojure"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["clojure"] = v_0_
  clojure = v_0_
end
local get_msg = nil
do
  local v_0_ = nil
  local function get_msg0(client, mtype)
    local f = string.format
    local _2_0 = mtype
    if (_2_0 == "not-supported") then
      return f("'%s' client is not supported", client)
    elseif (_2_0 == "fetch-err") then
      return f("CONJURE-ERROR: %s usage doc could not downloaded.\n                  Try again, or open an issue.", client)
    elseif (_2_0 == "fetching") then
      return f("CONJURE: fetching usage defs for %s .......", client)
    elseif (_2_0 == "caching") then
      return f("CONJURE: caching usage defs for %s .......", client)
    end
  end
  v_0_ = get_msg0
  _0_0["aniseed/locals"]["get-msg"] = v_0_
  get_msg = v_0_
end
local get_in_client = nil
do
  local v_0_ = nil
  local function get_in_client0(client, key)
    local _4_
    do
      local _2_0, _3_0 = client
      if (_2_0 == "clojure") then
        _4_ = clojure
      else
        local _ = _2_0
        _4_ = error(get_msg(client, "not-supported"))
      end
    end
    return _4_[key]
  end
  v_0_ = get_in_client0
  _0_0["aniseed/locals"]["get-in-client"] = v_0_
  get_in_client = v_0_
end
local dl_defs = nil
do
  local v_0_ = nil
  local function dl_defs0(client, cb)
    local path = get_in_client(client, "path")
    if fs["exists?"](path) then
      return cb()
    else
      local args = {"curl", "-L", get_in_client(client, "url"), "-o", path}
      local on_exit = nil
      local function _2_()
        if fs["exists?"](path) then
          return cb()
        else
          return error(get_msg(client, "fetch-err"))
        end
      end
      on_exit = _2_
      print(get_msg(client, "fetching"))
      return vim.fn.jobstart(args, {on_exit = on_exit})
    end
  end
  v_0_ = dl_defs0
  _0_0["aniseed/locals"]["dl-defs"] = v_0_
  dl_defs = v_0_
end
local up_defs = nil
do
  local v_0_ = nil
  local function up_defs0(client, cb)
    local function _2_()
      return dl_defs("clojure", cb)
    end
    return vim.fn.jobstart({"rm", get_in_client(client, "path")}, {on_exit = _2_})
  end
  v_0_ = up_defs0
  _0_0["aniseed/locals"]["up-defs"] = v_0_
  up_defs = v_0_
end
local cached_defs_3f = nil
do
  local v_0_ = nil
  local function cached_defs_3f0(client)
    return not a["nil?"](_2amodule_2a[client].defs)
  end
  v_0_ = cached_defs_3f0
  _0_0["aniseed/locals"]["cached-defs?"] = v_0_
  cached_defs_3f = v_0_
end
local cache_defs = nil
do
  local v_0_ = nil
  local function cache_defs0(client, cb)
    local path = get_in_client(client, "path")
    local parse = nil
    do
      local _2_0 = get_in_client(client, "ft")
      if (_2_0 == "fennel") then
        local function _3_()
          return fennel.dofile(path)
        end
        parse = _3_
      elseif (_2_0 == "json") then
        local function _3_()
          return vim.fn.json_decode(vim.fn.readfile(path))
        end
        parse = _3_
      else
      parse = nil
      end
    end
    local function _3_()
      print(get_msg(client, "caching"))
      _2amodule_2a[client]["defs"] = parse()
      return cb()
    end
    return dl_defs(client, vim.schedule_wrap(_3_))
  end
  v_0_ = cache_defs0
  _0_0["aniseed/locals"]["cache-defs"] = v_0_
  cache_defs = v_0_
end
local ensure_defs = nil
do
  local v_0_ = nil
  local function ensure_defs0(client, cb)
    if cached_defs_3f(client) then
      return cb()
    else
      return cache_defs(client, cb)
    end
  end
  v_0_ = ensure_defs0
  _0_0["aniseed/locals"]["ensure-defs"] = v_0_
  ensure_defs = v_0_
end
local get_in_defs = nil
do
  local v_0_ = nil
  local function get_in_defs0(client, sym)
    return a.get(get_in_client(client, "defs"), sym)
  end
  v_0_ = get_in_defs0
  _0_0["aniseed/locals"]["get-in-defs"] = v_0_
  get_in_defs = v_0_
end
local parse_sym_usage = nil
do
  local v_0_ = nil
  local function parse_sym_usage0(client, kv)
    local sec = nil
    do
      local _2_0 = client
      if (_2_0 == "clojure") then
        sec = {also = kv["see-alsos"], examples = kv.examples, header = {kv.ns, kv.name}, info = kv.doc, notes = kv.notes, signture = {kv.name, kv.arglists}}
      else
      sec = nil
      end
    end
    local formatlist = nil
    local function _3_(xs, title, template)
      local res = {}
      local count = 1
      if not a["empty?"](xs) then
        table.insert(res, title)
        table.insert(res, "--------------")
        local function _4_(item)
          table.insert(res, vim.split(string.format(template, count, str.trim(item)), "\n"))
          count = (count + 1)
          return nil
        end
        a["run!"](_4_, xs)
        return vim.tbl_flatten(res)
      end
    end
    formatlist = _3_
    local header = {string.format("%s/%s", unpack(sec.header)), "=============="}
    local signture = nil
    local function _4_(_241)
      return string.format("`(%s %s)`", a["get-in"](sec, {"signture", 1}), _241)
    end
    signture = {str.join(" ", a.map(_4_, a["get-in"](sec, {"signture", 2}))), " "}
    local info = {a.map(str.trim, vim.split(sec.info, "\n")), " "}
    local examples = formatlist(sec.examples, "Usage", "### Example %d:\n\n```clojure\n%s\n```\n--------------\n")
    local notes = formatlist(sec.notes, "Notes", "### Note %d:\n%s\n\n--------------\n")
    local see_also = nil
    if not a["empty?"](sec.also) then
      local function _5_(_241)
        return string.format("* `%s`", _241)
      end
      see_also = {"See Also", "--------------", a.map(_5_, sec.also), " "}
    else
    see_also = nil
    end
    return vim.tbl_flatten({header, signture, info, see_also, examples, notes})
  end
  v_0_ = parse_sym_usage0
  _0_0["aniseed/locals"]["parse-sym-usage"] = v_0_
  parse_sym_usage = v_0_
end
local get_ns_sym = nil
do
  local v_0_ = nil
  local function get_ns_sym0(client, sym, cb)
    local _2_0 = client
    if (_2_0 == "clojure") then
      local function _3_(_241)
        return cb(string.gsub(_241, "#'", ""))
      end
      local _5_
      do
        local _4_0 = client
        if (_4_0 == "clojure") then
          _5_ = string.format("(resolve '%s)", sym)
        else
        _5_ = nil
        end
      end
      return conjure_client["with-filetype"](client, eval["eval-str"], {["on-result"] = _3_, ["passive?"] = true, code = _5_, origin = client})
    end
  end
  v_0_ = get_ns_sym0
  _0_0["aniseed/locals"]["get-ns-sym"] = v_0_
  get_ns_sym = v_0_
end
local draw_border = nil
do
  local v_0_ = nil
  local function draw_border0(opts, style)
    local style0 = (style or {"\226\148\128", "\226\148\130", "\226\149\173", "\226\149\174", "\226\149\176", "\226\149\175"})
    local top = (a.get(style0, 3) .. string.rep(a.get(style0, 1), (opts.width + 2)) .. a.get(style0, 4))
    local mid = (a.get(style0, 2) .. string.rep(" ", (opts.width + 2)) .. a.get(style0, 2))
    local bot = (a.get(style0, 5) .. string.rep(a.get(style0, 1), (opts.width + 2)) .. a.get(style0, 6))
    local lines = nil
    do
      local lines0 = {top}
      for _ = 2, (opts.height + 1), 1 do
        table.insert(lines0, mid)
      end
      table.insert(lines0, bot)
      lines = lines0
    end
    local winops = a.merge(opts, {col = (opts.col - 2), height = (opts.height + 2), row = (opts.row - 1), width = (opts.width + 4)})
    local bufnr = vim.fn.nvim_create_buf(false, true)
    local winid = vim.api.nvim_open_win(bufnr, true, winops)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_add_highlight(bufnr, 0, "ConjureBorder", 1, 0, -1)
    return winid
  end
  v_0_ = draw_border0
  _0_0["aniseed/locals"]["draw-border"] = v_0_
  draw_border = v_0_
end
local setup_buffer = nil
do
  local v_0_ = nil
  local function setup_buffer0(bufnr, content, opts)
    local opts0 = a.merge({bufhidden = "wipe", buflisted = false, buftype = "nofile", filetype = "markdown", swapfile = false}, opts)
    for k, v in pairs(opts0) do
      vim.api.nvim_buf_set_option(bufnr, k, v)
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, content)
    return vim.api.nvim_win_set_cursor(0, {1, 0})
  end
  v_0_ = setup_buffer0
  _0_0["aniseed/locals"]["setup-buffer"] = v_0_
  setup_buffer = v_0_
end
local setup_win = nil
do
  local v_0_ = nil
  local function setup_win0(opts)
    local winops = a.merge({conceallevel = 3, winblend = 5, winhl = "NormalFloat:Normal"}, opts.win)
    local _let_0_ = {opts["primary-winid"], opts["border-winid"]}
    local primary = _let_0_[1]
    local border = _let_0_[2]
    for _, win in ipairs({primary, border}) do
      for k, v in pairs(winops) do
        vim.api.nvim_win_set_option(win, k, v)
      end
    end
    return vim.cmd(str.join(" ", {"au", "WinClosed,WinLeave", string.format("<buffer=%d>", opts.bufnr), ":bd!", "|", "call", string.format("nvim_win_close(%d,", border), "v:true)"}))
  end
  v_0_ = setup_win0
  _0_0["aniseed/locals"]["setup-win"] = v_0_
  setup_win = v_0_
end
local open_float = nil
do
  local v_0_ = nil
  local function open_float0(opts)
    local bufnr = vim.fn.nvim_create_buf(false, true)
    local winops = nil
    do
      local relative = (opts.relative or "editor")
      local style = (opts.style or "minimal")
      local fill = (opts.fill or 0.80000000000000004)
      local width = math.floor((vim.o.columns * fill))
      local height = math.floor((vim.o.lines * fill))
      local row = math.floor((((vim.o.lines - height) / 2) - 1))
      local col = math.floor(((vim.o.columns - width) / 2))
      winops = {col = col, height = height, relative = relative, row = row, style = style, width = width}
    end
    local border_winid = draw_border(winops, opts.border)
    local primary_winid = vim.fn.nvim_open_win(bufnr, true, winops)
    print(" ")
    setup_win({["border-winid"] = border_winid, ["opts.win"] = opts.win, ["primary-winid"] = primary_winid, bufnr = bufnr})
    return setup_buffer(bufnr, opts.content, opts.buf)
  end
  v_0_ = open_float0
  _0_0["aniseed/locals"]["open-float"] = v_0_
  open_float = v_0_
end
local open_split = nil
do
  local v_0_ = nil
  local function open_split0(opts)
    print(" ")
    vim.cmd("new")
    return setup_buffer(0, opts.content, opts.buf)
  end
  v_0_ = open_split0
  _0_0["aniseed/locals"]["open-split"] = v_0_
  open_split = v_0_
end
local open_vsplit = nil
do
  local v_0_ = nil
  local function open_vsplit0(opts)
    print(" ")
    vim.cmd("vnew")
    return setup_buffer(0, opts.content, opts.buf)
  end
  v_0_ = open_vsplit0
  _0_0["aniseed/locals"]["open-vsplit"] = v_0_
  open_vsplit = v_0_
end
local get_usage = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_usage0(opts)
      local client = (opts.client or vim.bo.filetype)
      local symbol = (opts.symbol or vim.fn.expand("<cword>"))
      local cb = nil
      do
        local _2_0 = opts.display
        if (_2_0 == "float") then
          cb = open_float
        elseif (_2_0 == "split") then
          cb = open_split
        elseif (_2_0 == "vsplit") then
          cb = open_vsplit
        else
        cb = nil
        end
      end
      local function _3_(ns_sym)
        local function _4_()
          return cb(a.assoc(opts, "content", parse_sym_usage(client, get_in_defs(client, ns_sym))))
        end
        return ensure_defs(client, _4_)
      end
      return get_ns_sym(client, symbol, _3_)
    end
    v_0_0 = get_usage0
    _0_0["get-usage"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-usage"] = v_0_
  get_usage = v_0_
end
local get_usage_float = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_usage_float0(opts)
      return get_usage({display = "float", fill = 0.80000000000000004, win = {winblend = 0}})
    end
    v_0_0 = get_usage_float0
    _0_0["get-usage-float"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-usage-float"] = v_0_
  get_usage_float = v_0_
end
local get_usage_vsplit = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_usage_vsplit0(opts)
      return get_usage({display = "vsplit"})
    end
    v_0_0 = get_usage_vsplit0
    _0_0["get-usage-vsplit"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-usage-vsplit"] = v_0_
  get_usage_vsplit = v_0_
end
local get_usage_split = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_usage_split0(opts)
      return get_usage({display = "split"})
    end
    v_0_0 = get_usage_split0
    _0_0["get-usage-split"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-usage-split"] = v_0_
  get_usage_split = v_0_
end
return nil