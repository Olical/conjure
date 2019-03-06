(ns conjure.main
  "Entry point for the plugin when in production mode."
  (:require  ;; This is required to ensure setTimeout is defined under advanced compilation.
            [cljs.nodejscli]

            [cljs.nodejs :as node]
            [cljs.reader :as edn]
            [applied-science.js-interop :as j]
            [conjure.nvim :as nvim]
            [conjure.session :as session]
            [conjure.display :as display]
            [conjure.action :as action]))

(defn- init! []
  (node/enable-util-print!)
  (nvim/enable-error-print!)
  (display/enable-log-print!))

(defn- parse [spec s]
  (let [v (edn/read-string {:readers {'re re-pattern}} s)]
    (display/ensure! spec v)))

(defn add! [s]
  (when-let [new-conn (parse ::session/new-conn s)]
    (session/add! new-conn)))

(defn remove! [s]
  (when-let [tag (parse ::session/tag s)]
    (session/remove! tag)))

(defn setup! [plugin]
  (init!)
  (nvim/reset-plugin! plugin)

  (nvim/register-command! :CLJSAdd add! {:nargs "1"})
  (nvim/register-command! :CLJSRemove remove! {:nargs "1"})
  (nvim/register-command! :CLJSEval action/eval! {:nargs "1"})
  (nvim/register-command! :CLJSShowLog display/show-log!)
  (nvim/register-command! :CLJSHideLog display/hide-log!)

  ;; TODO Work out why autocmd patterns aren't going through, should get log resizing working
  ;; TODO Swap the CursorMoved and InsertEnter events to use an inverse pattern when they work
  (nvim/register-autocmd! :CursorMoved display/hide-background-log! {:pattern "*"})
  (nvim/register-autocmd! :InsertEnter display/hide-background-log! {:pattern "*"})
  (nvim/register-command! :BufEnter #(display/set-log-size! :large) {:pattern "/tmp/conjure-log-*.cljc"})
  (nvim/register-command! :BufLeave #(display/set-log-size! :small) {:pattern "/tmp/conjure-log-*.cljc"}))

(j/assoc! js/module :exports setup!)

(comment
  ;; Development: `make nvim`, `make dev`, REPL into port 5885 then execute this once.
  (do
    ;; Connect the REPL to the Neovim instance.
    (nvim/require-api!)

    ;; Initialise the logging and printing go-loops.
    ;; This is not idempotent!
    (init!))

  (add! "{:tag :dev, :port 5555, :expr #re \".*\"}")
  (action/eval! "(+ 10 10)")
  (action/eval! "(repeat 20 :henlo)")
  (action/eval! "(prn :thisisasuperlongthingtoevalanditshouldgettruncated)")
  (action/eval! "`(fn [foo] (+ foo foo))")
  (action/eval! "(doc +)")
  (action/eval! "(prn 1) (prn 2) (prn 3) (prn 4) (prn 5)")
  (action/eval! "(println \"henlo\")")
  (remove! ":dev"))
