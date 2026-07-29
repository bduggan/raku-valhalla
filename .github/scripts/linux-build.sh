#!/usr/bin/env bash
# Build the native shim on Linux, inside the official Valhalla container.
#
# The container has libvalhalla and its build dependencies; a bare GitHub runner
# has neither, and prime_server in particular isn't packaged in apt at all. So
# we build in the container and bundle the resulting shared libraries into
# resources/libraries, which the test steps put on LD_LIBRARY_PATH.
#
# Runs anywhere docker does, not just in CI: ./.github/scripts/linux-build.sh
#
# Env overrides: VALHALLA_VERSION (default: .github/valhalla-version).
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$repo_root"

VALHALLA_VERSION="${VALHALLA_VERSION:-$(cat .github/valhalla-version)}"
image="ghcr.io/valhalla/valhalla:$VALHALLA_VERSION"

echo "==> building against $image"

# Created out here so it belongs to the invoking user, not to root.
mkdir -p resources/libraries

docker run --rm \
    --volume "$repo_root:/w" \
    --workdir /w \
    "$image" \
    bash .github/scripts/linux-build-in-container.sh
