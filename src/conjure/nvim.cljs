(ns conjure.nvim
  (:require [conjure.interop :as in]))

(defonce api! (atom nil))

(defn hello []
  (in/oapply-in @api! [:buffer :append] "Hello, World! From Conjure ClojureScript!"))

(defn setup! [plugin]
  (reset! api! (in/oget plugin :nvim))
  (in/oapply plugin :registerCommand "ConjureCLJS" hello))
