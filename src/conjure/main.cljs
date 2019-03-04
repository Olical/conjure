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

(defn eval! [s]
  (action/eval! s))

(defn show-log! []
  (display/show-log!))

(defn hide-log! []
  (display/hide-log!))

(defn setup! [plugin]
  (init!)
  (nvim/reset-plugin! plugin)

  (nvim/register-command! :CLJSAdd add! {:nargs "1"})
  (nvim/register-command! :CLJSRemove remove! {:nargs "1"})
  (nvim/register-command! :CLJSEval eval! {:nargs "1"})
  (nvim/register-command! :CLJSShowLog show-log!)
  (nvim/register-command! :CLJSHideLog hide-log!)

  (nvim/register-autocmd! :CursorMoved hide-log! {:pattern "*"}))

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
  (eval! "(+ 10 10)")
  (eval! "(repeat 20 :henlo)")
  (eval! "(prn :thisisasuperlongthingtoevalanditshouldgettruncated)")
  (eval! "`(fn [foo] (+ foo foo))")
  (eval! "(doc +)")
  (eval! "(prn 1) (prn 2) (prn 3) (prn 4) (prn 5)")
  (eval! "(println \"henlo\")")
  (remove! ":dev"))
