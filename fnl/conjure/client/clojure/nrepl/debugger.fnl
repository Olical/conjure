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
      (log.dbg "init-debugger response" msg)))
  nil)

;; TODO Highlight :line :column

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

;   {:code "(defn add
;             \"Hello, World!
;             This is a function.\"
;             [a b]
;             #dbg (+ a b))"
;    :column 1
;    :coor [4 1]
;    :debug-value "1"
;    :file "/home/olical/repos/Olical/conjure/dev/clojure/src/dev/sandbox.cljc"
;    :id "05a0f24c-6575-40fc-a1a7-39937fd07fbb"
;    :input-type ["continue"
;                 "locals"
;                 "inspect"
;                 "trace"
;                 "here"
;                 "continue-all"
;                 "next"
;                 "out"
;                 "inject"
;                 "stacktrace"
;                 "inspect-prompt"
;                 "quit"
;                 "in"
;                 "eval"]
;    :inspect "(\"Class\" \": \" (:value \"clojure.lang.PersistentArrayMap\" 0) (:newline) \"Contents: \" (:newline) \"  \" (:value \"a\" 1) \" = \" (:value \"1\" 2) (:newline) \"  \" (:value \"b\" 3) \" = \" (:value \"2\" 4) (:newline))"
;    :key "45dd9615-340a-49ad-8561-4d4739e15bea"
;    :line 11
;    :locals [["a" "1"] ["b" "2"]]
;    :original-id "64eb18b5-7319-4dac-8954-fc35c410206c"
;    :original-ns "dev.sandbox"
;    :prompt {}
;    :session "8d2503f0-bf45-44fa-b409-c34ab6eea13c"
;    :status ["need-debug-input"]}

;   (server.send
;     {:op :debug-middleware
;      :code "(+ 1 2)"
;      :file "dev/sandbox.cljc"
;      :ns "dev.sandbox"
;      :point [10 5]}
;     (fn [...]
;       (a.println ...))))
