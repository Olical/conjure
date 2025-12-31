(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local stdio (autoload :conjure.remote.stdio))
(local str (autoload :conjure.nfnl.string))

;;------------------------------------------------------------
;; Example interaction with irb REPL:
;;
;;
;; $ irb --no-pager --nocolorize --noautocomplete --noecho-on-assignment --simple-prompt
;; ?> class Greeter
;; ?>   def initialize(name = "World")
;; ?>     @name = name
;; ?>   end
;; ?>   def say_hi
;; ?>     puts "Hi #{@name}!"
;; ?>   end
;; ?>   def say_bye
;; ?>     puts "Bye #{@name}. Come back soon!"
;; ?>   end
;; >> end
;; => :say_bye  <<-- return value
;;
;; >> greeter = Greeter.new("Patricia")
;;
;; >> greeter.say_hi
;; Hi Patricia!
;; => nil       <<-- return value
;;
;; >> greeter.say_bye
;; Bye Patricia. Come back soon!
;; => nil       <<-- return value
;;
;; >> greeter.@name
;; <internal:kernel>:168:in 'Kernel#loop': (irb):15: syntax error found (SyntaxError)
;; > 15 | greeter.@name
;;      |         ^~~~~ unexpected instance variable; expecting a message to send to the receiver
;;
;; 	from .../.local/share/mise/installs/ruby/3.4.5/lib/ruby/gems/3.4.0/gems/irb-1.15.2/exe/irb:9:in '<top (required)>'
;; 	from .../.local/share/mise/installs/ruby/3.4.5/lib/ruby/site_ruby/3.4.0/rubygems.rb:319:in 'Kernel#load'
;; 	from .../.local/share/mise/installs/ruby/3.4.5/lib/ruby/site_ruby/3.4.0/rubygems.rb:319:in 'Gem.activate_and_load_bin_path'
;; 	from .../.local/share/mise/installs/ruby/3.4.5/bin/irb:25:in '<main>'
;; >>
;;------------------------------------------------------------


(local M (define :conjure.client.ruby.stdio))

(set M.buf-suffix ".rb")
(set M.comment-prefix "# ")

;; NOTE:
;;   1. This client depends on a simplified interaction with the REPL with the default
;;      value of :command.
;;      See https://ruby.github.io/irb/ for command line options and configuration.
;;      While you can try other command line options, it may break this client.
;;
;;   2. The :value_prefix_pattern helps tell what is a return value.
;;      But the pattern selects from beginning of line to and including the value prefix
;;      so that we can delete it from a line.
(config.merge
  {:client
   {:ruby
    {:stdio
     {:command "irb --no-pager --nocolorize --noautocomplete --noecho-on-assignment --simple-prompt"
      :prompt_pattern ">> "
      :value_prefix_pattern "=> "
      }}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:ruby
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :ruby :stdio]))
(local state (client.new-state #(do {:repl nil})))

;; This should allow using <localleader>ee on most expressions or statements.
(fn M.form-node? [node]
  (log.dbg "--------------------")
  (log.dbg (.. "ruby.stdio.form-node?: node:type = " (core.str (node:type))))
  (log.dbg (.. "ruby.stdio.form-node?: node:parent = " (core.str (node:parent))))
  (let [parent (node:parent)]
    ; Order of conditions is important. If need to tweak, add an example to sandbox.rb.
    (if
        ; Grab nested binary from where the cursor is in the expression to the left-most
        ; number. See dev/ruby/sandbox.rb.
        (and (= "binary" (node:type))
          (not (= "binary" (parent:type)))) true
        (= "binary" (node:type)) true
        (and (= "left" (node:type))
             (= "assignment" (parent:type))) true
        (and (= "call" (node:type))
          (not (= "assignment" (parent:type)))) true
        (= "arguments" (node:type)) true
        (= "class" (node:type)) true
        (= "method" (node:type)) true
        (= "array" (node:type)) true
        (= "hash" (node:type)) true
        (= "symbol" (node:type)) true
        (= "integer" (node:type)) true
        (= "float" (node:type)) true
        (= "string" (node:type)) true
        (= "assignment" (node:type)) true
        (= "identifier" (node:type)) true
        false)))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

(fn prep-code [s]
  (.. s "\n"))

; Take a list of lines and prepend the comment prefix to each and then log.
(fn display-result [msg]
  (->> msg
       (core.map #(.. M.comment-prefix $1))
       log.append))

;; Taken from Scheme client.
;;   input:
;;     [{:done? false   :out "5+ 3\n"}  {:done? true  :out "=> 8\n"}]
;;   output:
;;     ["5+ 3" "=> 8"]
;; Merge stdout and stderr.
;; Returns a list.
(fn M.unbatch [msgs]
  (log.dbg (.. "ruby.stdio.unbatch: msgs='" (core.str msgs) "'"))
  (->> msgs
       (core.map #(or (core.get $1 :out) (core.get $1 :err)))
       (core.map #(string.gsub $1 "\n$" "")) ; trim trailing newlines
       ))

;; Is there an irb error in the line?
(fn has_error? [line]
  (log.dbg (.. "ruby.stdio.has_error? line='" (core.str line) "'"))
  (if (core.nil? line) false
      (not (core.empty? (string.match line "Error")))))

;; Return the main error message without the specific errors and stack trace.
;;  Take the first line of the lines split from the original line.
;;  => "(irb):4:in '<main>': undefined method 'plus' for an instance of Integer (NoMethodError)"
;; Assumes caller found "Error" in the line by calling has_error?.
(fn extract_error_msg [line]
  (log.dbg (.. "ruby.stdio.extract_error_msg: line='" (core.str line) "'"))
  (core.first (str.split line "\n")))

(fn format-line [line]
  (let [value_prefix_pat (cfg [:value_prefix_pattern])
        gsub_value_prefix_pat (.. "^.*" "=> ")]
    (log.dbg (.. "ruby.stdio.format-line: line='" (core.str line) "'"))
    (log.dbg (.. "format-line: value_prefix_pat='" (core.str value_prefix_pat) "'"))
    (log.dbg (.. "format-line: gsub_value_prefix_pat='" (core.str gsub_value_prefix_pat) "'"))
    (if
      ;; If a line has a :value_prefix_pattern, then strip from beginning of line
      ;; to and including the pattern.
      (string.match line value_prefix_pat)
      (do
        (log.dbg (.. "format-line: line has '" value_prefix_pat "'"))
        (string.gsub line gsub_value_prefix_pat "")
        )

      (has_error? line)
      (.. "(error) " (extract_error_msg line))

      ; Otherwise prepend the comment-prefix with "(out") to indicate that the
      ; line is an output line.
      (.. M.comment-prefix "(out) " line))))

;; Taken from Scheme client.
;; (let [msgs ["5+ 3↵" "=> 8↵"]]
;;   (M.format-msg msgs)) ; ["# (out) 5+ 3↵" "8↵"]
;; FIXME: Assignments should return nil like puts does.
;;   when last msgs has "(out)" then append nil to msgs.
(fn M.format-msg [msgs]
  (log.dbg (.. "ruby.stdio.format-msg: msgs='" (core.str msgs) "'"))
  (->> msgs
       (core.filter #(string.gsub $1 "\n$" "")) ; trim trailing newlines
       (core.filter #(not (str.blank? $1))) ; omit blank lines
       (core.map format-line)))

(fn M.eval-str [opts]
  (log.dbg (.. "ruby.stdio.eval-str: opts='" (core.str opts) "'"))
  (with-repl-or-warn
    (fn [repl]
      (log.dbg (.. "ruby.stdio.eval-str: sending '" (core.str opts.code) "'"))
      (repl.send ; [code cb opts]
        (prep-code opts.code )
        (fn [msgs]
          (let [msgs (-> msgs M.unbatch M.format-msg)]
            (log.dbg (.. "cb from repl.send (ruby.stdio.eval-str): msgs='"
                         (core.str msgs) "'"))
            (opts.on-result (core.last msgs)) ; assume last line is return value
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

(fn M.start []
  (log.dbg (.. "ruby.stdio.start: prompt_pattern='" (cfg [:prompt_pattern])
               "', cmd='" (cfg [:command]) "'"))
  (if (state :repl)
    (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                 (.. M.comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (core.assoc
      (state) :repl
      (stdio.start ; start a REPL
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
           (when (and (= :number (type code)) (> code 0))
             (log.append [(.. M.comment-prefix "process exited with code " (core.str code))]))
           (when (and (= :number (type signal)) (> signal 0))
             (log.append [(.. M.comment-prefix "process exited with signal " (core.str signal))]))
           (M.stop))

         :on-stray-output
         (fn [msg]
           (log.append (M.format-msg msg)))}))))

(fn M.on-exit []
  (M.stop))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-load []
  (M.start))

(fn M.on-filetype []
  (mapping.buf
    :RubyStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :RubyStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :RubyInterrupt (cfg [:mapping :interrupt])
    #(M.interrupt)
    {:desc "Interrupt the REPL"}))

M
