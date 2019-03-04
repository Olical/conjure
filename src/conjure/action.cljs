(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
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
        (doseq [conn conns]
          (display/log! {:conn conn, :value {:tag :eval, :val (code/sample code)}})
          (display/log! {:conn conn, :value (a/<! (session/<eval! conn code))}))
        (display/log! {:conn {:tag :conjure}, :value {:tag :err, :val (str "No matching connections for path: " path)}} )))))
