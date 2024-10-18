(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local fs (require :nfnl.fs))
(local nfnlc (require :conjure.client.fennel.nfnl))

(describe "conjure.client.fennel.nfnl"
  (fn []
    (describe "module-path"
      (fn []
        (it "returns nil when given nil"
          (fn []
            (assert.is.nil (nfnlc.module-path nil))))

        (it "handles single path segments"
          (fn []
            (assert.are.equal "foo" (nfnlc.module-path (fs.full-path "fnl/foo.fnl")))))

        (it "handles multiple path segments"
          (fn []
            (assert.are.equal "foo.bar.baz" (nfnlc.module-path (fs.full-path "fnl/foo/bar/baz.fnl")))))))))
