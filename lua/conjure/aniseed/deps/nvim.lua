-- Bring vim into local scope.
local vim = vim
local api = vim.api
local inspect = vim.inspect

local function extend(t, o)
  local mt = getmetatable(t)
  for k, v in pairs(o) do
    rawset(mt, k, v)
  end
  return t
end

-- Equivalent to `echo vim.inspect(...)`
local function nvim_print(...)
  if select("#", ...) == 1 then
    api.nvim_out_write(inspect((...)))
  else
    api.nvim_out_write(inspect {...})
  end
  api.nvim_out_write("\n")
end

--- Equivalent to `echo` EX command
local function nvim_echo(...)
  for i = 1, select("#", ...) do
    local part = select(i, ...)
    api.nvim_out_write(tostring(part))
    -- vim.api.nvim_out_write("\n")
    api.nvim_out_write(" ")
  end
  api.nvim_out_write("\n")
end

local window_options = {
            arab = true;       arabic = true;   breakindent = true; breakindentopt = true;
             bri = true;       briopt = true;            cc = true;           cocu = true;
            cole = true;  colorcolumn = true; concealcursor = true;   conceallevel = true;
             crb = true;          cuc = true;           cul = true;     cursorbind = true;
    cursorcolumn = true;   cursorline = true;          diff = true;            fcs = true;
             fdc = true;          fde = true;           fdi = true;            fdl = true;
             fdm = true;          fdn = true;           fdt = true;            fen = true;
       fillchars = true;          fml = true;           fmr = true;     foldcolumn = true;
      foldenable = true;     foldexpr = true;    foldignore = true;      foldlevel = true;
      foldmarker = true;   foldmethod = true;  foldminlines = true;    foldnestmax = true;
        foldtext = true;          lbr = true;           lcs = true;      linebreak = true;
            list = true;    listchars = true;            nu = true;         number = true;
     numberwidth = true;          nuw = true; previewwindow = true;            pvw = true;
  relativenumber = true;    rightleft = true;  rightleftcmd = true;             rl = true;
             rlc = true;          rnu = true;           scb = true;            scl = true;
             scr = true;       scroll = true;    scrollbind = true;     signcolumn = true;
           spell = true;   statusline = true;           stl = true;            wfh = true;
             wfw = true;        winbl = true;      winblend = true;   winfixheight = true;
     winfixwidth = true; winhighlight = true;         winhl = true;           wrap = true;
}

local function validate(conf)
  assert(type(conf) == 'table')
  local type_names = {
    t='table', s='string', n='number', b='boolean', f='function', c='callable',
    ['table']='table', ['string']='string', ['number']='number',
    ['boolean']='boolean', ['function']='function', ['callable']='callable',
    ['nil']='nil', ['thread']='thread', ['userdata']='userdata',
  }
  for k, v in pairs(conf) do
    if not (v[3] and v[1] == nil) and type(v[1]) ~= type_names[v[2]] then
      error(string.format("validation_failed: %q: expected %s, received %s", k, type_names[v[2]], type(v[1])))
    end
  end
  return true
end

local function make_meta_accessor(get, set, del)
  validate {
    get = {get, 'f'};
    set = {set, 'f'};
    del = {del, 'f', true};
  }
  local mt = {}
  if del then
    function mt:__newindex(k, v)
      if v == nil then
        return del(k)
      end
      return set(k, v)
    end
  else
    function mt:__newindex(k, v)
      return set(k, v)
    end
  end
  function mt:__index(k)
    return get(k)
  end
  return setmetatable({}, mt)
end

local function pcall_ret(status, ...)
  if status then return ... end
end

local function nil_wrap(fn)
  return function(...)
    return pcall_ret(pcall(fn, ...))
  end
end

local fn = setmetatable({}, {
  __index = function(t, k)
    local f = function(...) return api.nvim_call_function(k, {...}) end
    rawset(t, k, f)
    return f
  end
})

local function getenv(k)
  local v = fn.getenv(k)
  if v == vim.NIL then
    return nil
  end
  return v
end

local function new_win_accessor(winnr)
  local function get(k)
    if winnr == nil and type(k) == 'number' then
      return new_win_accessor(k)
    end
    return api.nvim_win_get_var(winnr or 0, k)
  end
  local function set(k, v) return api.nvim_win_set_var(winnr or 0, k, v) end
  local function del(k)    return api.nvim_win_del_var(winnr or 0, k) end
  return make_meta_accessor(nil_wrap(get), set, del)
end

local function new_win_opt_accessor(winnr)
  local function get(k)
    if winnr == nil and type(k) == 'number' then
      return new_win_opt_accessor(k)
    end
    return api.nvim_win_get_option(winnr or 0, k)
  end
  local function set(k, v) return api.nvim_win_set_option(winnr or 0, k, v) end
  return make_meta_accessor(nil_wrap(get), set)
end

local function new_buf_accessor(bufnr)
  local function get(k)
    if bufnr == nil and type(k) == 'number' then
      return new_buf_accessor(k)
    end
    return api.nvim_buf_get_var(bufnr or 0, k)
  end
  local function set(k, v) return api.nvim_buf_set_var(bufnr or 0, k, v) end
  local function del(k)    return api.nvim_buf_del_var(bufnr or 0, k) end
  return make_meta_accessor(nil_wrap(get), set, del)
end

local function new_buf_opt_accessor(bufnr)
  local function get(k)
    if window_options[k] then
      return api.nvim_err_writeln(k.." is a window option, not a buffer option")
    end
    if bufnr == nil and type(k) == 'number' then
      return new_buf_opt_accessor(k)
    end
    return api.nvim_buf_get_option(bufnr or 0, k)
  end
  local function set(k, v)
    if window_options[k] then
      return api.nvim_err_writeln(k.." is a window option, not a buffer option")
    end
    return api.nvim_buf_set_option(bufnr or 0, k, v)
  end
  return make_meta_accessor(nil_wrap(get), set)
end

-- `nvim.$method(...)` redirects to `nvim.api.nvim_$method(...)`
-- `nvim.fn.$method(...)` redirects to `vim.api.nvim_call_function($method, {...})`
-- TODO `nvim.ex.$command(...)` is approximately `:$command {...}.join(" ")`
-- `nvim.print(...)` is approximately `echo vim.inspect(...)`
-- `nvim.echo(...)` is approximately `echo table.concat({...}, '\n')`
-- Both methods cache the inital lookup in the metatable, but there is api small overhead regardless.
return setmetatable({
  print = nvim_print;
  echo = nvim_echo;
  fn = rawget(vim, "fn") or fn;
  validate = validate;
  g = rawget(vim, 'g') or make_meta_accessor(nil_wrap(api.nvim_get_var), api.nvim_set_var, api.nvim_del_var);
  v = rawget(vim, 'v') or make_meta_accessor(nil_wrap(api.nvim_get_vvar), api.nvim_set_vvar);
  o = rawget(vim, 'o') or make_meta_accessor(api.nvim_get_option, api.nvim_set_option);
  w = new_win_accessor(nil);
  b = new_buf_accessor(nil);
  env = rawget(vim, "env") or make_meta_accessor(getenv, fn.setenv);
  wo = rawget(vim, "wo") or new_win_opt_accessor(nil);
  bo = rawget(vim, "bo") or new_buf_opt_accessor(nil);
  buf = {
    line = api.nvim_get_current_line;
    nr = api.nvim_get_current_buf;
  };
  ex = setmetatable({}, {
    __index = function(t, k)
      local command = k:gsub("_$", "!")
      local f = function(...)
        return api.nvim_command(table.concat(vim.tbl_flatten {command, ...}, " "))
      end
      rawset(t, k, f)
      return f
    end
  });
}, {
  __index = function(t, k)
    local f = api['nvim_'..k]
    if f then
      rawset(t, k, f)
    end
    return f
  end
})
-- vim:et ts=2 sw=2
