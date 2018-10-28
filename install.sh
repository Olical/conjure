#!/usr/bin/env sh
# Try install by
#   - download binary
#   - build with cargo

set -o nounset    # error when referencing undefined variable
set -o errexit    # exit when command fails

version=v0.1.0
name=conjure

try_curl() {
    command -v curl > /dev/null && \
        curl --fail --location "$1" --output target/release/$name
}

try_wget() {
    command -v wget > /dev/null && \
        wget --output-document=target/release/$name "$1"
}

download() {
    echo "Downloading target/release/${name}..."
    url=https://github.com/Olical/${name}/releases/download/$version/${1}
    if (try_curl "$url" || try_wget "$url"); then
        chmod a+x target/release/$name
        return
    else
        try_build || echo "Prebuilt binary might not be ready yet, try again later."
    fi
}

try_build() {
    if command -v cargo > /dev/null; then
        echo "Trying to build locally ..."
        cargo build --release
    else
        return 1
    fi
}

rm -f target/release/${name}

arch=$(uname -sm)
case "${arch}" in
    "Linux x86_64") download $name-$version-linux-x86_64 ;;
    *) echo "No pre-built binary available for ${arch}."; try_build ;;
esac
