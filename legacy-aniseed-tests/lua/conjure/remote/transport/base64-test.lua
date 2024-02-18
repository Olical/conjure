local _2afile_2a = "test/fnl/conjure/remote/transport/base64-test.fnl"
local _2amodule_name_2a = "conjure.remote.transport.base64-test"
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
local b64 = require("conjure.remote.transport.base64")
do end (_2amodule_locals_2a)["b64"] = b64
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["="]("", b64.encode(""), "empty to empty")
    t["="]("SGVsbG8sIFdvcmxkIQ==", b64.encode("Hello, World!"), "simple text to base64")
    return t["="]("Hello, World!", b64.decode("SGVsbG8sIFdvcmxkIQ=="), "base64 back to text")
  end
  tests_24_auto["basic"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a