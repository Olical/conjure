(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local elisp (autoload :conjure.remote.transport.elisp))
(local extract (autoload :conjure.extract))
(local log (autoload :conjure.log))
(local server (autoload :conjure.client.clojure.nrepl.server))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text))

(local M (define :conjure.client.clojure.nrepl.debugger))

(set M.state {:last-request nil})

(fn M.init []
  (log.append ["; Initialising CIDER debugger"] {:break? true})
  (server.send
    {:op :init-debugger}
    (fn [msg]
      (log.append ["; CIDER debugger initialized"] {:break? true})
      (log.dbg "init-debugger response" msg)))
  nil)

(fn M.send [opts]
  (let [key (core.get-in M.state [:last-request :key])]
    (if key
      (server.send
        {:op :debug-input
         :input (core.get opts :input)
         :key key}
        (fn [msg]
          (log.dbg "debug-input response" msg)
          (set M.state.last-request nil)))
      (log.append
        ["; Debugger is not awaiting input"]
        {:break? true}))))

(fn M.valid-inputs []
  (let [input-types (core.get-in M.state [:last-request :input-type])]
    (core.filter
      (fn [input-type]
        (not= :stacktrace input-type))
      (or input-types []))))

(fn M.render-inspect [inspect]
  (str.join
    (core.map
      (fn [v]
        (if (core.table? v)
          (let [head (core.first v)]
            (if
              (= :newline head) "\n"
              (= :value head) (core.second v)))
          v))
      inspect)))

(fn M.handle-input-request [msg]
  (set M.state.last-request msg)

  (log.append ["; CIDER debugger"] {:break? true})

  (when (not (core.empty? msg.inspect))
    (log.append
      (text.prefixed-lines
        (M.render-inspect (elisp.read msg.inspect))
        "; "
        {})
      {}))

  (when (not (core.nil? msg.debug-value))
    (log.append [(core.str "; Evaluation result => " msg.debug-value)] {}))

  (if (core.empty? msg.prompt)
    (log.append
      ["; Respond with :ConjureCljDebugInput [input]"
       (.. "; Inputs: " (str.join ", " (M.valid-inputs)))]
      {})
    (M.send {:input (extract.prompt msg.prompt)})))

(fn M.debug-input [opts]
  (if (core.some #(= opts.args $1) (M.valid-inputs))
    (M.send {:input (.. ":" opts.args)})
    (log.append
      [(.. "; Valid inputs: " (str.join ", " (M.valid-inputs)))])))

M
