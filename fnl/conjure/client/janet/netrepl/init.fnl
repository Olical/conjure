(module conjure.client.janet.netrepl
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            bridge conjure.bridge
            mapping conjure.mapping
            text conjure.text
            ui conjure.client.janet.netrepl.ui
            config conjure.config
            server conjure.client.janet.netrepl.server}})

(def buf-suffix ".janet")
(def comment-prefix "# ")

(config.merge
  {:client
   {:janet
    {:netrepl
     {:connection {:default_host "127.0.0.1"
                   :default_port "9365"}
      :mapping {:connect "cc"
                :disconnect "cd"}}}}})

(defn eval-str [opts]
  (server.send
    (.. opts.code "\n")
    (fn [msg]
      (let [clean (text.trim-last-newline msg)]
        (when opts.on-result
          ;; ANSI escape trimming happens here AND in log append (if enabled)
          ;; so that "eval and replace form" won't end up inserting ANSI codes.
          (opts.on-result (text.strip-ansi-escape-sequences clean)))
        (when (not opts.passive?)
          (ui.display (text.split-lines clean)))))))

(defn doc-str [opts]
  (eval-str (a.update opts :code #(.. "(doc " $1 ")"))))

(defn eval-file [opts]
  (eval-str
    (a.assoc opts :code (.. "(do (dofile \"" opts.file-path
                            "\" :env (fiber/getenv (fiber/current))) nil)"))))

(defn connect [opts]
  (server.connect opts))

(defn on-filetype []
  (mapping.buf :n (config.get-in [:client :janet :netrepl :mapping :disconnect])
               :conjure.client.janet.netrepl.server :disconnect)
  (mapping.buf :n (config.get-in [:client :janet :netrepl :mapping :connect])
               :conjure.client.janet.netrepl.server :connect))

(defn on-load []
  (nvim.ex.augroup :conjure_janet_netrepl_cleanup)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    "VimLeavePre *"
    (bridge.viml->lua :conjure.client.janet.netrepl.server :disconnect {}))
  (nvim.ex.augroup :END)

  (server.connect {}))
