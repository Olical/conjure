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

(deftest resolve-relative-to
  (t.= "fnl/conjure/fs.fnl"
       (fs.resolve-relative-to
         (.. (nvim.fn.getcwd) "/fnl/conjure/fs.fnl")
         (nvim.fn.getcwd))
       "cut down relative to the root")

  (t.= "/foo/bar/fnl/conjure/fs.fnl-nope"
       (fs.resolve-relative-to
         "/foo/bar/fnl/conjure/fs.fnl-nope"
         (nvim.fn.getcwd))
       "fall back to original"))

(deftest apply-path-subs
  (t.= "/home/olical/foo"
       (fs.apply-path-subs
         "/home/ollie/foo"
         {"ollie" "olical"})
       "simple mid-string replacement")
  (t.= "/home/ollie/foo"
       (fs.apply-path-subs
         "/home/ollie/foo"
         {"^ollie" "olical"})
       "non matches do nothing")
  (t.= "/home/ollie/foo"
       (fs.apply-path-subs
         "/home/ollie/foo"
         nil)
       "nil path-subs does nothing")
  (t.= "/home/olical/foo"
       (fs.apply-path-subs
         "/home/ollie/foo"
         {"^(/home/)ollie" "%1olical"})
       "gsub capture group replacement"))
