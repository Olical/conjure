;;------------------------------------------------------------
;; A client for snd/s7 (sound editor with s7 scheme scripting)
;;
;; Based on: fnl/conjure/client/scheme/stdio.fnl
;;           fnl/conjure/client/sql/stdio.fnl
;;
;; The `snd` program should be runnable on the command line.
;;
;; NOTE: Conflicts with the Scheme client due to the same filetype suffix.
;;       For testing the proof-of-concept, this client replaces the Scheme
;;       client in fnl/conjure/config.fnl.
;;
;;------------------------------------------------------------

(module conjure.client.snd-s7.stdio
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio-rt
             config conjure.config
             mapping conjure.mapping
             client conjure.client
             log conjure.log
             ts conjure.tree-sitter}
   require-macros [conjure.macros]})

(config.merge
  {:client
   {:snd-s7
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"
                :interrupt "ei"}
      :command "snd"
      :prompt_pattern "> "}}}})

(def- cfg (config.get-in-fn [:client :snd-s7 :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".scm")
(def comment-prefix "; ")
(def form-node? ts.node-surrounded-by-form-pair-chars?)

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

;;;;-------- from client/sql/stdio.fnl ----------------------
(defn- format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(defn- remove-blank-lines [msg]
  (->> (format-message msg)
       (a.filter #(not (= "" $1)))))

(defn- display-result [msg]
  (log.append (remove-blank-lines msg)))

(defn ->list [s]
  (if (a.first s)
    s
    [s]))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code "\n")
        (fn [msgs]
          (let [msgs (->list msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (remove-blank-lines (a.last msgs)))))
            (a.run! display-result msgs))
          )
        {:batch? false}))))

;;;;-------- End from client/sql/stdio.fnl ------------------

;;;;-------- from client/scheme/stdio.fnl -------------------
; (defn unbatch [msgs]
;   {:out (->> msgs
;           (a.map #(or (a.get $1 :out) (a.get $1 :err)))
;           (str.join ""))})
; 
; (defn format-msg [msg]
;   (->> (-> msg
;            (a.get :out)
;            (string.gsub "^%s*" "")
;            (string.gsub "%s+%d+%s*$" "")
;            (str.split "\n"))
;        (a.map
;          (fn [line]
;            (if
;              (not (cfg [:value_prefix_pattern]))
;              line
; 
;              (string.match line (cfg [:value_prefix_pattern]))
;              (string.gsub line (cfg [:value_prefix_pattern]) "")
; 
;              (.. comment-prefix "(out) " line))))
;        (a.filter #(not (str.blank? $1)))))
; 
; 
; (defn eval-str [opts]
;   (with-repl-or-warn
;     (fn [repl]
;       (repl.send
;         (.. opts.code "\n")
;         (fn [msgs]
;           (let [msgs (-> msgs unbatch format-msg)]
;             (opts.on-result (a.last msgs))
;             (log.append msgs)))
;         {:batch? true}))))
; 
;;;;-------- End from client/scheme/stdio.fnl ---------------

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(defn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

(defn- display-repl-status [status]
  (log.append
    [(.. comment-prefix
         (cfg [:command])
         " (" (or status "no status") ")")]
    {:break? true}))

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
    (a.assoc
      (state) :repl
      (stdio.start
        {:prompt-pattern (cfg [:prompt_pattern])
         :cmd (cfg [:command])

         :on-success
         (fn []
           (display-repl-status :started))

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
           (log.append (format-msg msg)))}))))

(defn on-load []
  (start))

(defn on-exit []
  (stop))

(defn on-filetype []
  (mapping.buf
    :SndStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :SndStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :SdnInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the REPL"}))
