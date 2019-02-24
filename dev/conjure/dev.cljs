(ns conjure.dev
  "Hooks into the result of `make nvim` through the `make dev` prepl."
  (:require [cljs.nodejs :as node]
            [promesa.core :as p]
            [conjure.nvim :as nvim]))

(node/enable-util-print!)

(defn connect! []
  (->> (node/require "neovim/scripts/nvim")
       (p/map nvim/reset-api!)))
