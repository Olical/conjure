(ns conjure.nvim
  "Wrapper around all nvim functions."
  (:require [cljs.nodejs :as node]
            [clojure.string :as str]
            [applied-science.js-interop :as j]
            [conjure.util :as util]))

(defonce plugin! (atom nil))
(defonce api! (atom nil))

(defn require-api! []
  (-> (node/require "neovim/scripts/nvim")
      (.then #(reset! api! %))))

(defn reset-plugin! [plugin]
  (reset! plugin! plugin)
  (reset! api! (j/get plugin :nvim)))

(defn <buffer []
  (-> (j/get @api! :buffer)
      (util/->chan)))

(defn <path [buffer]
  (-> (j/get buffer :name)
      (util/->chan)))

(defn- join [args]
  (str/join " " (remove nil? args)))

(defn out-write! [& args]
  (j/call @api! :outWrite (join args)))

(defn out-write-line! [& args]
  (j/call @api! :outWriteLine (join args)))

(defn err-write! [& args]
  (j/call @api! :errWrite (join args)))

(defn err-write-line! [& args]
  (j/call @api! :errWriteLine (join args)))

(defn register-command!
  ([k f] (register-command! k f {}))
  ([k f opts]
   (j/call @plugin! :registerCommand
           (name k)
           (fn [s]
             (try
               (f (str s))
               (catch :default e
                 (err-write-line! e))))
           (util/->js opts))))
