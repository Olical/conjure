#!/usr/bin/env sh

# Read from stdin and replace paths with compile calls. 
cat "${1:-/dev/stdin}" | \
    sed "s#src/\(\w\+\)/\(\w\+\)\.clj#(compile \'\1.\2)#g"
