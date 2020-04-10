#!/usr/bin/env bash

mkdir -p deps
if [ ! -d "deps/$2" ]; then git clone "https://github.com/$1/$2.git" "deps/$2"; fi
cd "deps/$2" && git fetch && git checkout "$3"

