(local {: autoload : define} (require :conjure.nfnl.module))
(local ts (autoload :conjure.tree-sitter))
(local config (autoload :conjure.config))
(local nfnl-config (autoload :conjure.nfnl.config))
(local text (autoload :conjure.text))
(local log (autoload :conjure.log))
(local core (autoload :conjure.nfnl.core))
(local fennel (autoload :conjure.nfnl.fennel))
(local str (autoload :conjure.nfnl.string))
(local repl (autoload :conjure.nfnl.repl))
(local fs (autoload :conjure.nfnl.fs))

(local M
  (define :conjure.client.fennel.nfnl
    {:comment-node? ts.lisp-comment-node?
     :buf-suffix ".fnl"
     :comment-prefix "; "}))

(fn M.form-node? [node]
  (ts.node-surrounded-by-form-pair-chars? node [["#(" ")"]]))

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

(set M.repls (or M.repls {}))

(fn M.repl-for-path [path]
  "Upserts a repl for the given path. Stored in the `repls` table.
  TODO: Add mappings or commands that allow us to reset the REPL state if they get stuck."
  (if (?. M.repls path)
    (. M.repls path)
    (let [r (repl.new
              {:on-error
               (fn [err-type err]
                 (-> (str.join ["[" err-type "] " err])
                     (text.strip-ansi-escape-sequences)
                     (str.trim)
                     (text.prefixed-lines "; ")
                     (log.append)))
               :cfg (let [config-map (nfnl-config.find-and-load (fs.file-name-root path))]
                      (when config-map
                        (nfnl-config.cfg-fn config-map)))})]
      (tset M.repls path r)
      r)))

(fn M.module-path [path]
  "Turns a full file path into a dot.delimited.module.path. We can then use this module path to perform live reloads by modifying the currently loaded module.

  Finds the closest root `fnl` directory and uses that as the root of the module path.

  TODO: Make this configurable so that non-standard Fennel setups also work. Maybe just read the .nfnl.fnl configuration since that is what we are supposed to be working with."
  (when path
    (let [parts (-> path (fs.file-name-root) (fs.split-path))
          fnl-and-below (core.drop-while #(not= $1 "fnl") parts)]
      (when (= "fnl" (core.first fnl-and-below))
        (str.join "." (core.rest fnl-and-below))))))

(comment
  (M.module-path "~/repos/Olical/conjure/fnl/conjure/client/fennel/nfnl.fnl"))

(fn M.eval-str [opts]
  "Client function, called by Conjure when evaluating a string."
  (let [repl (M.repl-for-path opts.file-path)
        results (repl (.. opts.code "\n"))
        result-strs (core.map fennel.view results)
        mod-path (M.module-path opts.file-path)]

    ;; When we evaluate a whole file and it ends in a table, we merge that table into the loaded module.
    ;; This allows you to reload a module with ef or eb.
    (when (and mod-path
               (or (= :buf opts.origin) (= :file opts.origin))
               (core.table? (core.last results)))
      (let [mod (core.get package.loaded mod-path)]
        (tset package.loaded mod-path (core.merge! mod (core.last results)))))

    (when (not (core.empty? result-strs))
      (let [result (str.join "\n" result-strs)]
        (when opts.on-result
          (opts.on-result result))

        (log.append (text.split-lines result))))))

(fn M.eval-file [opts]
  "Client function, called by Conjure when evaluating a file from disk."
  (set opts.code (core.slurp opts.file-path))
  (when opts.code
    (M.eval-str opts)))

(fn M.doc-str [opts]
  "Client function, called by Conjure when looking up documentation."
  (core.assoc opts :code (.. ",doc " opts.code))
  (M.eval-str opts))

M
