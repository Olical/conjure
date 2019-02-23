(ns conjure.nvim
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

(defn append [target value]
  (j/call target :append value))

(defn echo [message]
  (j/call @api! :outWriteLine message))

(defn echo-error [message]
  (j/call @api! :errWriteLine message))

(defn register-command [k f]
  (j/call @plugin! :registerCommand (name k) f))
