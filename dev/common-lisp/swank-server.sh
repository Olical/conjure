#!/usr/bin/env bash


sbcl --eval "(ql:quickload :swank)" --eval "(swank:create-server :dont-close t)"
