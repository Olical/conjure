local _2afile_2a = "test/fnl/conjure/remote/transport/bencode-test.fnl"
local _2amodule_name_2a = "conjure.remote.transport.bencode-test"
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
local bencode = require("conjure.remote.transport.bencode")
do end (_2amodule_locals_2a)["bencode"] = bencode
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    local bs = bencode.new()
    local data = {foo = {"bar"}}
    t["="](bs.data, "", "data starts empty")
    t["pr="]({data}, bencode["decode-all"](bs, bencode.encode(data)), "a single bencoded value")
    return t["="](bs.data, "", "data is empty after a decode")
  end
  tests_24_auto["basic"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    local bs = bencode.new()
    local data_a = {foo = {"bar"}}
    local data_b = {1, 2, 3}
    t["="](bs.data, "", "data starts empty")
    t["pr="]({data_a, data_b}, bencode["decode-all"](bs, (bencode.encode(data_a) .. bencode.encode(data_b))), "two bencoded values")
    return t["="](bs.data, "", "data is empty after a decode")
  end
  tests_24_auto["multiple-values"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    local bs = bencode.new()
    local data_a = {foo = {"bar"}}
    local data_b = {1, 2, 3}
    local encoded_b = bencode.encode(data_b)
    t["="](bs.data, "", "data starts empty")
    t["pr="]({data_a}, bencode["decode-all"](bs, (bencode.encode(data_a) .. string.sub(encoded_b, 1, 3))), "first value")
    t["="]("li1", bs.data, "after first, data contains partial data-b")
    t["pr="]({data_b}, bencode["decode-all"](bs, string.sub(encoded_b, 4)), "second value after rest of data")
    return t["="](bs.data, "", "data is empty after a decode")
  end
  tests_24_auto["partial-values"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a