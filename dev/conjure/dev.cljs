(ns conjure.dev
  "Hooks into the result of `make nvim` through the `make dev` prepl."
  (:require [cljs.nodejs :as node]
            [cljs.core.async :as a]
            [conjure.util :as util]
            [conjure.nvim :as nvim]))

(node/enable-util-print!)

(defn connect! []
  (let [nvim (util/->chan (node/require "neovim/scripts/nvim"))]
    (a/go (nvim/reset-api! (a/<! nvim)))))
