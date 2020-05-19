(module conjure.client.janet.netrepl.ui
  {require {client conjure.client
            log conjure.log}})

(defn display [lines opts]
  (client.with-filetype :janet log.append lines opts))

