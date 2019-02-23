(ns conjure.nvim
  (:require [applied-science.js-interop :as j]))

(defonce plugin! (atom nil))
(defonce api! (atom nil))

(defn store-api! [api]
  (reset! api! api))

(defn store-plugin! [plugin]
  (reset! plugin! plugin)
  (store-api! (j/get plugin :nvim)))

(defn api []
  (or @api! (throw (js/Error. "api not available"))))

(defn plugin []
  (or @plugin! (throw (js/Error. "plugin not available"))))

(defn buffer []
  (j/get (api) :buffer))

(defn append [target value]
  (doto target
    (j/call :append value)))

(defn register-command [k f]
  (doto (plugin)
    (j/call :registerCommand (name k) f)))
