(module conjure.client.janet.netrepl
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            bridge conjure.bridge
            mapping conjure.mapping
            text conjure.text
            ui conjure.client.janet.netrepl.ui
            config conjure.client.janet.netrepl.config
            server conjure.client.janet.netrepl.server}})

(def buf-suffix ".janet")
(def comment-prefix "# ")

(def config config)

(defn eval-str [opts]
  (server.send
    (.. opts.code "\n")
    (fn [msg]
      (let [clean (text.trim-last-newline (text.strip-ansi-codes msg))]
        (when opts.on-result
          (opts.on-result clean))
        (ui.display (text.split-lines clean))))))

(defn doc-str [opts]
  (eval-str (a.update opts :code #(.. "(doc " $1 ")"))))

(defn eval-file [opts]
  (ui.display ["# Not implemented yet."]))

(defn on-filetype []
  (mapping.buf :n config.mappings.disconnect
               :conjure.client.janet.netrepl.server :disconnect)
  (mapping.buf :n config.mappings.connect
               :conjure.client.janet.netrepl.server :connect)

  (nvim.ex.command_
    "-nargs=+ -buffer ConjureConnect"
    (bridge.viml->lua
      :conjure.client.janet.netrepl.server :connect
      {:args "<f-args>"})))

(defn on-load []
  (nvim.ex.augroup :conjure_janet_netrepl_cleanup)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    "VimLeavePre *"
    (bridge.viml->lua :conjure.client.janet.netrepl.server :disconnect {}))
  (nvim.ex.augroup :END)

  (server.connect))
