#!/usr/bin/env bash

clojure \
    -A:nrepl:cider \
    -m nrepl.cmdline \
    --middleware "[cider.nrepl/cider-middleware]" \
    --interactive
