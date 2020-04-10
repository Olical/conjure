#!/usr/bin/env bash

clj -m nrepl.cmdline --middleware "[cider.piggieback/wrap-cljs-repl]" --interactive
