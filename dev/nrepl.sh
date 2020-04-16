#!/usr/bin/env bash

clj -m nrepl.cmdline --middleware "[cider.nrepl/cider-middleware cider.piggieback/wrap-cljs-repl]" --interactive
