#!/usr/bin/env bash

CONJURE_DIR=/root/.local/share/nvim/site/pack/conjure/start/conjure

docker build . -t conjure
docker run \
    -v $(pwd):$CONJURE_DIR \
    -ti --rm conjure \
    nvim --cmd "cd $CONJURE_DIR" $@
