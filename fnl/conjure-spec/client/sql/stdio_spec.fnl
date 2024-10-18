(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local sql (require :conjure.client.sql.stdio))

(describe "conjure.client.sql.stdio"
  (fn []
    (describe "prep-code"
      (fn []
        (it "prepares sql code appropriately"
            (fn []
              ;; Remove trailing comments from meta commands
              ;; I may regret this when there's a meta command that takes double dash args...
              (assert.same
                "foo\n"
                (sql.prep-code
                  {:code "foo -- bar"
                   :node {:type (fn [] :meta)}}))

              ;; Only works on the last line so we don't mangle code, hopefully
              (assert.same
                "foo -- bar\nsomething\n"
                (sql.prep-code
                  {:code "foo -- bar\nsomething -- quuz"
                   :node {:type (fn [] :meta)}}))

              ;; If the last line has an extra blank line we do nothing, shouldn't really ever happen, but here's the behaviour anyway
              (assert.same
                "foo -- bar\nsomething -- quux\n\n"
                (sql.prep-code
                  {:code "foo -- bar\nsomething -- quux\n"
                   :node {:type (fn [] :meta)}}))

              ;; If something is a statement it gets a semi colon on the end too
              (assert.same
                "foo;\n"
                (sql.prep-code
                  {:code "foo -- bar"
                   :node {:type (fn [] :statement)}}))

              nil))))))
