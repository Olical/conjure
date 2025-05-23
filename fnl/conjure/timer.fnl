(local {: define} (require :nfnl.module))

(local M (define :conjure.timer))

(fn M.defer [f ms]
  (let [t (vim.uv.new_timer)]
    (t:start ms 0 (vim.schedule_wrap f))
    t))

(fn M.destroy [t]
  (when t
    (t:stop)
    (t:close))
  nil)

M
