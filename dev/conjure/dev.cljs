(ns conjure.dev
  (:require [cljs.nodejs :as nodejs]
            [promesa.core :as p]
            [conjure.nvim :as nvim]))

(nodejs/enable-util-print!)

(defn connect! []
  (->> (js/require "neovim/scripts/nvim")
       (p/map #(reset! nvim/api! %))))
