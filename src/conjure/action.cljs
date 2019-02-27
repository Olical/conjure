(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
            [conjure.session :as session]
            [conjure.nvim :as nvim]
            [conjure.display :as display]))

;; TODO Get current ns and switch to that ns first.
;; TODO Add mappings for this, probably want inner form, outer form and visual selection.
;; TODO Add a better output that doesn't hide anything, maybe a log buffer but have it show and hide.
;; TODO Add the key tools such as doc, goto, autocomplete, tests and file loading.

(defn eval! [code]
  (a/go
    (let [buffer (a/<! (nvim/<buffer))
          path (a/<! (nvim/<path buffer))]
      (if-let [conns (session/conns path)]
        (doseq [conn conns]
          (display/result! conn (a/<! (session/<eval! conn code))))
        (display/error! nil "No matching connections for path:" path)))))
