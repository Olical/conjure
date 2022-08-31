(module conjure.inline
  {autoload {a conjure.aniseed.core
             config conjure.config
             nvim conjure.aniseed.nvim}})

(defonce ns-id (nvim.create_namespace *module-name*))

(defn sanitise-text [s]
  (if (a.string? s)
    (s:gsub "%s+" " ")
    ""))

(defn clear [opts]
  "Clear all (Conjure related) virtual text for opts.buf, defaults to 0 which
  is the current buffer."
  (pcall
    (fn []
      (nvim.buf_clear_namespace (a.get opts :buf 0) ns-id 0 -1))))

(defn display [opts]
  "Display virtual text for opts.buf on opts.line containing opts.text."
  (local hl-group (config.get-in [:eval :inline :highlight]))
  (pcall
    (fn []
      (clear)
      (nvim.buf_set_virtual_text
        (a.get opts :buf 0) ns-id opts.line
        [[(sanitise-text opts.text) hl-group]]
        {}))))
