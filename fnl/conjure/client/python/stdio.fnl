(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local extract (autoload :conjure.extract))
(local str (autoload :conjure.aniseed.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))
(local b64 (autoload :conjure.remote.transport.base64))

(config.merge
  {:client
   {:python
    {:stdio
     {:command "python3 -iq"
      :prompt-pattern ">>> "
      :delay-stderr-ms 10}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:python
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :python :stdio]))
(local state (client.new-state #(do {:repl nil})))
(local buf-suffix ".py")
(local comment-prefix "# ")

; These types of nodes are roughly equivalent to Lisp forms.
; This should make it more intuitive to use <localLeader>ee to evaluate the
; "current form" and not be surprised that it wasn't what you thought.
(fn form-node?
  [node]
  (or (= "expression_statement" (node:type))
      (= "import_statement" (node:type))
      (= "import_from_statement" (node:type))
      (= "with_statement" (node:type))
      (= "function_definition" (node:type))
      (= "for_statement" (node:type))
      (= "call" (node:type))))

(fn with-repl-or-warn [f opts]
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
(fn is-assignment?
  [node]
  (and (= (node:child_count) 1)
       (let [child (node:child 0)]
         (= (child:type) "assignment"))))

(fn is-expression?
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
(fn str-is-python-expr?
  [s]
  (let [parser (vim.treesitter.get_string_parser s "python")
        result (parser:parse)
        tree (a.get result 1)
        root (tree:root)]
    (and (= 1 (root:child_count))
         (is-expression? (root:child 0)))))

(fn get-exec-str
  [s]
  (.. "import base64\nexec(base64.b64decode('" (b64.encode s) "'))\n"))

(fn prep-code [s]
  (let [python-expr (str-is-python-expr? s)]
    (if python-expr
      (.. s "\n")
      (get-exec-str s))))

; If, after pressing newline, the python interpreter expects more
; input from you (as is the case after the first line of an if branch or for loop)
; the python interpreter will output "..." to show that it is waiting for more input.
; We want to detect these lines and ignore them.
; Note: This is check will yield some false positives. For example if a user evaluates
;   print("... <-- check out those dots")
; the output will be flagged as one of these special "dots" lines. This could probably
; be smarter, but will work for most normal cases for now.
(fn is-dots? [s]
  (= (string.sub s 1 3) "..."))

(fn format-msg [msg]
  (->> (text.split-lines msg)
       (a.filter #(~= "" $1))
       (a.filter #(not (is-dots? $1)))))

(fn get-console-output-msgs [msgs]
  (->> (a.butlast msgs)
       (a.map #(.. comment-prefix "(out) " $1))))

(fn get-expression-result [msgs]
  (let [result (a.last msgs)]
    (if
      (or (a.nil? result) (is-dots? result))
      nil
      result)))

(fn unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(fn log-repl-output [msgs]
  (let [msgs (-> msgs unbatch format-msg)
        console-output-msgs (get-console-output-msgs msgs)
        cmd-result (get-expression-result msgs)]
    (when (not (a.empty? console-output-msgs))
      (log.append console-output-msgs))
    (when cmd-result
      (log.append [cmd-result]))))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (log-repl-output msgs)
          (when opts.on-result
            (let [msgs (-> msgs unbatch format-msg)
                  cmd-result (get-expression-result msgs)]
              (opts.on-result cmd-result))))
        {:batch? true}))))

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn get-help [code]
  (str.join "" ["help(" (str.trim code) ")"]))

(fn doc-str [opts]
  (when (str-is-python-expr? opts.code)
    (eval-str (a.assoc opts :code (get-help opts.code)))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. comment-prefix (a.pr-str (a.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(fn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(local initialise-repl-code
  ;; By default, there is no way for us to tell the difference between
  ;; normal stdout log messages and the result of the expression we evaluated.
  ;; This is because if an expression results in the literal value None, the python
  ;; interpreter will not print out anything.
  ;; Replacing this hook ensures that the last line in the output after
  ;; sending a command is the result of the command.
  ;; Relevant docs: https://docs.python.org/3/library/sys.html#sys.displayhook

  ;; We also set the `__name__` to something else so `__main__` blocks aren't executed.
  (str.join
    "\n"
    ["import sys"
     "def conjure_format_output(val):"
     "    print(repr(val))"
     "sys.displayhook = conjure_format_output\n"
     "__name__ = '__repl__'"]))

(fn start []
  (log.append [(.. comment-prefix "Starting Python client...")])
  (if (state :repl)
    (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                 (.. comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (if (not (pcall #(if vim.treesitter.language.require_language
                       (vim.treesitter.language.require_language "python")
                       (vim.treesitter.require_language "python"))))
      (log.append [(.. comment-prefix "(error) The python client requires a python treesitter parser in order to function.")
                   (.. comment-prefix "(error) See https://github.com/nvim-treesitter/nvim-treesitter")
                   (.. comment-prefix "(error) for installation instructions.")])
      (a.assoc
        (state) :repl
        (stdio.start
          {:prompt-pattern (cfg [:prompt-pattern])
           :cmd (cfg [:command])
           :delay-stderr-ms (cfg [:delay-stderr-ms])

           :on-success
           (fn []
             (display-repl-status :started
              (with-repl-or-warn
               (fn [repl]
                 (repl.send
                   (prep-code initialise-repl-code)
                   (fn [msgs] nil)
                   nil)))))

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
             (log.dbg (-> [msg] unbatch format-msg) {:join-first? true}))})))))

(fn on-load []
  (if (config.get-in [:client_on_load])
    (do ; FIXME: Can we remove the do?
      (start))
    (log.append ["Not starting repl"])))

(fn on-exit []
  (stop))

(fn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

(fn on-filetype []
  (mapping.buf
    :PythonStart (cfg [:mapping :start])
    start
    {:desc "Start the Python REPL"})

  (mapping.buf
    :PythonStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the Python REPL"})

  (mapping.buf
    :PythonInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the current evaluation"}))

{: buf-suffix
 : comment-prefix
 : form-node?
 : is-assignment?
 : is-expression?
 : str-is-python-expr?
 : format-msg
 : unbatch
 : eval-str
 : eval-file
 : get-help
 : doc-str
 : stop
 : initialise-repl-code
 : start
 : on-load
 : on-exit
 : interrupt
 : on-filetype }
