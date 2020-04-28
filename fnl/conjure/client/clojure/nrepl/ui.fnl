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

(defn display-result-fn [opts]
  "Sateful version of display-result that batches out/err text up until a
  newline or final nREPL message."
  (let [state {:out "" :err ""}]
    (fn [resp]
      (let [k (if resp.out :out resp.err :err)]
        (if k
          (let [s (a.get resp k)
                current (a.get state k)
                (start end) (string.find (string.reverse s) "\n")]
            (if start
              (if (= 1 start)
                ;; Not sure if this edge case is required.
                ;; Removing the need for trim might fix this?
                (do
                  (a.assoc state k "")
                  (a.assoc resp k (.. current s))
                  (display-result resp opts))
                (let [before (string.sub s 1 (- start))
                      after (string.sub s (- end))]
                  (a.assoc state k after)
                  (a.assoc resp k (.. current before))
                  (display-result resp opts)))
              (do
                (a.assoc
                  state k
                  (.. current s))
                nil)))
          (do
            (when resp.value
              (a.run!
                (fn [k]
                  (let [s (a.get state k)]
                    (when (not (a.empty? s))
                      (display-result {k s}))))
                [:out :err]))
            (display-result resp opts)))))))

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
