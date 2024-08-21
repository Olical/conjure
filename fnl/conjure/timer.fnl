(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local nvim (autoload :conjure.aniseed.nvim))

(fn defer [f ms]
  ;; vim.loop is deprecated in Neovim 0.10. Use vim.uv instead.
  (let [t (vim.loop.new_timer)]
    (t:start ms 0 (vim.schedule_wrap f))
    t))

(fn destroy [t]
  (when t
    (t:stop)
    (t:close))
  nil)

{
 : defer
 : destroy
 }
