(ns conjure.main
  (:require [cljs.nodejs :as nodejs]
            [applied-science.js-interop :as j]
            [conjure.nvim :as n]))

(nodejs/enable-util-print!)

(defn hello []
  (-> (n/buffer)
      (n/append "Hello, World! From Conjure ClojureScript!")))

(defn setup! [plugin]
  (n/store-plugin! plugin)
  (n/register-command :ConjureCLJS hello))

(defn -main []
  (j/assoc! js/module :exports setup!))

(set! *main-cli-fn* -main)
