#!/usr/bin/env bash

sbcl --eval "(ql:quickload :slynk)" --eval "(slynk:create-server :dont-close t)"
