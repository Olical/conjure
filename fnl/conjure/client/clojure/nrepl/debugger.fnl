(module conjure.client.clojure.nrepl.debugger
  {autoload {a conjure.aniseed.core
             elisp conjure.remote.transport.elisp
             log conjure.log
             server conjure.client.clojure.nrepl.server}})

;; TODO Make all of this generic, have Conjure call client methods.

(defonce dap
  (let [(ok? dap) (pcall require :dap)]
    (if ok?
      dap
      (do
        (log.append
          [";; nvim-dap is required for debugging support https://github.com/mfussenegger/nvim-dap"]
          {:break? true})
        nil))))

(when dap
  (set
    dap.adapters.clojure
    (fn [cb config]
      (when (= :attach config.request)
        (a.println "I think here's where we connect to Conjure's internal DAP server")))))

(defn init []
  (server.send
    {:op :init-debugger}
    (fn [...]
      (a.println ...))))

(defn send [opts]
  (server.send
    {:op :debug-input
     :input (.. ":" (a.get opts :input))
     :key (a.get opts :key)}
    (fn [...]
      (a.println ...))))

(defn handle-input-request [msg]
  (a.println msg))

; (vim.json.encode)

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
