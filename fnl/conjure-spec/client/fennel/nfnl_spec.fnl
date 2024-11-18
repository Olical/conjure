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
            (assert.is.nil (nfnlc.module-path nil))
            nil))

        (it "handles single path segments"
          (fn []
            (assert.are.equal "foo" (nfnlc.module-path (fs.full-path "fnl/foo.fnl")))
            nil))

        (it "handles multiple path segments"
          (fn []
            (assert.are.equal "foo.bar.baz" (nfnlc.module-path (fs.full-path "fnl/foo/bar/baz.fnl")))
            nil))))

    (describe "repl-for-path"
      (fn []
        (local path (fs.full-path "fnl/foo.fnl"))

        (it "returns a new repl for a path"
          (fn []
            (assert.is.function (nfnlc.repl-for-path path))
            nil))

        (it "returns the same function each time"
          (fn []
            (assert.is.equal (nfnlc.repl-for-path path) (nfnlc.repl-for-path path))
            nil))

        (it "executes fennel and returns the results"
          (fn []
            (assert.are.same [30] ((nfnlc.repl-for-path path) "(+ 10 20)"))
            nil))))))
