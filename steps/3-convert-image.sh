#!/bin/bash

set -euxo pipefail

if [[ ${#} -ne 3 ]]; then
    echo "Usage: <source image> <dest image> <platform>"
    echo ""
    echo "Example:"
    echo "./$(basename "${0}") fedora-coreos-40.20240616.3.0-{qemu,proxmox}.x86_64.qcow2 proxmox"
    exit 1
fi

source="${1}"
dest="${2}"
platform="${3}"

if [[ ! -f "${source}" ]]; then
    echo "Source image ${source} does not exists"
    exit 1
fi

if [[ -f "${dest}" ]]; then
    echo "Destination image ${dest} already exists"
    exit 1
fi

if [[ -z "$(command -v guestfish)" ]]; then
    echo "Could not find 'guestfish' command"
    exit 1
fi

cp --reflink=auto "${source}" "${dest}"
guestfish -a "${dest}" <<EOF
run
mount /dev/sda3 /
download /loader/entries/ostree-1.conf tmp.loader.entries.ostree-1.conf
<! sed -i "s/ignition.platform.id=qemu/ignition.platform.id=${platform}/" tmp.loader.entries.ostree-1.conf
upload tmp.loader.entries.ostree-1.conf /loader/entries/ostree-1.conf
EOF

rm -v ./tmp.loader.entries.ostree-1.conf

echo "Done"
