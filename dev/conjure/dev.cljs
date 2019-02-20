(ns conjure.dev
  (:require [conjure.nvim :as nvim]))

(defn connect! []
  (-> (js/require "neovim/scripts/nvim")
      (.then #(reset! nvim/api! %))))
