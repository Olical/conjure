(ns conjure.main
  "Entry point for the plugin when in production mode."
  (:require [cljs.nodejscli]
            [cljs.nodejs :as node]
            [cljs.core.async :as a]
            [clojure.string :as str]
            [promesa.core :as p]
            [applied-science.js-interop :as j]
            [conjure.nvim :as nvim]
            [conjure.session :as session]))

(node/enable-util-print!)

;; TODO All sorts of parsing and validation.

(defn add! [args-str]
  (p/do*
    (let [[tag-str port-str] (str/split (str args-str) #",")
          tag (keyword tag-str)
          port (js/parseInt port-str 10)]
      (session/add! {:tag tag, :port port}))))

(defn remove! [tag-str]
  (p/do*
    (session/remove! (keyword (str tag-str)))))

(defn eval! [code]
  (p/do*
    (a/go
      (doseq [conn (session/path-conns "foo.clj")]
        (a/>! (get-in conn [:prepl :eval-chan]) (str code))))))

(defn setup! [plugin]
  (nvim/reset-plugin! plugin)
  (nvim/register-command! :CLJS add! {:nargs "*"})
  (nvim/register-command! :CLJSRemove remove! {:nargs "1"})
  (nvim/register-command! :CLJSEval eval! {:nargs "1"}))

(j/assoc! js/module :exports setup!)
