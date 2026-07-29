#!/usr/bin/env bash
# Runs INSIDE ghcr.io/valhalla/valhalla, invoked by linux-build.sh.
#
# Installs the -dev packages make-lib probes for, builds the shim against the
# static libvalhalla.a, then copies the shim's shared-library dependencies next
# to it so the bare runner can load them.
set -euo pipefail

# Keep roughly in sync with the brew list in macos-install-deps.sh.
apt-get -qq update
DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends \
    clang pkg-config \
    libboost-dev libcurl4-openssl-dev libczmq-dev libgeos-dev libgeotiff-dev \
    libluajit-5.1-dev liblz4-dev libproj-dev libprotobuf-dev libspatialite-dev \
    libsqlite3-dev libssl-dev libtiff-dev libzmq3-dev zlib1g-dev

# VALHALLA_USE_STATIC bakes libvalhalla.a into the shim, so libvalhalla itself
# is not needed at runtime on the test machine.
CXX=clang++ VALHALLA_USE_STATIC=1 ./make-lib

shim=resources/libraries/libvalhalla_c.so

# Bundle the shim's remaining shared dependencies beside it. The glibc/loader
# core is deliberately excluded: it has to come from the runner, to match the
# runner's kernel.
while read -r so; do
    case "$so" in
        */ld-linux*|*/libc.so.*|*/libm.so.*|*/libdl.so.*|*/libpthread.so.*|*/librt.so.*|*/libresolv.so.*)
            continue ;;
    esac
    cp -n "$so" resources/libraries/
done < <(ldd "$shim" | sed -n 's/.*=> \(\/[^ ]*\).*/\1/p')

echo "==> bundled:"
ls -1 resources/libraries/

# Hand the artifacts back to whoever owns the mounted repo, not to root.
chown -R "$(stat -c '%u:%g' .)" resources/libraries
