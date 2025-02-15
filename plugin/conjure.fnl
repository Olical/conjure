(if (= 1 (vim.fn.has "nvim-0.8"))
  (let [main (require :conjure.main)]
    (main.main))
  (vim.notify_once "Conjure requires Neovim > v0.8" vim.log.levels.ERROR))
