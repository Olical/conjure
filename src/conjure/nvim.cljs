(ns conjure.nvim
  "Wrapper around all nvim functions."
  (:require [applied-science.js-interop :as j]
            [conjure.util :as util]))

(defonce plugin! (atom nil))
(defonce api! (atom nil))

(defn reset-api! [api]
  (reset! api! api))

(defn reset-plugin! [plugin]
  (reset! plugin! plugin)
  (reset-api! (j/get plugin :nvim)))

(defn buffer []
  (j/get @api! :buffer))

(defn path [buffer]
  (j/get buffer :name))

(defn out-write-line! [line]
  (j/call @api! :outWriteLine line))

(defn err-write-line! [line]
  (j/call @api! :errWriteLine line))

(defn register-command!
  ([k f] (register-command! k f {}))
  ([k f opts]
   (j/call @plugin! :registerCommand
           (name k)
           (comp f str)
           (util/->js opts))))
