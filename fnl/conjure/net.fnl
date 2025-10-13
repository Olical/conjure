(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))

(import-macros {: augroup : autocmd} :conjure.macros)

(local M (define :conjure.net {}))

(fn M.resolve [host]
  ;; Mostly to work around jeejah binding to localhost instead of 127.0.0.1 and
  ;; libuv net requiring IP addresses.
  (if (= host "::")
    host
    (-> host
        (->> (vim.uv.getaddrinfo)
             (core.filter #(= "inet" (core.get $1 :family)))
             (core.first))
        (core.get :addr))))

(local state {:sock-drawer []})

(fn destroy-sock [sock]
  (when (not (sock:is_closing))
    (sock:read_stop)
    (sock:shutdown)
    (sock:close))

  (set state.sock-drawer (core.filter #(not= sock $1) state.sock-drawer)))

(fn M.connect [{:  host : port : cb}]
  (let [sock (vim.uv.new_tcp)
        resolved-host (M.resolve host)]

    (when (not resolved-host)
      (error "Failed to resolve host for Conjure connection"))

    (sock:connect resolved-host port cb)
    (table.insert state.sock-drawer sock)
    {:sock sock
     :resolved-host resolved-host
     :destroy #(destroy-sock sock)
     :host host
     :port port}))

(fn destroy-all-socks []
  (core.run! destroy-sock state.sock-drawer))

(local group (vim.api.nvim_create_augroup "conjure-net-sock-cleanup" {}))
(vim.api.nvim_create_autocmd
  :VimLeavePre
  {: group
   :pattern "*"
   :callback destroy-all-socks})

M
