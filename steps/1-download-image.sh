#!/bin/bash
set -euxo pipefail
arch="x86_64" # or aarch64
# podman run --security-opt label=disable --pull=always --rm -v .:/data -w /data \
#     quay.io/coreos/coreos-installer:release download -s stable -p qemu -f qcwo2 -a "${arch}"
docker run --rm -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release download -s stable -p qemu -f qcow2.xz -a "${arch}"
