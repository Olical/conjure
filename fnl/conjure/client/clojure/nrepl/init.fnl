(module conjure.client.clojure.nrepl
  {require {nvim conjure.aniseed.nvim
            mapping conjure.mapping
            bridge conjure.bridge
            config conjure.client.clojure.nrepl.config
            action conjure.client.clojure.nrepl.action}})

;; TODO Handle stdin requests.
;; TODO Name sessions after cities (or similar) and show type in list.
;; TODO Have all auto completion tools working.
;; TODO Pretty error output.
;; TODO Ensure sideload sessions don't break everything.
;; TODO Tools to hook into shadow and figwheel.
;; TODO Build session language into the session list.

(def buf-suffix ".cljc")
(def context-pattern "[(]%s*ns%s*(.-)[%s){]")
(def comment-prefix "; ")
(def config config)

(defn eval-file [opts]
  (action.eval-file opts))

(defn eval-str [opts]
  (action.eval-str opts))

(defn doc-str [opts]
  (action.doc-str opts))

(defn def-str [opts]
  (action.def-str opts))

(defn on-filetype []
  (mapping.buf :n config.mappings.disconnect
               :conjure.client.clojure.nrepl.server :disconnect)
  (mapping.buf :n config.mappings.connect-port-file
               :conjure.client.clojure.nrepl.action :connect-port-file)
  (mapping.buf :n config.mappings.interrupt
               :conjure.client.clojure.nrepl.action :interrupt)

  (mapping.buf :n config.mappings.last-exception
               :conjure.client.clojure.nrepl.action :last-exception)
  (mapping.buf :n config.mappings.result-1
               :conjure.client.clojure.nrepl.action :result-1)
  (mapping.buf :n config.mappings.result-2
               :conjure.client.clojure.nrepl.action :result-2)
  (mapping.buf :n config.mappings.result-3
               :conjure.client.clojure.nrepl.action :result-3)
  (mapping.buf :n config.mappings.view-source
               :conjure.client.clojure.nrepl.action :view-source)

  (mapping.buf :n config.mappings.session-clone
               :conjure.client.clojure.nrepl.action :clone-current-session)
  (mapping.buf :n config.mappings.session-fresh
               :conjure.client.clojure.nrepl.action :clone-fresh-session)
  (mapping.buf :n config.mappings.session-close
               :conjure.client.clojure.nrepl.action :close-current-session)
  (mapping.buf :n config.mappings.session-close-all
               :conjure.client.clojure.nrepl.action :close-all-sessions)
  (mapping.buf :n config.mappings.session-list
               :conjure.client.clojure.nrepl.action :display-sessions)
  (mapping.buf :n config.mappings.session-next
               :conjure.client.clojure.nrepl.action :next-session)
  (mapping.buf :n config.mappings.session-prev
               :conjure.client.clojure.nrepl.action :prev-session)
  (mapping.buf :n config.mappings.session-select
               :conjure.client.clojure.nrepl.action :select-session-interactive)
  (mapping.buf :n config.mappings.session-type
               :conjure.client.clojure.nrepl.action :display-session-type)

  (mapping.buf :n config.mappings.run-all-tests
               :conjure.client.clojure.nrepl.action :run-all-tests)
  (mapping.buf
    :n config.mappings.run-current-ns-tests
    :conjure.client.clojure.nrepl.action :run-current-ns-tests)
  (mapping.buf
    :n config.mappings.run-alternate-ns-tests
    :conjure.client.clojure.nrepl.action :run-alternate-ns-tests)
  (mapping.buf :n config.mappings.run-current-test
               :conjure.client.clojure.nrepl.action :run-current-test)

  (mapping.buf :n config.mappings.refresh-changed
               :conjure.client.clojure.nrepl.action :refresh-changed)
  (mapping.buf :n config.mappings.refresh-all
               :conjure.client.clojure.nrepl.action :refresh-all)
  (mapping.buf :n config.mappings.refresh-clear
               :conjure.client.clojure.nrepl.action :refresh-clear)

  (nvim.ex.command_
    "-nargs=+ -buffer ConjureConnect"
    (bridge.viml->lua
      :conjure.client.clojure.nrepl.action :connect-host-port
      {:args "<f-args>"})))

(defn on-load []
  (nvim.ex.augroup :conjure_clojure_nrepl_cleanup)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    "VimLeavePre *"
    (bridge.viml->lua :conjure.client.clojure.nrepl.server :disconnect {}))
  (nvim.ex.augroup :END)

  (action.connect-port-file))
