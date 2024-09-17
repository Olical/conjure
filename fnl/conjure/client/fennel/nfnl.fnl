(local {: autoload} (require :nfnl.module))
(local ts (autoload :conjure.tree-sitter))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local log (autoload :conjure.log))
(local core (autoload :nfnl.core))
(local fennel (autoload :nfnl.fennel))
(local str (autoload :nfnl.string))
(local repl (autoload :nfnl.repl))
(local fs (autoload :nfnl.fs))

(local comment-node? ts.lisp-comment-node?)

(fn form-node? [node]
  (ts.node-surrounded-by-form-pair-chars? node [["#(" ")"]]))

(local buf-suffix ".fnl")
(local comment-prefix "; ")

(config.merge
  {:client
   {:fennel
    {:nfnl
     {}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
   {:client
    {:fennel
     {:nfnl
      {:mapping {}}}}}))

(local cfg (config.get-in-fn [:client :fennel :nfnl]))

(local repls {})

;; TODO Catch errors and display them in the log with ASCII codes removed.

(fn repl-for-path [path]
  "Upserts a repl for the given path. Stored in the `repls` table.
  TODO: Add mappings or commands that allow us to reset the REPL state if they get stuck."
  (if (?. repls path)
    (. repls path)
    (let [r (repl.new)]
      (tset repls path r)
      r)))

(fn module-path [path]
  "Turns a full file path into a dot.delimited.module.path. We can then use this module path to perform live reloads by modifying the currently loaded module.

  Finds the closest root `fnl` directory and uses that as the root of the module path.

  TODO: Make this configurable so that non-standard Fennel setups also work. Maybe just read the .nfnl.fnl configuration since that is what we are supposed to be working with."
  (let [parts (-> path (fs.file-name-root) (fs.split-path))
        fnl-and-below (core.drop-while #(not= $1 "fnl") parts)]
    (when (= "fnl" (core.first fnl-and-below))
      (str.join "." (core.rest fnl-and-below)))))

(comment
  (module-path "~/repos/Olical/conjure/fnl/conjure/client/fennel/nfnl.fnl"))

(fn eval-str [opts]
  "Client function, called by Conjure when evaluating a string."
  (let [repl (repl-for-path opts.file-path)
        results (repl (.. opts.code "\n"))
        result-strs (core.map fennel.view results)
        lines (text.split-lines (str.join "\n" result-strs))]
    (log.append lines)))

(fn eval-file [opts]
  "Client function, called by Conjure when evaluating a file from disk."
  (set opts.code (core.slurp opts.file-path))
  (when opts.code
    (eval-str opts)))

(fn doc-str [opts]
  "Client function, called by Conjure when looking up documentation."
  (core.assoc opts :code (.. ",doc " opts.code))
  (eval-str opts))

{: comment-node?
 : form-node?
 : buf-suffix
 : comment-prefix
 : eval-str
 : eval-file
 : doc-str}
