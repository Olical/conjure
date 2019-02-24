(ns conjure.main
  "Entry point for the plugin when in production mode."
  (:require  ;; This is required to ensure setTimeout is defined under advanced compilation.
            [cljs.nodejscli]

            [cljs.nodejs :as node]
            [cljs.core.async :as a]
            [clojure.edn :as edn]
            [applied-science.js-interop :as j]
            [promesa.core :as p]
            [conjure.nvim :as nvim]
            [conjure.session :as session]
            [conjure.display :as display]))

(node/enable-util-print!)

(defn parse [spec s]
  (display/ensure! spec (edn/read-string s)))

(defn add! [s]
  (p/do*
    (when-let [new-conn (parse ::session/new-conn s)]
      (session/add! new-conn))))

(defn remove! [s]
  (p/do*
    (when-let [tag (parse ::session/tag s)]
      (session/remove! tag))))

(defn eval! [s]
  (p/do*
    (a/go
      (doseq [conn (session/path-conns "foo.clj")]
        (a/>! (get-in conn [:prepl :eval-chan]) s)))))

(defn setup! [plugin]
  (nvim/reset-plugin! plugin)
  (nvim/register-command! :CLJS add! {:nargs "1"})
  (nvim/register-command! :CLJSRemove remove! {:nargs "1"})
  (nvim/register-command! :CLJSEval eval! {:nargs "1"}))

(j/assoc! js/module :exports setup!)
