(ns conjure.nvim
  "Wrapper around all nvim functions."
  (:require [applied-science.js-interop :as j]))

(defonce plugin! (atom nil))
(defonce api! (atom nil))

(defn reset-api! [api]
  (reset! api! api))

(defn reset-plugin! [plugin]
  (reset! plugin! plugin)
  (reset-api! (j/get plugin :nvim)))

(defn buffer []
  (j/get @api! :buffer))

(defn out-write-line! [line]
  (j/call @api! :outWriteLine line))

(defn err-write-line! [line]
  (j/call @api! :errWriteLine line))

(defn register-command! [k f opts]
  (j/call @plugin! :registerCommand (name k) f (clj->js opts)))
