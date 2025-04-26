-- [nfnl] fnl/conjure/bridge.fnl
local function viml__3elua(m, f, opts)
  return ("lua require('" .. m .. "')['" .. f .. "'](" .. ((opts and opts.args) or "") .. ")")
end
return {["viml->lua"] = viml__3elua}
