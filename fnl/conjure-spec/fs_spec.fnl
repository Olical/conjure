(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local fs (require :conjure.fs))
(local nvim (require :conjure.aniseed.nvim))

(describe "fs"
  (fn []
    (describe "config-dir"
      (fn []
        (it "returns the default config dir when XDG_CONFIG_HOME is not set"
          (fn []
            (nvim.fn.setenv "XDG_CONFIG_HOME" "")
            (nvim.fn.setenv "HOME" "/home/conjure")
            (assert.equals "/home/conjure/.config/conjure" (fs.config-dir)))))

        (it "returns the XDG config dir when XDG_CONFIG_HOME is set"
          (fn []
            (nvim.fn.setenv "XDG_CONFIG_HOME" "/home/conjure/.config")
            (assert.equals "/home/conjure/.config/conjure" (fs.config-dir))))))

    (describe "findfile"
      (fn []
        (it "returns nil for non-existent files"
          (fn []
            (assert.equals nil (fs.findfile "definitely doesn't exist"))))

        (it "returns the correct file path for an existing file"
          (fn []
            (assert.equals (.. (nvim.fn.getcwd) "/README.adoc") (fs.findfile "README.adoc"))))))

    (describe "file-readable?"
      (fn []
        (it "returns false for non-existent files"
          (fn []
            (assert.equals false (fs.file-readable? "doesn't exist"))))

        (it "returns false for directories"
          (fn []
            (assert.equals false (fs.file-readable? "fnl"))))

        (it "returns true for readable files"
          (fn []
            (assert.equals true (fs.file-readable? "README.adoc"))))))

    (describe "split-path"
      (fn []
        (it "returns an empty list for an empty path"
          (fn []
            (assert.same [] (fs.split-path ""))))

        (it "returns an empty list for the root path"
          (fn []
            (assert.same [] (fs.split-path "/"))))

        (it "splits a path into its components"
          (fn []
            (assert.same ["foo" "bar" "baz"] (fs.split-path "/foo/bar/baz"))))))

    (describe "join-path"
      (fn []
        (it "returns an empty string for an empty list"
          (fn []
            (assert.equals "" (fs.join-path []))))

        (it "joins path components into a single string"
          (fn []
            (assert.equals "foo/bar/baz" (fs.join-path ["foo" "bar" "baz"]))))))

    (describe "resolve-relative-to"
      (fn []
        (it "resolves a path relative to a given base path"
          (fn []
            (assert.equals "fnl/conjure/fs.fnl"
              (fs.resolve-relative-to
                (.. (nvim.fn.getcwd) "/fnl/conjure/fs.fnl")
                (nvim.fn.getcwd)))))

        (it "falls back to the original path if it can't be resolved"
          (fn []
            (assert.equals "/foo/bar/fnl/conjure/fs.fnl-nope"
              (fs.resolve-relative-to
                "/foo/bar/fnl/conjure/fs.fnl-nope"
                (nvim.fn.getcwd)))))))

    (describe "apply-path-subs"
      (fn []
        (it "applies a simple mid-string replacement"
          (fn []
            (assert.equals "/home/olical/foo"
              (fs.apply-path-subs
                "/home/ollie/foo"
                {"ollie" "olical"}))))

        (it "does nothing when there are no matches"
          (fn []
            (assert.equals "/home/ollie/foo"
              (fs.apply-path-subs
                "/home/ollie/foo"
                {"^ollie" "olical"}))))

        (it "does nothing when path-subs is nil"
          (fn []
            (assert.equals "/home/ollie/foo"
              (fs.apply-path-subs
                "/home/ollie/foo"
                nil))))

        (it "applies a gsub capture group replacement"
          (fn []
            (assert.equals "/home/olical/foo"
              (fs.apply-path-subs
                "/home/ollie/foo"
                {"^(/home/)ollie" "%1olical"}))))))

    (describe "file-path->module-name"
      (fn []
        (local ex-mod "test.foo.bar")
        (local ex-file "/some-big/ol/path/test/foo/bar.fnl")
        (local ex-file2 "/some-big/ol/path/test/foo/bar/init.fnl")
        (local ex-no-file "/some-big/ol/path/test/foo/bar/no/init.fnl")

        (it "returns nil for a nil file path"
          (fn []
            (assert.equals nil (fs.file-path->module-name nil))))

        (it "returns the module name for a valid file path"
          (fn []
            (tset package.loaded ex-mod {:my :module})
            (assert.equals ex-mod (fs.file-path->module-name ex-file))
            (assert.equals ex-mod (fs.file-path->module-name ex-file2))
            (tset package.loaded ex-mod nil)))

        (it "returns nil for a non-existent file path"
          (fn []
            (assert.equals nil (fs.file-path->module-name ex-no-file))))))

    (describe "upwards-file-search"
      (fn []
        (it "returns nil when no match is found"
          (fn []
            (assert.equals nil (fs.upwards-file-search [] (nvim.fn.getcwd)))
            (assert.equals nil (fs.upwards-file-search ["thisbetternotexist"] (nvim.fn.getcwd)))))

        (it "finds a file in the current directory"
          (fn []
            (assert.equals (.. (nvim.fn.getcwd) "/README.adoc")
              (fs.upwards-file-search ["README.adoc"] (nvim.fn.getcwd)))))

        (it "walks upwards to find a file"
          (fn []
            (assert.equals (.. (nvim.fn.getcwd) "/README.adoc")
              (fs.upwards-file-search ["README.adoc"] (.. (nvim.fn.getcwd) "/fnl/conjure/client/clojure/nrepl")))))

        (it "returns early when matching below first"
          (fn []
            (assert.equals (.. (nvim.fn.getcwd) "/fnl/conjure-spec/.fs.test")
              (fs.upwards-file-search ["README.adoc" ".fs.test"] (.. (nvim.fn.getcwd) "/fnl/conjure-spec/client/clojure/nrepl")))))

        (it "returns early when matching at the same level first"
          (fn []
            (assert.equals (.. (nvim.fn.getcwd) "/fnl/conjure-spec/.fs.test")
              (fs.upwards-file-search ["README.adoc" ".fs.test"] (.. (nvim.fn.getcwd) "/fnl/conjure-spec")))))))

    (describe "resolve-above"
      (fn []
        (it "returns nil when no match is found"
          (fn []
            (assert.equals nil (fs.resolve-above []))
            (assert.equals nil (fs.resolve-above ["thisbetternotexist"]))))

        (it "finds a file in the current directory"
          (fn []
            (assert.equals (.. (nvim.fn.getcwd) "/README.adoc")
              (fs.resolve-above ["README.adoc"]))))))

    (describe "conjure-source-directory"
      (fn []
        (it "returns the current working directory"
          (fn []
            (assert.equals (.. (nvim.fn.getcwd) "/.test-config/nvim/pack/conjure-tests/start/conjure") fs.conjure-source-directory))))))
