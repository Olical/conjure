(module conjure.client.fennel.aniseed-test
  {require {ani conjure.client.fennel.aniseed}})

(def ex-mod "test.foo.bar")
(def ex-file "/some-big/ol/path/test/foo/bar.fnl")
(def ex-file2 "/some-big/ol/path/test/foo/bar/init.fnl")
(def ex-no-file "/some-big/ol/path/test/foo/bar/no/init.fnl")

(deftest module-name
  (tset package.loaded ex-mod {:my :module})

  (t.= ani.default-module-name (ani.module-name nil nil))
  (t.= ex-mod (ani.module-name ex-mod ex-file))
  (t.= ex-mod (ani.module-name nil ex-file))
  (t.= ex-mod (ani.module-name nil ex-file2))
  (t.= ani.default-module-name (ani.module-name nil ex-no-file))

  (tset package.loaded ex-mod nil))
