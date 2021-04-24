(module conjure.promise
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             uuid conjure.uuid}})

(defonce- state {})

(defn new []
  (let [id (uuid.v4)]
    (a.assoc
      state id
      {:id id
       :val nil
       :done? false})
    id))

(defn done? [id]
  (a.get-in state [id :done?]))

(defn deliver [id val]
  (when (= false (done? id))
    (a.assoc-in state [id :val] val)
    (a.assoc-in state [id :done?] true))
  nil)

(defn deliver-fn [id]
  #(deliver id $1))

(defn close [id]
  (let [val (a.get-in state [id :val])]
    (a.assoc state id nil)
    val))

(defn await [id opts]
  (nvim.fn.wait
    (a.get opts :timeout 10000)
    (.. "luaeval(\"require('conjure.promise')['done?']('" id "')\")")
    (a.get opts :interval 50)))
