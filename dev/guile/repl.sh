#!/usr/bin/env bash

set -xe

SOCKET=$(git rev-parse --show-toplevel)/dev/guile/guile-repl.socket
if [[ -f $SOCKET ]]; then rm $SOCKET; fi
guile --listen=$SOCKET
rm $SOCKET
