-- [nfnl] Compiled from fnl/conjure/event.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.event"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, client, nvim, str, text = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function emit(...)
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
_2amodule_2a["emit"] = emit
do local _ = {emit, nil} end
return _2amodule_2a
