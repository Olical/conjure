(module conjure.net
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            bridge conjure.bridge}})

(defn resolve [host]
  ;; Mostly to work around jeejah binding to localhost instead of 127.0.0.1 and
  ;; libuv net requiring IP addresses.
  (if (= host "::")
    host
    (-> host
        (->> (vim.loop.getaddrinfo)
             (a.filter #(= "inet" (a.get $1 :family)))
             (a.first))
        (a.get :addr))))

(defonce- state
  {:sock-drawer []})

(defn- destroy-sock [sock]
  (when (not (sock:is_closing))
    (sock:read_stop)
    (sock:shutdown)
    (sock:close))

  (set state.sock-drawer (a.filter #(not= sock $1) state.sock-drawer)))

(defn connect [{:  host : port : cb}]
  (let [sock (vim.loop.new_tcp)
        resolved-host (resolve host)]
    (sock:connect resolved-host port cb)
    (table.insert state.sock-drawer sock)
    {:sock sock
     :resolved-host resolved-host
     :destroy #(destroy-sock sock)
     :host host
     :port port}))

(defn destroy-all-socks []
  (a.run! destroy-sock state.sock-drawer))

(nvim.ex.augroup :conjure_net_sock_cleanup)
(nvim.ex.autocmd_)
(nvim.ex.autocmd
  "VimLeavePre *"
  (bridge.viml->lua :conjure.net :destroy-all-socks {}))
(nvim.ex.augroup :END)
