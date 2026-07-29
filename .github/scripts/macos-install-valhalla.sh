#!/usr/bin/env bash
# Build Valhalla from source and install it under $VALHALLA_PREFIX.
#
# There is no Homebrew formula for Valhalla, so macOS has to build it. That
# takes tens of minutes, hence the CI cache — whose key includes a hash of this
# file, so editing the flags below correctly invalidates it.
#
# Everything Raku has no use for is switched off, to keep the build short.
#
# Env overrides: VALHALLA_VERSION (default: .github/valhalla-version),
#                VALHALLA_PREFIX  (default: /usr/local/valhalla).
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

VALHALLA_VERSION="${VALHALLA_VERSION:-$(cat "$repo_root/.github/valhalla-version")}"
VALHALLA_PREFIX="${VALHALLA_PREFIX:-/usr/local/valhalla}"

# Built outside the repo so a stale checkout can't end up in a dist tarball.
src=$(mktemp -d)
trap 'rm -rf "$src"' EXIT

echo "==> cloning valhalla $VALHALLA_VERSION"
git clone --recurse-submodules --branch "$VALHALLA_VERSION" --depth 1 \
    https://github.com/valhalla/valhalla.git "$src"

cmake -B "$src/build" -S "$src" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$VALHALLA_PREFIX" \
    -DCMAKE_CXX_FLAGS=-Wno-error=deprecated-declarations \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_TESTS=OFF \
    -DENABLE_BENCHMARKS=OFF \
    -DENABLE_PYTHON_BINDINGS=OFF \
    -DENABLE_SERVICES=OFF \
    -DENABLE_TOOLS=OFF \
    -DENABLE_HTTP=OFF

make -C "$src/build" -j"$(sysctl -n hw.physicalcpu)"
sudo make -C "$src/build" install

echo "==> installed valhalla $VALHALLA_VERSION to $VALHALLA_PREFIX"
