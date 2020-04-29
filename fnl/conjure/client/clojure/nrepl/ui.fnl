(module conjure.client.clojure.nrepl.ui
  {require {client conjure.client
            log conjure.log
            text conjure.text
            a conjure.aniseed.core
            state conjure.client.clojure.nrepl.state}})

(defn display [lines opts]
  (client.with-filetype :clojure log.append lines opts))

(defonce- state
  {:join-next-key nil})

(defn- handle-join-line [resp]
  (let [next-k (if resp.out :out resp.err :err)
        current-k (a.get state :join-next-key)]
    (when (or next-k resp.value)
      (a.assoc state :join-next-key
               (when (and next-k
                          (not (text.trailing-newline?
                                 (a.get resp next-k))))
                 next-k)))
    (and next-k (= current-k next-k))))

(defn display-result [resp opts]
  (local opts (or opts {}))
  (let [joined? (handle-join-line resp)]
    (display
      (if
        resp.out
        (text.prefixed-lines
          (text.trim-last-newline resp.out)
          (if
            opts.simple-out? "; "
            opts.raw-out? ""
            "; (out) ")
          {:skip-first? joined?})

        resp.err
        (text.prefixed-lines
          (text.trim-last-newline resp.err)
          "; (err) "
          {:skip-first? joined?})

        resp.value
        (when (not (and opts.ignore-nil? (= "nil" resp.value)))
          (text.split-lines resp.value))

        nil)
      {:join-first? joined?})))

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
