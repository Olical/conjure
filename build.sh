#!/usr/bin/env sh

clojure --main cljs.main --compile-opts cljsc_opts.edn --compile conjure.main
