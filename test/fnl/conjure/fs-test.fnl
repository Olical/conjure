(module conjure.fs-test
  {require {fs conjure.fs
            nvim conjure.aniseed.nvim}})


(deftest config-dir
  (nvim.fn.setenv :XDG_CONFIG_HOME "")
  (nvim.fn.setenv :HOME "/home/conjure")
  (t.= "/home/conjure/.config/conjure" (fs.config-dir))

  (nvim.fn.setenv :XDG_CONFIG_HOME "/home/conjure/.config")
  (t.= "/home/conjure/.config/conjure" (fs.config-dir)))

(deftest findfile
  (t.= nil (fs.findfile "definitely doesn't exist"))
  (t.= "README.adoc" (fs.findfile "README.adoc")))
