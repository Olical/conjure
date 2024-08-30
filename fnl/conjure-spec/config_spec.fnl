(local {: describe : it } (require :plenary.busted))
(local assert (require :luassert.assert))
(local config (require :conjure.config))
(local core (require :nfnl.core))

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
