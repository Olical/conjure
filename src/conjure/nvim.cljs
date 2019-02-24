(ns conjure.nvim
  (:require [clojure.string :as str]
            [applied-science.js-interop :as j]))

(defonce plugin! (atom nil))
(defonce api! (atom nil))

(defn reset-api! [api]
  (reset! api! api))

(defn reset-plugin! [plugin]
  (reset! plugin! plugin)
  (reset-api! (j/get plugin :nvim)))

(defn buffer []
  (j/get @api! :buffer))

(defn append! [target & value]
  (j/call target :append (str/join " " value)))

(defn echo! [& message]
  (j/call @api! :outWriteLine (str/join " " message)))

(defn echo-error! [& message]
  (j/call @api! :errWriteLine (str/join " " message)))

(defn register-command! [k f opts]
  (j/call @plugin! :registerCommand (name k) f (clj->js opts)))
