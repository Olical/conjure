#!/usr/bin/env bash

docker build . -t conjure
docker run -ti --rm conjure
