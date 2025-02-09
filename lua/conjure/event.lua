-- [nfnl] Compiled from fnl/conjure/event.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local nvim = autoload("conjure.aniseed.nvim")
local a = autoload("conjure.aniseed.core")
local text = autoload("conjure.text")
local client = autoload("conjure.client")
local str = autoload("conjure.aniseed.string")
local function emit(...)
  do
    local names = a.map(text["upper-first"], {...})
    local function _2_()
      while not a["empty?"](names) do
        nvim.ex.doautocmd("User", ("Conjure" .. str.join(names)))
        table.remove(names)
      end
      return nil
    end
    client.schedule(_2_)
  end
  return nil
end
return {emit = emit}
