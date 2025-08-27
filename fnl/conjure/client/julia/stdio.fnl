(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.julia.stdio))

; TODO prompt_pattern for julia seems to not show, empty "" is problematic.
(config.merge
  {:client
   {:julia
    {:stdio
     {:command "julia --banner=no --color=no -i"
      :prompt_pattern ""}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:julia
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :julia :stdio]))
(local state (client.new-state #(do {:repl nil})))
(set M.buf-suffix ".jl")
(set M.comment-prefix "# ")

(fn M.form-node? [node]
  (let [parent (node:parent)]
    (and
      ;; Pkg.activate(...) should execute the expression Pkg.foo should just return foo.
      (not (and
             (= "call_expression" (parent:type))
             (= "field_expression" (node:type))))

      ;; (a, b) = (1, 2) should evaluate the assignment, not the tuple alone.
      ;; So don't allow evaluating a node that is directly below an assignment.
      (not (= "assignment" (parent:type)))

      ;; Don't eval arg lists as tuples, just evaluate the call_expression above.
      (not= "argument_list" (node:type)))))

(fn with-repl-or-warn [f _opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")
                   (.. M.comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))

(fn prep-code [s]
  (.. s "\nif(isnothing(ans)) display(nothing) end\n"))

(fn M.unbatch [msgs]
  (->> msgs
       (core.map #(or (core.get $1 :out) (core.get $1 :err)))
       (str.join "")))

(fn M.format-msg [msg]
  ; remove last "nothing" if preceded by character or newline.
  (->> (-> (string.gsub msg "(.?[%w\n])(nothing)" "%1")
           (str.split "\n"))
       (core.filter #(~= "" $1))))

(fn M.get-form-modifier [node]
  ;; When the next sibling is a semi-colon it means we need to override the
  ;; tree sitter response. We instead need to tell Conjure the exact text and
  ;; range we're interested in since this is a pretty non-standard operation
  ;; when it comes to Conjure clients.

  ;; There's a risk the `;` is actually seperated by some spaces or something,
  ;; that will cause this to behave a little weirdly but that should be a very
  ;; rare edge case.
  (when (= ";" (ts.node->str (node:next_sibling)))
    {:modifier :raw
     :node-table {;; Add a semi-colon to the end of the content.
                  :content (.. (ts.node->str node) ";")

                  ;; Increment the end of the range by one.
                  :range (core.update-in (ts.range node) [:end 2] core.inc)}}))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code (string.gsub opts.code ";$" "; nothing;"))
        (fn [msgs]
          (let [msgs (-> msgs M.unbatch M.format-msg)]
             (log.append msgs)
             (when opts.on-result
               (opts.on-result (str.join " " msgs)))))
        {:batch? true}))))

(fn M.eval-file [opts]
  (M.eval-str (core.assoc opts :code (core.slurp opts.file-path))))

(fn M.doc-str [opts]
  (M.eval-str (core.update opts :code #(.. "Main.eval(REPL.helpmode(\"" $1 "\"))"))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. M.comment-prefix (core.pr-str (core.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (core.assoc (state) :repl nil))))

(fn M.start []
  (if (state :repl)
    (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                 (.. M.comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (core.assoc
      (state) :repl
      (stdio.start
        {:prompt-pattern (cfg [:prompt_pattern])
         :cmd (cfg [:command])

         :on-success
         (fn []
           (display-repl-status :started)
           (with-repl-or-warn
             (fn [repl]
               (repl.send
                 (prep-code "using REPL")
                 (fn [msgs]
                   (log.append (-> msgs M.unbatch M.format-msg)))
                 {:batch? true}))))

         :on-error
         (fn [err]
           (display-repl-status err))

         :on-exit
         (fn [code signal]
           (when (and (= :number (type code)) (> code 0))
             (log.append [(.. M.comment-prefix "process exited with code " code)]))
           (when (and (= :number (type signal)) (> signal 0))
             (log.append [(.. M.comment-prefix "process exited with signal " signal)]))
           (M.stop))

         :on-stray-output
         (fn [msg]
           (log.append (-> [msg] M.unbatch M.format-msg) {:join-first? true}))}))))

(fn M.on-load []
  (M.start))

(fn M.on-exit []
  (M.stop))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-filetype []
  (mapping.buf
    :JuliaStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :JuliaStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :JuliaInterrupt (cfg [:mapping :interrupt])
    #(M.interrupt)
    {:desc "Interrupt the evaluation"}))

M
