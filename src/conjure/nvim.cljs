(ns conjure.nvim
  "Wrapper around all nvim functions."
  (:require [cljs.nodejs :as node]
            [cljs.core.async :as a]
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

(defn <buffer
  ([] (<buffer @api!))
  ([o] (-> (j/get o :buffer) (util/->chan))))

(defn <window
  ([] (<window @api!))
  ([o] (-> (j/get o :window) (util/->chan))))

(defn <tabpage
  ([] (<tabpage @api!))
  ([o] (-> (j/get o :tabpage) (util/->chan))))

(defn <name ([buffer]
  (-> (j/get buffer :name)
      (util/->chan))))

(defn <length [buffer]
  (-> (j/get buffer :length)
      (util/->chan)))

(defn append! [buffer & args]
  (j/call buffer :append (util/join args)))

(defn set-width! [window width]
  (j/assoc! window :width width))

(defn set-cursor! [window {:keys [x y]}]
  (j/assoc! window :cursor #js [y x]))

(defn scroll-to-bottom! [window]
  (a/go
    (let [buffer (a/<! (<buffer window))
          length (a/<! (<length buffer))]
      (set-cursor! window {:x 0, :y length}))))

(defn out-write! [& args]
  (j/call @api! :outWrite (util/join args)))

(defn out-write-line! [& args]
  (j/call @api! :outWriteLine (util/join args)))

(defn err-write! [& args]
  (j/call @api! :errWrite (util/join args)))

(defn err-write-line! [& args]
  (j/call @api! :errWriteLine (util/join args)))

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
