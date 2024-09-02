(local autoload (require :nfnl.autoload))
(local a (autoload :conjure.aniseed.core))
(local client (autoload :conjure.client))
(local elisp (autoload :conjure.remote.transport.elisp))
(local extract (autoload :conjure.extract))
(local log (autoload :conjure.log))
(local server (autoload :conjure.client.clojure.nrepl.server))
(local str (autoload :conjure.aniseed.string))
(local text (autoload :conjure.text))

(local state {:last-request nil})

(fn init []
  (log.append ["; Initialising CIDER debugger"] {:break? true})
  (server.send
    {:op :init-debugger}
    (fn [msg]
      (log.append ["; CIDER debugger initialized"] {:break? true})
      (log.dbg "init-debugger response" msg)))
  nil)

(fn send [opts]
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

(fn valid-inputs []
  (let [input-types (a.get-in state [:last-request :input-type])]
    (a.filter
      (fn [input-type]
        (not= :stacktrace input-type))
      (or input-types []))))

(fn render-inspect [inspect]
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

(fn handle-input-request [msg]
  (set state.last-request msg)

  (log.append ["; CIDER debugger"] {:break? true})

  (when (not (a.empty? msg.inspect))
    (log.append
      (text.prefixed-lines
        (render-inspect (elisp.read msg.inspect))
        "; "
        {})
      {}))

  (when (not (a.nil? msg.debug-value))
    (log.append [(a.str "; Evaluation result => " msg.debug-value)] {}))

  (if (a.empty? msg.prompt)
    (log.append
      ["; Respond with :ConjureCljDebugInput [input]"
       (.. "; Inputs: " (str.join ", " (valid-inputs)))]
      {})
    (send {:input (extract.prompt msg.prompt)})))

(fn debug-input [opts]
  (if (a.some #(= opts.args $1) (valid-inputs))
    (send {:input (.. ":" opts.args)})
    (log.append
      [(.. "; Valid inputs: " (str.join ", " (valid-inputs)))])))

{: debug-input
 : handle-input-request
 : init
 : render-inspect
 : send
 : state
 : valid-inputs}
