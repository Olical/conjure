(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local school (require :conjure.school))

(describe "running :ConjureSchool"
  (fn []
    (school.start)

    (it "buffer has correct name"
        (fn []
          (assert.are.equals "conjure-school.fnl" (vim.fn.bufname))))

    (it "buffer requires conjure.school module"
        (fn []
          (assert.same ["(local school (require :conjure.school))"] (vim.api.nvim_buf_get_lines 0 0 1 false))))

    (vim.cmd.bdelete "conjure-school.fnl")))
