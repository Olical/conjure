(local autoload (require :nfnl.autoload))
(local a (autoload :conjure.aniseed.core))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local state (autoload :conjure.client.clojure.nrepl.state))
(local str (autoload :conjure.aniseed.string))
(local text (autoload :conjure.text))

(local cfg (config.get-in-fn [:client :clojure :nrepl]))

(fn handle-join-line [resp]
  (let [next-key (if resp.out :out resp.err :err)
        key (state.get :join-next :key)]
    (when (or next-key resp.value)
      (a.assoc (state.get) :join-next
               (when (and next-key
                          (not (text.trailing-newline?
                                 (a.get resp next-key))))
                 {:key next-key})))
    (and next-key (= key next-key))))

(fn display-result [resp opts]
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
      {:join-first? joined?
       :low-priority? (not (not (or resp.out resp.err)))})))

(fn display-sessions [sessions cb]
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

{: display-result : display-sessions }
