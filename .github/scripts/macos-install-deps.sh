#!/usr/bin/env bash
# Homebrew packages needed to build Valhalla and the native shim on macOS.
# Keep roughly in sync with the apt list in linux-build-in-container.sh.
set -euo pipefail

brew update

brew install \
    autoconf automake boost cmake curl czmq jq libspatialite libtool \
    luajit lz4 pkg-config protobuf protobuf-c spatialite-tools sqlite3 \
    unzip wget zmq
