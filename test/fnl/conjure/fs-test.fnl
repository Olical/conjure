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

(def ex-mod "test.foo.bar")
(def ex-file "/some-big/ol/path/test/foo/bar.fnl")
(def ex-file2 "/some-big/ol/path/test/foo/bar/init.fnl")
(def ex-no-file "/some-big/ol/path/test/foo/bar/no/init.fnl")

(deftest file-path->module-name
  (tset package.loaded ex-mod {:my :module})

  (t.= nil (fs.file-path->module-name nil))
  (t.= ex-mod (fs.file-path->module-name ex-file))
  (t.= ex-mod (fs.file-path->module-name ex-file))
  (t.= ex-mod (fs.file-path->module-name ex-file2))
  (t.= nil (fs.file-path->module-name ex-no-file))

  (tset package.loaded ex-mod nil))

(deftest upwards-file-search
  ;; No match
  (t.= nil (fs.upwards-file-search [] (nvim.fn.getcwd)))
  (t.= nil (fs.upwards-file-search ["thisbetternotexist"] (nvim.fn.getcwd)))

  ;; Match in the cwd
  (t.= "README.adoc"
       (fs.upwards-file-search
         ["README.adoc"]
         (nvim.fn.getcwd)))

  ;; Match by walking upwards
  (t.= "README.adoc"
       (fs.upwards-file-search
         ["README.adoc"]
         (.. (nvim.fn.getcwd) "/test/fnl/conjure/client/clojure/nrepl")))

  ;; Matching below first, return early
  (t.= "test/fnl/conjure/.fs.test"
       (fs.upwards-file-search
         ["README.adoc" ".fs.test"]
         (.. (nvim.fn.getcwd) "/test/fnl/conjure/client/clojure/nrepl")))

  ;; Matching at same level first, return early
  (t.= "test/fnl/conjure/.fs.test"
       (fs.upwards-file-search
         ["README.adoc" ".fs.test"]
         (.. (nvim.fn.getcwd) "/test/fnl/conjure"))))

(deftest resolve-above
  ;; No match
  (t.= nil (fs.resolve-above []))
  (t.= nil (fs.resolve-above ["thisbetternotexist"]))

  ;; Match in the cwd
  (t.= "README.adoc" (fs.resolve-above ["README.adoc"])))
