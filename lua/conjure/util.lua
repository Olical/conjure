-- [nfnl] fnl/conjure/util.fnl
local function wrap_require_fn_call(mod, f)
  local function _1_()
    return require(mod)[f]()
  end
  return _1_
end
local function replace_termcodes(s)
  return vim.api.nvim_replace_termcodes(s, true, false, true)
end
return {["wrap-require-fn-call"] = wrap_require_fn_call, ["replace-termcodes"] = replace_termcodes}
