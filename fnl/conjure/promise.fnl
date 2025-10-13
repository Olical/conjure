(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local uuid (autoload :conjure.uuid))

(local M (define :conjure.promise))

(local state {})

(fn M.new []
  (let [id (uuid.v4)]
    (core.assoc
      state id
      {:id id
       :val nil
       :done? false})
    id))

(fn M.done? [id]
  (core.get-in state [id :done?]))

(fn M.deliver [id val]
  (when (= false (M.done? id))
    (core.assoc-in state [id :val] val)
    (core.assoc-in state [id :done?] true))
  nil)

(fn M.deliver-fn [id]
  #(M.deliver id $1))

(fn M.close [id]
  (let [val (core.get-in state [id :val])]
    (core.assoc state id nil)
    val))

(fn M.await [id opts]
  (vim.fn.wait
    (core.get opts :timeout 10000)
    (.. "luaeval(\"require('conjure.promise')['done?']('" id "')\")")
    (core.get opts :interval 50)))

M
