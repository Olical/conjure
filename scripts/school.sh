#!/usr/bin/env bash

PREFIX="/tmp/conjure-school"

if [[ ! -d $PREFIX ]]; then
  echo "Downloading Conjure into $PREFIX..."
  curl -LJ https://github.com/Olical/conjure/archive/develop.zip -o $PREFIX.zip
  unzip $PREFIX.zip -d $PREFIX
  rm $PREFIX.zip
else
  echo "$PREFIX already exists, no need to download."
fi

nvim --cmd "set rtp+=$PREFIX/conjure-develop" +ConjureSchool \
  && echo "I hope you had a great time! Cleaning up $PREFIX and exiting." \
  && rm -rf $PREFIX
