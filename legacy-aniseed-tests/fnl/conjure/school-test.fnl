(module conjure.school-test
  {require {school conjure.school
            nvim conjure.aniseed.nvim}})

(deftest start
  (school.start)
  (t.= "conjure-school.fnl" (nvim.fn.bufname))
  (t.pr= ["(module user.conjure-school"] (nvim.buf_get_lines 0 0 1 false))
  (nvim.ex.bdelete "conjure-school.fnl"))
