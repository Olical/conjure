-- [nfnl] Compiled from fnl/conjure/client/guile/nrepl.fnl by https://github.com/Olical/nfnl, do not edit.
module(conjure.client.guile.nrepl, {[autoload] = {[nvim] = conjure.aniseed.nvim, [a] = conjure.aniseed.core, [mapping] = conjure.mapping, [eval] = conjure.eval, [str] = conjure.aniseed.string, [text] = conjure.text, [config] = conjure.config, [client] = conjure.client, [util] = conjure.util, [ts] = conjure["tree-sitter"]}})
config.merge({client = {guile = {nrepl = {default_host = "localhost", port_files = {".nrepl-port"}}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {guile = {nrepl = {mapping = {disconnect = "cd", connect_port_file = "cf", interrupt = "ei"}}}}})
else
end
__fnl_global__def_2d(cfg, config["get-in-fn"]({"client", "guile", "nrepl"}))
local function _2_()
  return {repl = nil}
end
__fnl_global__defonce_2d(state, client["new-state"](_2_))
def(__fnl_global__buf_2dsuffix, ".scm")
def(__fnl_global__comment_2dprefix, "; ")
def(__fnl_global__context_2dpattern, "%(define%-module%s+(%([%g%s]-%))")
def(__fnl_global__form_2dnode_3f, ts["node-surrounded-by-form-pair-chars?"])
def(__fnl_global__comment_2dnode_3f, ts["lisp-comment-node?"])
defn(__fnl_global__symbol_2dnode_3f, {node}, string.find(node:type(), "kwd"))
local function _8_(...)
  if (nil ~= header) then
    local tmp_3_auto = parse["strip-shebang"](header)
    if (nil ~= tmp_3_auto) then
      local tmp_3_auto0 = parse["strip-meta"](tmp_3_auto)
      if (nil ~= tmp_3_auto0) then
        local tmp_3_auto1 = parse["strip-comments"](tmp_3_auto0)
        if (nil ~= tmp_3_auto1) then
          local tmp_3_auto2 = string.match(tmp_3_auto1, "%(%s*ns%s+([^)]*)")
          if (nil ~= tmp_3_auto2) then
            local tmp_3_auto3 = str.split(tmp_3_auto2, "%s+")
            if (nil ~= tmp_3_auto3) then
              return a.first(tmp_3_auto3)
            else
              return nil
            end
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
defn(context, {header}, _8_(...))
defn(__fnl_global__eval_2dfile, {opts}, __fnl_global__eval_2dfile(opts))
defn(__fnl_global__eval_2dstr, {opts}, __fnl_global__eval_2dstr(opts))
defn(__fnl_global__doc_2dstr, {opts}, __fnl_global__doc_2dstr(opts))
defn(__fnl_global__def_2dstr, {opts}, __fnl_global__def_2dstr(opts))
defn(connect, {opts}, __fnl_global__connect_2dhost_2dport(opts))
defn(__fnl_global__on_2dfiletype, {}, mapping.buf("GuileDisconnect", cfg({"mapping", "disconnect"}), util["wrap-require-fn-call"]("conjure.client.guile.nrepl", "disconnect"), {desc = "Disconnect from the current nREPL"}), mapping.buf("GuileConnectPortFile", cfg({"mapping", "connect_port_file"}), util["wrap-require-fn-call"]("conjure.client.guile.nrepl", "connect-port-file"), {desc = "Connect to port specified in .nrepl-port"}), mapping.buf("GuileInterrupt", cfg({"mapping", "interrupt"}), util["wrap-require-fn-call"]("conjure.client.guile.nrepl", "interrupt"), {desc = "Interrupt the current evaluation"}))
defn(__fnl_global__on_2dload, {}, __fnl_global__connect_2dport_2dfile())
return defn(__fnl_global__on_2dexit, {}, disconnect())
