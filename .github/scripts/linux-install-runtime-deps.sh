#!/usr/bin/env bash
# Shared libraries the shim needs at run time, installed on the bare runner.
#
# Only the ones apt can supply. Everything else (prime_server, geos, spatialite,
# ...) is bundled out of the build container by linux-build-in-container.sh.
#
# NB: these names track the Ubuntu release (see the t64 ABI transition), so they
# will need revisiting whenever ubuntu-latest moves to a newer release.
set -euo pipefail

sudo apt-get -qq update
sudo apt-get install -qq -y --no-install-recommends \
    libcurl4 libprotobuf-lite32t64 libssl3 libzmq5 zlib1g
