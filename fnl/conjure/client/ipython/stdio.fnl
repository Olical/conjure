(module conjure.client.ipython.stdio
  {autoload {a conjure.aniseed.core
             extract conjure.extract
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio
             config conjure.config
             text conjure.text
             mapping conjure.mapping
             client conjure.client
             log conjure.log
             ts conjure.tree-sitter
             b64 conjure.remote.transport.base64}
   require-macros [conjure.macros]})

(config.merge
  {:client
   {:ipython
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"
                :interrupt "ei"}
      :command "ipython --no-autoindent --colors=NoColor"
      :prompt-pattern "In %[%d+%]: "
      :delay-stderr-ms 10
      :env {}}}}})


(def- cfg (config.get-in-fn [:client :ipython :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".ipynb")
(def comment-prefix "# ")

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")
                   (.. comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))


; Returns whether a given expression node is an assignment expression
; An assignment expression seems to be a weird case where it does not actually
; evaluate to anything so it seems more like a statement
(defn is-assignment?
  [node]
  (and (= (node:child_count) 1)
       (let [child (node:child 0)]
         (= (child:type) "assignment"))))

(defn is-expression?
  [node]
  (and (= "expression_statement" (node:type))
       (not (is-assignment? node))))

; Returns whether the string passed in is a simple python
; expression or something more complicated. If it is an expression,
; it can be passed to the REPL as is.
; Otherwise, we evaluate it as a multiline string using "exec". This is a simple
; way for us to not worry about extra or missing newlines in the middle of the code
; we are trying to evaluate at the REPL.
;
; For example, this Python code:
;   for i in range(5):
;       print(i)
;   def foo():
;       print("bar")
; while valid Python code, would not work in the REPL because the REPL expects 2 newlines
; after the for loop body.
;
; In addition, this Python code:
;   for i in range(5):
;       print(i)
;
;       print(i)
; while also valid Python code, would not work in the REPL because the REPL thinks the for loop
; body is over after the first "print(i)" (because it is followed by 2 newlines).
;
; Sending statements like these as a multiline string to Python's exec seems to be a decent workaround
; for this. Another option that I have seen used in some other similar projects is sending the statement
; as a "bracketed paste" (https://cirw.in/blog/bracketed-paste) so the REPL treats the input as if it were
; "pasted", but I couldn't get this working.
(defn str-is-python-expr?
  [s]
  (let [parser (vim.treesitter.get_string_parser s "python")
        result (parser:parse)
        tree (a.get result 1)
        root (tree:root)]
    (and (= 1 (root:child_count))
         (is-expression? (root:child 0)))))

(defn- get-exec-str
  [s]
  (.. "exec(base64.b64decode('" (b64.encode s) "'))\n"))

(defn- prep-code [s]
  (let [python-expr (str-is-python-expr? s)]
    (if python-expr
      (.. s "\n")
      (get-exec-str s))))
      
(defn format-msg [msg]
  (->> (text.split-lines msg)
       (a.filter #(~= "" $1))))

(defn- get-console-output-msgs [msgs]
  (->> msgs
       (a.map #(.. comment-prefix "(out) " $1))))

(defn unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(defn- log-repl-output [msgs]
  (a.pr "log-repl-output")
  (a.pr msgs)
  (let [msgs (-> msgs unbatch format-msg)
        console-output-msgs (get-console-output-msgs msgs)]
    (when (not (a.empty? console-output-msgs))
      (log.append console-output-msgs))))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (log-repl-output msgs))
        {:batch? true}))))

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(defn get-help [code]
  (str.join "" ["help(" (str.trim code) ")"]))

(defn doc-str [opts]
  (when (str-is-python-expr? opts.code)
    (eval-str (a.assoc opts :code (get-help opts.code)))))

(defn get-form-modifier [node]
  (let [p (ts.parent node)]
    (if (= "module" (p:type))
      {:modifier :node
       :node p}
      {:modifier :parent})))

(defn- display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. comment-prefix (a.pr-str (a.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(defn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(defn start []
  (if (state :repl)
    (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                 (.. comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (if (not (pcall #(vim.treesitter.require_language "python")))
      (log.append [(.. comment-prefix "(error) The python client requires a python treesitter parser in order to function.")
                   (.. comment-prefix "(error) See https://github.com/nvim-treesitter/nvim-treesitter")
                   (.. comment-prefix "(error) for installation instructions.")])
      (a.assoc
        (state) :repl
        (stdio.start
          {:prompt-pattern (cfg [:prompt-pattern])
           :cmd (cfg [:command])
           :delay-stderr-ms (cfg [:delay-stderr-ms])
           :env {:INPUTRC "~/.inputrc"}

           :on-success
           (fn []
             (display-repl-status :started)
             (with-repl-or-warn
               (fn [repl]
                 (repl.send
                   "import base64\n"
                   (fn [msgs] nil)
                   nil))))

           :on-error
           (fn [err]
             (display-repl-status err))

           :on-exit
           (fn [code signal]
             (when (and (= :number (type code)) (> code 0))
               (log.append [(.. comment-prefix "process exited with code " code)]))
             (when (and (= :number (type signal)) (> signal 0))
               (log.append [(.. comment-prefix "process exited with signal " signal)]))
             (stop))

           :on-stray-output
           (fn [msg]
             (log.append (-> [msg] unbatch format-msg)))})))))

(defn on-load []
  (start))

(defn on-exit []
  (stop))

(defn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (let [uv vim.loop]
        (uv.kill repl.pid uv.constants.SIGINT)))))

(defn on-filetype []
  (mapping.buf
    :IPythonStart (cfg [:mapping :start])
    start
    {:desc "Start the Python REPL"})

  (mapping.buf
    :IPythonStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the Python REPL"})

  (mapping.buf
    :IPythonInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the current evaluation"}))
  

