#!/usr/bin/env bash

git clone https://git.sr.ht/~abcdw/guile-ares-rs
cd guile-ares-rs || exit
make ares-rs
