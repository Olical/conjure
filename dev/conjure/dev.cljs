(ns conjure.dev
  (:require [cljs.nodejs :as node]
            [promesa.core :as p]
            [conjure.nvim :as n]))

(node/enable-util-print!)

(defn connect! []
  (->> (node/require "neovim/scripts/nvim")
       (p/map n/store-api!)))
