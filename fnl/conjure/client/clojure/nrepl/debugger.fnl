(module conjure.client.clojure.nrepl.debugger
  {autoload {log conjure.log
             extract conjure.extract
             text conjure.text
             client conjure.client
             a conjure.aniseed.core
             str conjure.aniseed.string
             elisp conjure.remote.transport.elisp
             server conjure.client.clojure.nrepl.server}})

(defonce state {:last-request nil})

(defn init []
  (log.append ["; Initialising CIDER debugger"] {:break? true})
  (server.send
    {:op :init-debugger}
    (fn [msg]
      (log.append ["; CIDER debugger initialized"] {:break? true})
      (log.dbg "init-debugger response" msg)))
  nil)

(defn send [opts]
  (let [key (a.get-in state [:last-request :key])]
    (if key
      (server.send
        {:op :debug-input
         :input (a.get opts :input)
         :key key}
        (fn [msg]
          (log.dbg "debug-input response" msg)
          (set state.last-request nil)))
      (log.append
        ["; Debugger is not awaiting input"]
        {:break? true}))))

(defn valid-inputs []
  (let [input-types (a.get-in state [:last-request :input-type])]
    (a.filter
      (fn [input-type]
        (not= :stacktrace input-type))
      (or input-types []))))

(defn render-inspect [inspect]
  (str.join
    (a.map
      (fn [v]
        (if (a.table? v)
          (let [head (a.first v)]
            (if
              (= :newline head) "\n"
              (= :value head) (a.second v)))
          v))
      inspect)))

(defn handle-input-request [msg]
  (set state.last-request msg)

  (log.append ["; CIDER debugger"] {:break? true})

  (when (not (a.empty? msg.inspect))
    (log.append
      (text.prefixed-lines
        (render-inspect (elisp.read msg.inspect))
        "; "
        {})
      {}))

  (if (a.empty? msg.prompt)
    (log.append
      ["; Respond with :ConjureCljDebugInput [input]"
       (.. "; Inputs: " (str.join ", " (valid-inputs)))]
      {})
    (send {:input (extract.prompt msg.prompt)})))

(defn debug-input [opts]
  (if (a.some #(= opts.args $1) (valid-inputs))
    (send {:input (.. ":" opts.args)})
    (log.append
      [(.. "; Valid inputs: " (str.join ", " (valid-inputs)))])))
