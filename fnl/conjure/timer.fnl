(module conjure.timer
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim}})

(defn defer [f ms]
  (let [t (vim.loop.new_timer)]
    (t:start ms 0 (vim.schedule_wrap f))
    t))

(defn destroy [t]
  (when t
    (t:stop)
    (t:close))
  nil)
