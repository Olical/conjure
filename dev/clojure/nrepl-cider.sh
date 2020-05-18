#!/usr/bin/env bash

clj -A:nrepl:cider \
    -m nrepl.cmdline \
    --middleware "[cider.nrepl/cider-middleware]" \
    --interactive
