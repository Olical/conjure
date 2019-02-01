#!/usr/bin/env sh

mkdir -p bin

if [ "$1" == "prebuilt" ]; then
    echo "Fetching pre-built binaries isn't supported just yet"
elif [ "$1" == "debug" ]; then
    echo "Building Conjure in debug mode"
    cargo build && cp target/debug/conjure bin
else
    echo "Building Conjure in release mode (default)"
    cargo build --release && cp target/release/conjure bin
fi
