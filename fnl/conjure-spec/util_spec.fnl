(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local util (require :conjure.util))

(describe
  "replace-termcodes"
  (fn []
    (it "escapes sequences like <C-o>"
        (fn []
          (assert.equals
            "hello\015world"
            (util.replace-termcodes "hello<C-o>world"))))))
