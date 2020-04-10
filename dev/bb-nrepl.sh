#!/usr/bin/env bash

echo "5678" > .nrepl-port
bb --nrepl-server 5678
