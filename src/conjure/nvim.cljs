(ns conjure.nvim
  (:require [goog.object :as go]))

(defonce api! (atom nil))

(defn hello []
  (let [append (go/getValueByKeys @api! #js ["buffer" "append"])]
    (append "Hello, World! From Conjure ClojureScript!")))

(defn setup! [plugin]
  (reset! api! (go/get plugin "nvim"))

  (let [register-command (go/get plugin "registerCommand")]
    (register-command plugin "ConjureCLJS" hello)))
