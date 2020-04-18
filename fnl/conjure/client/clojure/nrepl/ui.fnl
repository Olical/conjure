(module conjure.client.clojure.nrepl.ui
  {require {client conjure.client
            log conjure.log
            text conjure.text
            a conjure.aniseed.core
            state conjure.client.clojure.nrepl.state}})

(defn display [lines opts]
  (client.with-filetype :clojure log.append lines opts))

(defn display-result [resp opts]
  (local opts (or opts {}))
  (display
    (if
      resp.out
      (text.prefixed-lines
        resp.out
        (if
          opts.simple-out? "; "
          opts.raw-out? ""
          "; (out) "))

      resp.err
      (text.prefixed-lines resp.err "; (err) ")

      resp.value
      (when (not (and opts.ignore-nil? (= "nil" resp.value)))
        (text.split-lines resp.value))

      nil)))

(defn display-given-sessions [sessions cb]
  (let [current (a.get-in state [:conn :session])]
    (display (a.concat [(.. "; Sessions (" (a.count sessions) "):")]
                       (a.map-indexed (fn [[idx session]]
                                        (.. ";  " idx " - " session
                                            (if (= current session)
                                              " (current)"
                                              "")))
                                      sessions))
             {:break? true})
    (when cb
      (cb sessions))))
