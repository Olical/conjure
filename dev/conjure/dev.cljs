(ns conjure.dev
  (:require [cljs.nodejs :as nodejs]
            [promesa.core :as p]
            [conjure.interop :as in]
            [conjure.nvim :as nvim]))

(nodejs/enable-util-print!)

(defn connect! []
  (->> (js/require "neovim/scripts/nvim")
       (p/map #(reset! nvim/api! %))
       (p/error #(in/eprintln "Failed to connect to existing nvim instance, start it with `make nvim`" %))))
