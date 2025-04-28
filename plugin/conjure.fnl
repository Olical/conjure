(local minimum-version "0.9")
(if (= 1 (vim.fn.has (.. "nvim-" minimum-version)))
  (let [main (require :conjure.main)]
    (main.main))
  (vim.notify_once (.. "Conjure requires Neovim > v" minimum-version) vim.log.levels.ERROR))
