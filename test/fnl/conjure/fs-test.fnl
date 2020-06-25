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

(deftest file-readable?
  (t.= false (fs.file-readable? "doesn't exist") "doesn't exist")
  (t.= false (fs.file-readable? "fnl" "it's a directory"))
  (t.= true (fs.file-readable? "README.adoc") "README.adoc is readable"))

(deftest split-path
  (t.pr= [] (fs.split-path ""))
  (t.pr= [] (fs.split-path "/"))
  (t.pr= ["foo" "bar" "baz"] (fs.split-path "/foo/bar/baz")))

(deftest join-path
  (t.pr= "" (fs.join-path []))
  (t.pr= "foo/bar/baz" (fs.join-path ["foo" "bar" "baz"])))

(deftest resolve-relative
  (t.= "fnl/conjure/fs.fnl"
       (fs.resolve-relative (.. (nvim.fn.getcwd) "/fnl/conjure/fs.fnl"))
       "cut down relative to the root")

  (t.= "/foo/bar/fnl/conjure/fs.fnl-nope"
       (fs.resolve-relative "/foo/bar/fnl/conjure/fs.fnl-nope")
       "fall back to original"))
