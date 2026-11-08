(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local fs (require :conjure.nfnl.fs))
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
            nil))))

    (describe "eval-str"
      (fn []
        (it "picks up macro changes from disk when evaluating a whole buffer"
          (fn []
            (let [root-dir (vim.fn.tempname)
                  macro-path (.. root-dir "/fnl/conjure-spec-reload-macros.fnlm")
                  eval-buf (fn []
                             (var result nil)
                             (nfnlc.eval-str
                               {:file-path (.. root-dir "/fnl/app.fnl")
                                :origin :buf
                                :code "(import-macros m :conjure-spec-reload-macros) (m.version)"
                                :on-result #(set result $1)})
                             result)]
              (vim.fn.mkdir (.. root-dir "/fnl") "p")
              (vim.fn.writefile ["{:version (fn [] :v1)}"] macro-path)
              (assert.are.equal "\"v1\"" (eval-buf))
              (vim.fn.writefile ["{:version (fn [] :v2)}"] macro-path)
              (assert.are.equal "\"v2\"" (eval-buf))
              (vim.fn.delete root-dir "rf"))
            nil))))))
