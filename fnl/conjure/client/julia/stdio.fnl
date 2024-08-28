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
(local buf-suffix ".jl")
(local comment-prefix "# ")

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")
                   (.. comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))

(fn prep-code [s]
  (.. s "\nif(isnothing(ans)) display(nothing) end\n"))

(fn unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(fn format-msg [msg]
  ; remove last "nothing" if preceded by character or newline.
  (->> (-> (string.gsub msg "(.?[%w\n])(nothing)" "%1")
           (str.split "\n"))
       (a.filter #(~= "" $1))))

(fn get-form-modifier [node]
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
                  :range (a.update-in (ts.range node) [:end 2] a.inc)}}))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code (string.gsub opts.code ";$" "; nothing;"))
        (fn [msgs]
          (let [msgs (-> msgs unbatch format-msg)]
             (log.append msgs)
             (when opts.on-result
               (opts.on-result (str.join " " msgs)))))
        {:batch? true}))))

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn doc-str [opts]
  (eval-str (a.update opts :code #(.. "Main.eval(REPL.helpmode(\"" $1 "\"))"))))

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

(fn start []
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
           (display-repl-status :started)
           (with-repl-or-warn
             (fn [repl]
               (repl.send
                 (prep-code "using REPL")
                 (fn [msgs]
                   (log.append (-> msgs unbatch format-msg)))
                 {:batch? true}))))

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
           (log.append (-> [msg] unbatch format-msg) {:join-first? true}))}))))

(fn on-load []
  (start))

(fn on-exit []
  (stop))

(fn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

(fn on-filetype []
  (mapping.buf
    :JuliaStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :JuliaStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :JuliaInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the evaluation"}))

{: buf-suffix
 : comment-prefix
 : unbatch
 : format-msg
 : get-form-modifier
 : eval-str
 : eval-file
 : doc-str
 : stop
 : start
 : on-load
 : on-exit
 : interrupt
 : on-filetype}
