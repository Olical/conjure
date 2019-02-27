(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
            [conjure.session :as session]
            [conjure.nvim :as nvim]
            [conjure.display :as display]
            [conjure.code :as code]))

;; TODO Get current ns and switch to that ns first.
;; TODO Add mappings for this, probably want inner form, outer form and visual selection.
;; TODO Add a better output that doesn't hide anything, maybe a log buffer but have it show and hide.
;; TODO Add the key tools such as doc, goto, autocomplete, tests and file loading.

(defn eval! [code]
  (a/go
    (let [buffer (a/<! (nvim/<buffer))
          path (a/<! (nvim/<path buffer))]
      (if-let [conns (session/conns path)]
        (doseq [{:keys [tag] :as conn} conns]
          (let [result (a/<! (session/<eval! conn code))]
            (display/result! tag (update result :val code/format))))
        (display/error! nil "No matching connections for path:" path)))))
