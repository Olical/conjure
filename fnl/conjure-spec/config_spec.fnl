(local {: describe : it } (require :plenary.busted))
(local assert (require :luassert.assert))
(local config (require :conjure.config))
(local core (require :conjure.nfnl.core))

(describe "get-in"
  (fn []
    (it "takes a table of keys and fetches the config value from vim.b or vim.g variables."
      (fn []
        (assert.is_true (config.get-in [:client_on_load]))
        (assert.same :conjure.client.clojure.nrepl (config.get-in [:filetype :clojure]))))))

(describe "filetypes"
  (fn []
    (it "returns the filetypes list"
      (fn []
        (assert.same (config.get-in [:filetypes]) (config.filetypes))
        (assert.same :clojure (core.first (config.filetypes)))))))

(describe "get-in-fn"
  (fn []
    (it "returns a function that works like get-in but with a path prefix"
      (fn []
        (assert.same :conjure.client.sql.stdio ((config.get-in-fn [:filetype]) [:sql]))))))

(describe "assoc-in"
 (fn []
   (it "sets some new config"
     (fn []
       (config.assoc-in [:foo :bar] :baz)
       (assert.same :baz (config.get-in [:foo :bar]))))))

(describe "merge"
  (fn []
    (it "merges more config into the tree, requires overwrite? if it already exists"
      (fn []
        (config.merge {:foo {:bar :de_dust2}})
        (assert.same :baz (config.get-in [:foo :bar]))
        (config.merge {:foo {:bar :de_dust2}} {:overwrite? true})
        (assert.same :de_dust2 (config.get-in [:foo :bar]))))))

(describe "hyphen migration"
  (fn []
    (it "get-in falls back to a hyphenated key and emits a deprecation warning"
      (fn []
        (let [warnings []
              orig vim.notify_once]
          ; "migration" has no underscores, so gsub only replaces the leaf underscore
          (core.assoc vim.g "conjure#migration#old-key" :legacy)
          (set vim.notify_once (fn [msg _] (table.insert warnings msg)))
          (let [result (config.get-in [:migration :old_key])]
            (set vim.notify_once orig)
            (core.assoc vim.g "conjure#migration#old-key" nil)
            (assert.same :legacy result)
            (assert.same 1 (length warnings))
            (assert.truthy (string.find (. warnings 1) "deprecated" 1 true))))))

    (it "get-in reads an underscore key normally without any warning"
      (fn []
        (let [warnings []
              orig vim.notify_once]
          (core.assoc vim.g "conjure#migration#new_key" :modern)
          (set vim.notify_once (fn [msg _] (table.insert warnings msg)))
          (let [result (config.get-in [:migration :new_key])]
            (set vim.notify_once orig)
            (core.assoc vim.g "conjure#migration#new_key" nil)
            (assert.same :modern result)
            (assert.same 0 (length warnings))))))

    (it "assoc-in warns when a key segment contains a hyphen"
      (fn []
        (let [warnings []
              orig vim.notify]
          (set vim.notify (fn [msg _] (table.insert warnings msg)))
          (config.assoc-in [:migration :bad-key] :val)
          (set vim.notify orig)
          (core.assoc vim.g "conjure#migration#bad-key" nil)
          (assert.same 1 (length warnings))
          (assert.truthy (string.find (. warnings 1) "hyphen" 1 true)))))

    (it "assoc-in does not warn for underscore keys"
      (fn []
        (let [warnings []
              orig vim.notify]
          (set vim.notify (fn [msg _] (table.insert warnings msg)))
          (config.assoc-in [:migration :good_key] :val)
          (set vim.notify orig)
          (core.assoc vim.g "conjure#migration#good_key" nil)
          (assert.same 0 (length warnings)))))

    (it "merge does not overwrite a value already set via the legacy hyphen key"
      (fn []
        (let [orig vim.notify_once]
          (core.assoc vim.g "conjure#migration#old-key" :legacy)
          (set vim.notify_once (fn [_ _] nil))
          (config.merge {:migration {:old_key :default}})
          (let [result (config.get-in [:migration :old_key])]
            (set vim.notify_once orig)
            (core.assoc vim.g "conjure#migration#old-key" nil)
            (assert.same :legacy result)))))

    (it "get-in falls back to a hyphenated key in vim.b and emits a deprecation warning"
      (fn []
        (let [warnings []
              orig vim.notify_once]
          (core.assoc vim.b "conjure#migration#buf-key" :buffer-legacy)
          (set vim.notify_once (fn [msg _] (table.insert warnings msg)))
          (let [result (config.get-in [:migration :buf_key])]
            (set vim.notify_once orig)
            (core.assoc vim.b "conjure#migration#buf-key" nil)
            (assert.same :buffer-legacy result)
            (assert.same 1 (length warnings))
            (assert.truthy (string.find (. warnings 1) "deprecated" 1 true))))))))
