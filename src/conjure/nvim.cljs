(ns conjure.nvim
  (:require [goog.object :as go]))

(defonce api! (atom nil))

(defn hello []
  ((go/getValueByKeys @api! #js ["buffer" "append"]) "Hello, World! From Conjure ClojureScript!"))

(defn setup! [plugin]
  (reset! api! (go/get plugin "nvim"))
  ((go/get plugin "registerCommand") "ConjureCLJS" hello))
