#!/usr/bin/env sh

# TODO Is there a better / shorter way to do this?
racket -e "(require (submod ogion main))" -- --debug
