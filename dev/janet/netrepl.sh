#!/usr/bin/env bash

echo "Be sure to install the dependencies with 'jpm install spork' first."
janet -e "(import spork/netrepl) (netrepl/server)"
