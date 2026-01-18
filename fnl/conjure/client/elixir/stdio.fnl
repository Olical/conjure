(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local stdio (autoload :conjure.remote.stdio))
(local str (autoload :conjure.nfnl.string))
(local util (autoload :conjure.util))
(local vim _G.vim)

;;============================================================
;;
;; Based on https://github.com/brandonpollack23/conjure/tree/add-elixir-client
;; for https://github.com/Olical/conjure/issues/635.
;;
;; This uses a lot from Brandon's implementation but is based on the Scheme client,
;; conjure.client.scheme.stdio.
;;
;; Also, it is in a separate repo from Conjure as an example
;; of creating clients that are not part of the Conjure codebase. This should allow people
;; to contribute to the Conjure ecosystem without having to add to the main codebase.
;;
;;============================================================

;;------------------------------------------------------------
;; Example interaction with iex REPL:
;;
;;
;;  $ iex
;;  Erlang/OTP 28 [erts-16.0] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit] [dtrace]
;;
;;  Interactive Elixir (1.18.4) - press Ctrl+C to exit (type h() ENTER for help)
;;  iex(1)> (1)
;;  1
;;  iex(2)> add(1, 2)
;;  error: undefined function add/2 (there is no such import)
;;  └─ iex:2
;;
;;  ** (CompileError) cannot compile code (errors have been logged)
;;
;;  iex(2)> 1+ 2
;;  3
;;  iex(3)>
;;------------------------------------------------------------


(local M (define :conjure.client.elixir.stdio))

(local iex-command (if (= :windows (util.os))
                       "iex.bat --no-color"
                       "iex --no-color"))

(config.merge
  {:client
   {:elixir
    {:stdio
     {:command iex-command ; M.start will overwrite this.
      :standalone_command iex-command
      :prompt_pattern "iex%(%d+%)> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:elixir
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :elixir :stdio]))
(local state (client.new-state #(do {:repl nil})))
(set M.buf-suffix ".ex")
(set M.comment-prefix "# ")

;; This should allow using <localleader>ee on most expressions or statements.
(fn M.form-node? [node]
  (log.dbg "--------------------")
  (log.dbg (.. "client.elixir.stdio.form-node?: node:type = " (core.str (node:type))))
  (log.dbg (.. "client.elixir.stdio.form-node?: node:parent = " (core.str (node:parent))))
  (let [parent (node:parent)]
    (if (= "call" (node:type)) true
        (= "binary_operator" (node:type)) true
        (and (= "list" (node:type))
             (not (= "binary_operator" (parent:type)))) true
        (= "integer" (node:type)) true
        (= "char" (node:type)) true
        (= "sigil" (node:type)) true
        (= "float" (node:type)) true
        (= "string" (node:type)) true
        (= "tuple" (node:type)) true
        (= "identifier" (node:type)) true
        (= "unary_operator" (node:type)) true
        (= "map" (node:type)) true
        (= "nil" (node:type)) true
        (= "integer" (node:type)) true
        (= "charlist" (node:type)) true
        (= "boolean" (node:type)) true
        (= "atom" (node:type)) true
        false)))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

(fn prep-code [s]
  (.. s "\n"))

(fn display-result [msg]
  (->> msg
       (core.map #(.. M.comment-prefix $1))
       log.append))

;; A function to clean the lines of an output message. It removes:
;;   - any blank lines
;;   - "iex:15"
;;   - "..(12)>"
(fn remove_prompts [msgs]
  (->>
    (str.split msgs "\n")
    (core.filter #(not (= "" $1)))
    (core.filter #(core.nil? (string.find $1 "iex:%d+")))
    (core.map #(string.gsub $1 "%.+%(%d+%)> +" ""))))

;; IO.puts("Hello world.\n") causes :ok to also be printed.
;; # debug: remote.stdio.on-message; receive chunk >>"Hello world.↵↵:ok↵iex(18)> "<<
;; # debug: client.elixir.stdio.unbatch: msgs='[{:done?↵  true↵  :out↵  "Hello world.↵↵:ok↵"}]'
;;
;; # debug: M.unbatch: msgs=[{:done? true↵  :out "** (BadBooleanError) expected a boolean on left-side of \"and\", got: 1↵    iex:15: (file)↵"}]
;; FIXME: Remove ":ok\n\niex(18)> " from the response.
(fn M.unbatch [msgs]
  (log.dbg (.. "client.elixir.stdio.unbatch: msgs='" (core.str msgs) "'"))
  ;; Pass array to a series of functions that operate on the array.
  ;; Map a function to split each element of the array
  {:out (->> msgs
             (core.map #(or (core.get $1 :out) (core.get $1 :err)))
             (core.map #(remove_prompts $1))
             (core.map #(str.join "\n" $1))
             (str.join))})

;; # debug: format-msg: msg={:out "3↵"}
(fn M.format-msg [msg]
  (log.dbg (.. "client.elixir.stdio.format-msg: msg='" (core.str msg) "'"))
  (->> (-> msg
           (core.get :out)
           (str.split "\n"))
       (core.filter #(not (str.blank? $1)))
       (core.map (fn [line] line))))

(fn M.eval-str [opts]
  (log.dbg (.. "client.elixir.stdio.eval-str: opts='" (core.str opts) "'"))
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code )
        (fn [msgs]
          (let [msgs (-> msgs M.unbatch M.format-msg)]
            (log.dbg (.. "client.elixir.stdio.eval-str: in cb: msgs='" (core.str msgs) "'"))
            (opts.on-result (str.join "\n" msgs))
            (log.append msgs)))
        {:batch? true}))))

(fn M.eval-file [opts]
  (M.eval-str (core.assoc opts :code (core.slurp opts.file-path))))

(fn display-repl-status [status]
  (log.append
    [(.. M.comment-prefix
         (cfg [:command])
         " (" (or status "no status") ")")]
    {:break? true}))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (core.assoc (state) :repl nil))))

;; from https://github.com/brandonpollack23/conjure/blob/add-elixir-client/fnl/conjure/client/elixir/stdio.fnl#L123-L130
(fn M.is-mix-project? []
  ;; TODO: Isn't there an idomatic Neovim way to check for a mix.exs file?
  (let [cwd (vim.fn.getcwd)
        mix_file (io.open (.. cwd "/mix.exs"))]
    (if mix_file
      (do
        (mix_file:close)
        true)
      false)))

(fn M.start []
  (if (state :repl)
    (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                 (.. M.comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})

    ;; Adapted from https://github.com/brandonpollack23/conjure/blob/add-elixir-client/fnl/conjure/client/elixir/stdio.fnl#L148-L154
    (let [mix-project (M.is-mix-project?)
          run_cmd (if mix-project
                       (.. (cfg [:standalone_command]) " -S mix")
                       (cfg [:standalone_command]))
          iex-mode (if mix-project
                       "mix mode"
                       "standalone mode")]

      ;; Remember the command to run so we do the right thing when telling Neovim to
      ;; switch current directories.
      (config.merge
        {:client
          {:elixir
            {:stdio
              {:command run_cmd}}}}
        {:overwrite? true})

      (log.dbg (.. "client.elixir.stdio.start: prompt_pattern='" (cfg [:prompt_pattern])
                   "', command='" (cfg [:command]) "'"))
      (log.append [(.. M.comment-prefix "Using iex in " iex-mode)])
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
                   (prep-code ":help")
                   (fn [msgs]
                     (display-result (-> msgs M.unbatch M.format-msg)))
                   {:batch? true}))))

           :on-error
           (fn [err]
             (display-repl-status err))

           :on-exit
           (fn [code signal]
             (log.append [(.. M.comment-prefix "process exited with code: " (core.str code))])
             (log.append [(.. M.comment-prefix "process exited with signal: " (core.str signal))])
             (M.stop))

           :on-stray-output
           (fn [msg]
             (log.append (M.format-msg msg)))})))))

(fn M.on-exit []
  (M.stop))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix "Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-load []
  (M.start))

(fn M.on-filetype []
  (mapping.buf
    :ElixirStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :ElixirStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :ElixirInterrupt (cfg [:mapping :interrupt])
    #(M.interrupt)
    {:desc "Interrupt the REPL"}))

M
