(module conjure.config
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            config conjure.config2}})

;; TODO Delete this module since it's just a shim.

(defn- old->new-key [k]
  (-> k
      (string.gsub "^mappings$" "mapping")
      (string.gsub "^clients" "filetype_client")
      (string.gsub "%?$" "")
      (string.gsub "-" "_")))

(defn- old->new-client-ks [client]
  (when client
    (a.concat [:client] (str.split client "%."))))

(defn get [{: client : path}]
  (print "DEPRECATED: Get config through g:conjure#..., this approach will stop working soon.")
  (let [client-ks (old->new-client-ks client)
        ks (a.map old->new-key path)]
    (config.get-in (a.concat client-ks ks))))

(defn assoc [{: client : path : val}]
  (print "DEPRECATED: Set config through g:conjure#..., this approach will stop working soon.")
  (let [client-ks (old->new-client-ks client)
        ks (a.map old->new-key path)]
    (config.assoc-in (a.concat client-ks ks) val)))
