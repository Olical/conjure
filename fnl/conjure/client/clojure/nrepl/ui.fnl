(module conjure.client.clojure.nrepl.ui
  {autoload {log conjure.log
             text conjure.text
             config conjure.config
             a conjure.aniseed.core
             str conjure.aniseed.string
             state conjure.client.clojure.nrepl.state}})

(def- cfg (config.get-in-fn [:client :clojure :nrepl]))

(defn- handle-join-line [resp]
  (let [next-key (if resp.out :out resp.err :err)
        key (state.get :join-next :key)]
    (when (or next-key resp.value)
      (a.assoc (state.get) :join-next
               (when (and next-key
                          (not (text.trailing-newline?
                                 (a.get resp next-key))))
                 {:key next-key})))
    (and next-key (= key next-key))))

(defn display-result [resp opts]
  (local opts (or opts {}))
  (let [joined? (handle-join-line resp)]
    (log.append
      (if
        resp.out
        (text.prefixed-lines
          (text.trim-last-newline resp.out)
          (if
            (or opts.raw-out? (cfg [:eval :raw_out])) ""
            opts.simple-out? "; "
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

(defn display-sessions [sessions cb]
  (let [current (state.get :conn :session)]
    (log.append
      (a.concat [(.. "; Sessions (" (a.count sessions) "):")]
                (a.map-indexed
                  (fn [[idx session]]
                    (str.join
                      ["; " (if (= current session.id) ">" " ")
                       idx " - " (session.str)]))
                  sessions))
      {:break? true})
    (when cb
      (cb))))
