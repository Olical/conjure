(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local nvim (autoload :conjure.aniseed.nvim))
(local uuid (autoload :conjure.uuid))

(local state {})

(fn new []
  (let [id (uuid.v4)]
    (a.assoc
      state id
      {:id id
       :val nil
       :done? false})
    id))

(fn done? [id]
  (a.get-in state [id :done?]))

(fn deliver [id val]
  (when (= false (done? id))
    (a.assoc-in state [id :val] val)
    (a.assoc-in state [id :done?] true))
  nil)

(fn deliver-fn [id]
  #(deliver id $1))

(fn close [id]
  (let [val (a.get-in state [id :val])]
    (a.assoc state id nil)
    val))

(fn await [id opts]
  (nvim.fn.wait
    (a.get opts :timeout 10000)
    (.. "luaeval(\"require('conjure.promise')['done?']('" id "')\")")
    (a.get opts :interval 50)))

{
 : new
 : done?
 : deliver
 : deliver-fn
 : close
 : await
 }
