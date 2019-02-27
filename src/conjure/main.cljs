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

(node/enable-util-print!)

(defn parse [spec s]
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

(defn setup! [plugin]
  (nvim/reset-plugin! plugin)
  (nvim/register-command! :CLJS add! {:nargs "1"})
  (nvim/register-command! :CLJSRemove remove! {:nargs "1"})
  (nvim/register-command! :CLJSEval eval! {:nargs "1"})
  (nvim/register-command! :CLJSCheck (fn [] (nvim/out-write-line! "test"))))

(j/assoc! js/module :exports setup!)

(comment
  (add! "{:tag :dev, :port 5555, :expr #re \".*\"}")
  (eval! "(+ 10 10)")
  (eval! "(println \"henlo\")")
  (remove! ":dev"))
