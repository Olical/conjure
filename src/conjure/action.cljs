(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
            [clojure.string :as str]
            [conjure.async :as async :include-macros true]
            [conjure.session :as session]
            [conjure.nvim :as nvim]
            [conjure.display :as display]
            [conjure.code :as code]))

;; TODO Get current ns and switch to that ns first.
;; TODO Add mappings for this, probably want inner form, outer form and visual selection.
;; TODO Add the key tools such as doc, goto, autocomplete, tests and file loading.

(defn eval! [code]
  (async/go
    (let [buffer (a/<! (nvim/<buffer))
          path (a/<! (nvim/<name buffer))]
      (if-let [conns (session/conns path)]
        (do
          (display/info! "Eval with" (str/join ", " (map (comp name :tag) conns)) "=>" (code/sample code))
          (doseq [conn conns]
            (display/log! {:conn conn, :value (a/<! (session/<eval! conn code))})))
        (display/error! "No matching connections for path" path)))))
