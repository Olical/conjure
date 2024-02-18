local _2afile_2a = "test/fnl/conjure/process-test.fnl"
local _2amodule_name_2a = "conjure.process-test"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local nvim, process = require("conjure.aniseed.nvim"), require("conjure.process")
do end (_2amodule_locals_2a)["nvim"] = nvim
_2amodule_locals_2a["process"] = process
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["="](false, process["executable?"]("nope-this-does-not-exist"), "thing's that don't exist return false")
    t["="](true, process["executable?"]("sh"), "sh should always exist, I hope")
    return t["="](true, process["executable?"]("sh foo bar"), "only the first word is checked")
  end
  tests_24_auto["executable?"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    local sh = process.execute("sh")
    t["="]("table", type(sh), "we get a table to identify the process")
    t["="](true, process["running?"](sh), "it starts out as running")
    t["="](false, process["running?"](nil), "the running check handles nils")
    t["="](1, nvim.fn.bufexists(sh.buf), "a buffer is created for the terminal / process")
    t["="](sh, process.stop(sh), "stopping returns the process table")
    t["="](sh, process.stop(sh), "stopping is idempotent")
    return t["="](false, process["running?"](sh), "now it's not running")
  end
  tests_24_auto["execute-stop-lifecycle"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    local state = {args = nil}
    local sh
    local function _4_(...)
      state["args"] = {...}
      return nil
    end
    sh = process.execute("sh", {["on-exit"] = _4_})
    process.stop(sh)
    return t["pr="]({sh}, state.args, "called and given the proc")
  end
  tests_24_auto["on-exit-hook"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a