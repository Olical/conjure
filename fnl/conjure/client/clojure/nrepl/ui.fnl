(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local state (autoload :conjure.client.clojure.nrepl.state))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text))

(local M (define :clojure.client.clojure.nrepl.ui))

(local cfg (config.get-in-fn [:client :clojure :nrepl]))

(fn handle-join-line [resp]
  (let [next-key (if resp.out :out resp.err :err)
        key (state.get :join-next :key)]
    (when (or next-key resp.value)
      (core.assoc (state.get) :join-next
                  (when (and next-key
                             (not (text.trailing-newline?
                                    (core.get resp next-key))))
                    {:key next-key})))
    (and next-key (= key next-key))))

(fn M.display-result [resp opts]
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

(fn M.display-sessions [sessions cb]
  (let [current (state.get :conn :session)]
    (log.append
      (core.concat
        [(.. "; Sessions (" (core.count sessions) "):")]
        (core.map-indexed
          (fn [[idx session]]
            (str.join
              ["; " (if (= current session.id) ">" " ")
               idx " - " (session.str)]))
          sessions))
      {:break? true})
    (when cb
      (cb))))

M
