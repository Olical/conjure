(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local text (autoload :conjure.text))

(local M (define :conjure.client.javascript.stdio))

(fn filetype [] vim.bo.filetype)

(local repl-type (if (= "javascript" (filetype))
                     :js 
                     
                     (= "typescript" (filetype))
                     :ts))

(fn get-repl-cmd []
  (if (= :js repl-type)
      "node -i"

      (= :ts repl-type)
      "ts-node -i"))

(config.merge {:client 
               {:javascript 
                {:stdio 
                 {:command (get-repl-cmd)
                  :args "NODE_OPTIONS=\'--experimental-repl-await\'"
                  :prompt-pattern "> "
                  :show_stray_out false}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge 
    {:client 
     {:javascript 
      {:stdio 
       {:mapping {:start :cs
                  :stop :cS
                  :restart :cr
                  :interrupt :ei
                  :stray :ts}}}}}))

(local cfg (config.get-in-fn [:client :javascript :stdio]))
(set M.buf-suffix ".js")
(local state (client.new-state (fn [] {:repl nil})))
(set M.comment-prefix "// ")

(fn M.form-node? [node]
  (or (= :function_declaration (node:type)) (= :export_statement (node:type))
      (= :try_statement (node:type)) (= :expression_statement (node:type))
      (= :import_statement (node:type)) (= :class_declaration (node:type))
      (= :type_alias_declaration (node:type)) (= :enum_declaration  (node:type))
      (= :lexical_declaration (node:type)) (= :for_statement (node:type))
      (= :for_in_statement  (node:type))))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
        (f repl)
        (log.append [(.. M.comment-prefix "No REPL running")
                     (.. M.comment-prefix "Start REPL with "
                         (config.get-in [:mapping :prefix])
                         (cfg [:mapping :start]))]))))

(fn display-result [msg]
  (log.append msg))

(fn get-absolute-path [f]
  (.. "\"" 
      (vim.fn.fnamemodify (.. (vim.fn.expand "%:p:h") "/" f) ":p") 
      "\""))

(fn replace-imports-path [s]
  (if (or (string.find s :import)
          (string.find s :require))
      (string.gsub s "[\"\'](.-)[\"\']" 
                   (fn [m]
                     (if (text.starts-with m ".")
                         (get-absolute-path m)

                         (.. "\"" m "\""))))
      s))

;; replacement fn for "import {mod1 as m1, mod2 as m2 ...} from ...", "import {mod1, mod2} from ..."
(fn replace-curly-import [s]
  (let [pattern "import%s+%{(.-)%}%s+from%s+[\"'](.-)[\"']" 
        replace-fn (fn [bd path]
                     (let [spl (str.split bd ",")
                           spl->nms (->> 
                                      spl 
                                      (a.map (fn [el] (el:gsub "as" ":")))
                                      (str.join ", "))]

                       (.. "const {" spl->nms "} = require(\"" path "\")")))
        (repl _) (string.gsub s pattern replace-fn)]
    repl))

(local patterns-replacements
       [;; import * as `something` from "module"
        ["^%s*import%s+%*%s+as%s+([^%s]+)%s+from%s+([\"'])(.-)%2%s*"
         "const %1 = require(\"%3\")"]
        ;; import mod from "module"
        ["^%s*import%s+([^%s{]+)%s+from%s+([\"'])(.-)%2%s*"
         "const %1 = require(\"%3\")"]
        ;; import defaultExport, { export1 } from "module-name"; 
        ["^%s*import%s+([^%s{,]+)%s*,%s*%{([^}]+)%}%s+from%s+([\"'])(.-)%3%s*"
         "const { default: %1, %2 } = require(\"%4\")"]
        ["^%s*import%s+([\"'])(.-)%1%s*" "require(\"%2\");"]])

(fn replace-imports-regex [s]
  (let [initial-acc {:applied? false :result s}
        final-acc (a.reduce 
                    (fn [acc [pat repl]]
                      (if acc.applied?
                          acc
                          (let [(r c) (string.gsub acc.result pat repl)]
                            (if (> c 0)
                                {:applied? true :result r}
                                acc))))
                    initial-acc patterns-replacements)]
    final-acc.result))

;; To avoid Node.js REPL complaints, imports are automatically converted for the user.
;; See https://github.com/nodejs/node/issues/48084
(fn replace-imports [s]
  (if (and (text.starts-with s :import)
           (not (text.starts-with s "import type")))
      (-> s
          replace-curly-import
          replace-imports-regex)
      s))

(fn is-arrow-fn? [code]
  (when (or (text.starts-with code "let")
            (text.starts-with code "const"))
    (let [pat (if (string.find code "async")
                  ".*=%s*async%s+%(.*%)%s*:+.*=>"
                  ".*=%s*%(.*%)%s*:?.*=>")]
      (if (string.match code pat)
          true 
          false))))

;; Before sending code to the REPL, all comments must be removed
(fn remove-comments [s]
  (let [(sub _) (-> s  
                    (string.gsub "%/%/.-\n" "")
                    (string.gsub "%/%*.-%*%/" "")
                    (string.gsub "^%/%/.*" "")
                    (string.gsub "^%/.*" "")
                    (string.gsub "^%s*%*.*" "")
                    (string.gsub "^%s*%/%*+.*" ""))]
    sub))

;; Arrow functions are automatically transformed into standard functions, 
;; allowing them to be redefined in the Node.js REPL.
(fn replace-arrows [s]
  (if (not (is-arrow-fn? s)) s
      (let [decl (if (text.starts-with s :const) "const" 
                     (text.starts-with s :let) "let")
            pattern (.. decl "%s*([%w_]+)%s*=%s*(.-)%((.-)%)%s*(.-)%s*=>%s*(.*)")
            replace-fn (fn [name before-args args after-args body]
                         (let [async-kw (if (before-args:find :async) "async " "")
                               final-body (if (body:find "^%s*%{")
                                              (.. " " body)
                                              (.. " { return " body " }"))]
                           (.. async-kw "function " name "(" args ")" after-args final-body)))
            (replace _) (s:gsub pattern replace-fn)]
        replace)))

;; For better user experience, in some scenarios semicolons must be automatically appended 
(fn add-semicolon [s]
  (let [spl (str.split s "\n")
        sub-fn (fn [ln]
                 (if (or (text.starts-with ln :.)
                         (string.match ln "%s*@")
                         (text.ends-with ln "{")
                         (text.ends-with ln ";")
                         (str.blank? ln))
                     ln
                     (.. ln ";")))
        sub (a.map sub-fn spl)]
    (str.join " " sub)))

(fn manage-semicolons [s]
  (if (or 
        (text.starts-with s "function")
        (text.starts-with s "namespace")
        (text.starts-with s "class")
        (text.starts-with s "@"))
      (add-semicolon s)
      s))

(fn prep-code-expr [e]
  (-> e
      remove-comments
      (string.gsub "%s+%." "%.")
      replace-imports-path
      replace-imports
      replace-arrows
      manage-semicolons))

(fn prep-code-file [f]
  (->> (str.split f "\n")
       (a.map prep-code-expr)
       (str.join "\n")))

(fn prep-code [s]
  (.. (prep-code-expr s) "\n"))

(fn replace-dots [s with]
  (let [(s _count) (string.gsub s "%.%.%.%s?" with)] s))

(fn M.format-msg [msg]
  (->> (str.split msg "\n")
       (a.filter #(not= "" $1))
       (a.map #(replace-dots $1 ""))))

(fn sanitize-msg [msg field]
  (->> (str.split (a.get msg field) "\n")
       (a.map #(replace-dots $1 ""))
       (a.filter (partial (not str.blank?)))
       (a.map #(.. "(" field ") " $1 "\n"))
       (str.join "")))

(fn prepare-out [msg]
  (if (a.get msg :out) 
      (sanitize-msg msg :out)

      (a.get msg :err)
      (sanitize-msg msg :err)))

(fn M.unbatch [msgs]
  (->> msgs
       (a.map prepare-out)
       (str.join "")))

(fn delete-file [f]
  (let [cmd (if (= 0 (vim.fn.has "macunix"))
                "del"
                "rm")]
    (when (= 1 (vim.fn.filereadable f))
      (os.execute (.. cmd " " f)))))

(fn stray-out []
  (config.merge {:client 
                 {:javascript 
                  {:stdio 
                   {:show_stray_out (not (cfg [:show_stray_out]))}}}}
                {:overwrite? true}))

(fn restart []
  (M.stop)
  (M.start))

(fn M.eval-str [opts]
  (with-repl-or-warn 
    (fn [repl]
      (repl.send (prep-code opts.code)
                 (fn [msgs]
                   (let [msgs (-> msgs M.unbatch M.format-msg)]
                     (display-result msgs)
                     (when opts.on-result
                       (opts.on-result (str.join " " msgs)))))
                 {:batch? true}))))

(fn M.eval-file [opts]
  (with-repl-or-warn 
    (fn [repl]
      (let [c (prep-code-file (a.slurp opts.file-path))
            tmp_name (.. opts.file-path "_tmp")
            _tmp (a.spit tmp_name c)]
        (log.dbg ["EVAL TEMP FILE: " tmp_name])
        (repl.send (.. ".load " tmp_name "\n"))
        (fn [msgs]
          (let [msgs (-> msgs M.unbatch M.format-msg)]
            (display-result msgs)
            (when opts.on-result
              (opts.on-result (str.join " " msgs)))))
        (delete-file tmp_name)))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. M.comment-prefix (a.pr-str (a.get-in repl [:opts :cmd]))
             " (" status ")")] {:break? true}))))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(set M.initialise-repl-code "")

(fn M.start []
  (if (state :repl)
      (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                   (.. M.comment-prefix "Stop the REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :stop]))]
                  {:break? true})
      (a.assoc 
        (state) :repl
        (stdio.start
          {:prompt-pattern (cfg [:prompt-pattern])
           :cmd (cfg [:command])
           :delay-stderr-ms (cfg [:delay-stderr-ms])

           :on-success 
           (fn []
             (display-repl-status :started)
             (with-repl-or-warn
                 (fn [repl]
                   (repl.send 
                     (prep-code M.initialise-repl-code) 
                     (fn [msgs]
                       (display-result (-> msgs
                                           M.unbatch
                                           M.format-msg)))
                     {:batch true}))))

           :on-error (fn [err]
                       (display-repl-status err))

           :on-exit (fn [code signal]
                      (when (and (= :number (type code)) (> code 0))
                        (log.append
                          [(.. M.comment-prefix
                               "process exited with code "
                               code)]))
                      (when (and (= :number (type signal)) (> signal 0))
                        (log.append 
                          [(.. M.comment-prefix
                               "process exited with signal "
                               signal)]))
                      (M.stop))

           :on-stray-output
           (fn [msg]
             (when (cfg [:show_stray_out]) 
               (display-result 
                 (-> [msg] M.unbatch M.format-msg))))}))))

(fn warning-msg []
  (a.map #(log.append [$1])
         ["// WARNING! Node.js REPL limitations require transformations:"
          "// 1. ES6 'import' statements are converted to 'require(...)' calls."
          "// 2. Arrow functions ('const fn = () => ...') are converted to 'function fn() ...' declarations to allow re-definition."]))

(fn M.on-load []
  (if (config.get-in [:client_on_load])
      (do
        (M.start)
        (warning-msg))
      (log.append ["Not starting repl"])))

(fn M.on-exit [] (M.stop))

(fn M.interrupt []
  (with-repl-or-warn 
    (fn [repl]
      (log.append [(.. M.comment-prefix
                       " Sending interrupt signal.")]
                  {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-filetype []
  (mapping.buf :JavascriptStart 
               (cfg [:mapping :start]) 
               M.start
               {:desc "Start the Javascript REPL"})
  (mapping.buf :JavascriptStop 
               (cfg [:mapping :stop])
               M.stop
               {:desc "Stop the Javascript REPL"})
  (mapping.buf :JavascriptRestart 
               (cfg [:mapping :restart])
               restart  
               {:desc "Restart the Javascript REPL"})
  (mapping.buf :JavascriptInterrupt 
               (cfg [:mapping :interrupt]) 
               M.interrupt
               {:desc "Interrupt the current evaluation"})
  (mapping.buf :JavascriptStray 
               (cfg [:mapping :stray]) 
               stray-out
               {:desc "Toggle stray out"}))

M
