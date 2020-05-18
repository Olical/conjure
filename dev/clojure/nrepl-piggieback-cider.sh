#!/usr/bin/env bash

clj -A:nrepl:cljs:cider:piggieback \
    -m nrepl.cmdline \
    --middleware "[cider.nrepl/cider-middleware cider.piggieback/wrap-cljs-repl]" \
    --interactive
