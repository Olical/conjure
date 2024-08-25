(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local school (require :conjure.school))
(local nvim (require :conjure.aniseed.nvim))

(describe "running :ConjureSchool"
  (fn []
    (school.start)

    (it "buffer has correct name"
        (fn []
          (assert.are.equals "conjure-school.fnl" (nvim.fn.bufname))))

    (it "buffer requires conjure.school module"
        (fn []
          (assert.same ["(local school (require :conjure.school))"] (nvim.buf_get_lines 0 1 2 false))))

    (nvim.ex.bdelete "conjure-school.fnl")
        ))
