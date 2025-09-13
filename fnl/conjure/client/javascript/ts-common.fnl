(local {: define } (require :conjure.nfnl.module))
(local text (require :conjure.text))

(local M (define :conjure.client.javascript.ts-common))

;; Path resolution for relative imports
(fn M.resolve-path [path]
  (if (text.starts-with path ".")
      (vim.fs.normalize (vim.fs.joinpath (vim.fn.expand "%:p:h") path))
      path))

;; Transform "as" syntax in named imports
(fn M.transform-as-syntax [binding-text]
  (string.gsub binding-text " as " ": "))

(fn M.get-text [node code]
  (vim.treesitter.get_node_text node code))

(fn M.get-tree [code]
  (let [parser (vim.treesitter.get_string_parser code vim.bo.filetype)]
    (. (parser:parse) 1)))

(fn M.get-child [node nm]
  (. (node:field nm) 1))

(fn M.find-child-by-type [node type-str]
  (var result nil)
  (each [child (node:iter_children)]
    (if (= (child:type) type-str)
        (set result child)))
  result)

M
