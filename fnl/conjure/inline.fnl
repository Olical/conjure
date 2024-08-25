(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local config (autoload :conjure.config))
(local nvim (autoload :conjure.aniseed.nvim))

(local ns-id (nvim.create_namespace :conjure.inline))

(fn sanitise-text [s]
  (if (a.string? s)
    (s:gsub "%s+" " ")
    ""))

(fn clear [opts]
  "Clear all (Conjure related) virtual text for opts.buf, defaults to 0 which
  is the current buffer."
  (pcall
    (fn []
      (nvim.buf_clear_namespace (a.get opts :buf 0) ns-id 0 -1))))

(fn display [opts]
  "Display virtual text for opts.buf on opts.line containing opts.text."
  (local hl-group (config.get-in [:eval :inline :highlight]))
  (pcall
    (fn []
      (clear)
      (nvim.buf_set_virtual_text
        (a.get opts :buf 0) ns-id opts.line
        [[(sanitise-text opts.text) hl-group]]
        {}))))

{
 : sanitise-text
 : clear
 : display
 }
