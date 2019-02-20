(ns conjure.dev
  (:require [promesa.core :as p]
            [conjure.nvim :as nvim]))

(defn connect! []
  (->> (js/require "neovim/scripts/nvim")
       (p/map #(reset! nvim/api! %))))
