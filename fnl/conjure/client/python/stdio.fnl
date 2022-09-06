(module conjure.client.python.stdio
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
             ts conjure.tree-sitter}
   require-macros [conjure.macros]})

(config.merge
  {:client
   {:python
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"
                :interrupt "ei"}
      :command "python3 -iq"
      :prompt_pattern ">>> "}}}})

(def- cfg (config.get-in-fn [:client :python :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".py")
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

; If python cannot determine whether you are done with your statement after
; a single newline, it will sit and wait for you to enter another newline.
; This happens if you are in the body of a for loop for example.
; We always send 2 newlines because this should cover us in all cases.
(defn- prep-code [s]
  (.. s "\n\n"))

(defn unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(defn format-msg [msg]
  (->> (str.split msg "\n")
       (a.filter #(~= "" $1))))

; If, after pressing newline, the python interpreter expects more
; input from you (as is the case after the first line of an if branch or for loop)
; the python interpreter will output "..." to show that it is waiting for more input.
; We want to detect these lines and ignore them in many cases.
;
; Note: This is check will yield some false positives. For example if a user evaluates
;   print("... <-- check out those dots")
; the output will be flagged as one of these special "dots" lines. This should probably
; be smarter...
(defn- is-dots? [s]
  (= (string.sub s 1 3) "..."))

(defn- get-console-output-msgs [msgs]
  (->> (a.butlast msgs)
       (a.filter #(not (is-dots? $1)))
       (a.map #(.. comment-prefix "(out) " $1))))

(defn- get-result [msgs]
  (let [result (a.last msgs)]
    (if
      (or (a.nil? result) (is-dots? result))
      nil
      result)))

(defn- log-repl-output [msgs]
  (let [msgs (-> msgs unbatch format-msg)
        console-output-msgs (get-console-output-msgs msgs)
        cmd-result (get-result msgs)]
    (when (not (a.empty? console-output-msgs))
      (log.append console-output-msgs))
    (when cmd-result
      (log.append [cmd-result]))))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (log-repl-output msgs)
          (when opts.on-result
            (opts.on-result (str.join " " msgs))))
        {:batch? true}))))

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

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

; By default, there is no way for us to tell the difference between
; normal stdout log messages and the result of the expression we evaluated.
; This is because if an expression results in the literal value None, the python
; interpreter will not print out anything.

; Replacing this hook ensures that the last line in the output after
; sending a command is the result of the command.
; Relevant docs: https://docs.python.org/3/library/sys.html#sys.displayhook
(def update-python-displayhook
  (.. "import sys\n"
      "def format_output(val):\n"
      "    print(repr(val))\n\n"
      "sys.displayhook = format_output\n"))

(defn start []
  (if (state :repl)
    (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                 (.. comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (a.assoc
      (state) :repl
      (stdio.start
        {:prompt-pattern (cfg [:prompt_pattern])
         :cmd (cfg [:command])

         :on-success
         (fn []
           (display-repl-status :started
            (with-repl-or-warn
             (fn [repl]
               (repl.send
                 (prep-code update-python-displayhook)
                 log-repl-output
                 {:batch? true})))))

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
           (log.dbg (-> [msg] unbatch format-msg) {:join-first? true}))}))))

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
  (mapping.buf :n :PythonStart (cfg [:mapping :start]) *module-name* :start)
  (mapping.buf :n :PythonStop (cfg [:mapping :stop]) *module-name* :stop)
  (mapping.buf :n :PythonInterrupt (cfg [:mapping :interrupt]) *module-name* :interrupt))
