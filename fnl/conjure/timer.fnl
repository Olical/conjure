(local {: define} (require :conjure.nfnl.module))
(local vim _G.vim)

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

(fn M.interval [ms f]
  (let [t (vim.uv.new_timer)]
    (t:start ms ms (vim.schedule_wrap f))
    t))

M
