local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.event"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text")}
local a = _local_0_[1]
local client = _local_0_[2]
local nvim = _local_0_[3]
local str = _local_0_[4]
local text = _local_0_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.event"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local emit
do
  local v_0_
  local function emit0(...)
    do
      local names = a.map(text["upper-first"], {...})
      local function _1_()
        while not a["empty?"](names) do
          nvim.ex.doautocmd("User", ("Conjure" .. str.join(names)))
          table.remove(names)
        end
        return nil
      end
      client.schedule(_1_)
    end
    return nil
  end
  v_0_ = emit0
  _0_0["emit"] = v_0_
  emit = v_0_
end
return nil