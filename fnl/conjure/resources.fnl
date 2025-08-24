(local {: autoload : define} (require :conjure.nfnl.module))
(local a (require :conjure.nfnl.core))
(local log (autoload :conjure.log))

(local M (define :conjure.resources))

(local resource-prefix "res/")

(var cache {})

(fn read-and-cache-file-contents [path]
  (log.dbg (.. path " resource not cached - reading"))
  (let [content (a.slurp path)]
    (tset cache path content)
    content))

(fn get-cached-file-contents [path]
  (if (. cache path)
    (. cache path)
    (read-and-cache-file-contents path)))

(fn M.get-resource-contents [path]
  (let [resource-path (.. resource-prefix path)
        file-paths (vim.api.nvim_get_runtime_file resource-path false)]
    (if (> (length file-paths) 0)
      (get-cached-file-contents (. file-paths 1)) 
      nil)))

M
