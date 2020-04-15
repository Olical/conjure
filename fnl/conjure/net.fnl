(module conjure.net
  {require {a conjure.aniseed.core}})

(defn resolve [host]
  (-> host
      (->> (vim.loop.getaddrinfo)
           (a.filter #(= "inet" (a.get $1 :family)))
           (a.first))
      (a.get :addr)))

