local _2afile_2a = "fnl/conjure/proc.fnl"
local _0_
do
  local name_0_ = "conjure.proc"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_ = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local nvim = _local_0_[1]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.proc"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local executable_3f
do
  local v_0_
  do
    local v_0_0
    local function executable_3f0(name)
      return (1 == nvim.fn.executable(name))
    end
    v_0_0 = executable_3f0
    _0_["executable?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["executable?"] = v_0_
  executable_3f = v_0_
end
-- (executable? bb) (executable? nope-this-doesnt)
local execute
do
  local v_0_
  do
    local v_0_0
    local function execute0(cmd)
      local win = nvim.tabpage_get_win(0)
      local original_buf = nvim.win_get_buf(win)
      local term_buf = nvim.create_buf(true, true)
      nvim.win_set_buf(win, term_buf)
      local job_id = nvim.fn.termopen(cmd)
      do
        local _2_ = job_id
        if (_2_ == 0) then
          error("invalid arguments or job table full")
        elseif (_2_ == -1) then
          error(("'" .. cmd .. "' is not executable"))
        end
      end
      nvim.win_set_buf(win, original_buf)
      return {["job-id"] = job_id, buf = term_buf, cmd = cmd}
    end
    v_0_0 = execute0
    _0_["execute"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["execute"] = v_0_
  execute = v_0_
end
-- (execute bb nrepl-server)
return nil