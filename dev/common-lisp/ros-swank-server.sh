#!/usr/bin/env bash

ros run --eval '(ql:quickload :swank)' --eval '(swank:create-server :dont-close t)'
