(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local config (autoload :conjure.config))

(local M (define :conjure.inline))

(local ns-id (vim.api.nvim_create_namespace :conjure.inline))

(fn M.sanitise-text [s]
  (if (core.string? s)
    (s:gsub "%s+" " ")
    ""))

(fn M.clear [opts]
  "Clear all (Conjure related) virtual text for opts.buf, defaults to 0 which
  is the current buffer."
  (pcall
    (fn []
      (vim.api.nvim_buf_clear_namespace (core.get opts :buf 0) ns-id 0 -1))))

(fn M.display [opts]
  "Display virtual text for opts.buf on opts.line containing opts.text."
  (local hl-group (config.get-in [:eval :inline :highlight]))
  (pcall
    (fn []
      (M.clear)
      (vim.api.nvim_buf_set_virtual_text
        (core.get opts :buf 0) ns-id opts.line
        [[(M.sanitise-text opts.text) hl-group]]
        {}))))

M
