#!/bin/bash
set -euo pipefail
GROUP() {
    echo "::group::${*}"
    set -x
}
ENDGROUP() {
    set +x
    echo "::endgroup::"
}
pv() {
    dd if="$1" bs=1M status=progress
}

cd work

GROUP "Download CoreOS image..."
bash ./steps/1-download-image.sh | tee download.log
ENDGROUP

GROUP "Extract downloaded CoreOS image..."
bash ./steps/2-extract-image.sh
ENDGROUP

GROUP "Install guestfish..."
sudo apt-get update && sudo apt-get install guestfish -y
ENDGROUP

GROUP "Convert CoreOS image..."
INFILExz="$(tail -1 ./download.log)"
INFILE="${INFILExz%.xz}"
OUTFILE="${INFILE//qemu/proxmox}"
VERSION="$(tail -1 ./download.log | sed -e 's/qemu/proxmox/' | cut -d- -f3)"
sudo chmod -R a+r /boot
export LIBGUESTFS_DEBUG=1 LIBGUESTFS_TRACE=1
bash "./steps/3-convert-image.sh" "${INFILE}" "${OUTFILE}" proxmox
ENDGROUP

GROUP "Compress converted CoreOS image..."
pv "${OUTFILE}" | xz -z --fast --stdout > "${OUTFILE}.xz"
ENDGROUP

GROUP "Record metadata..."
set +u # Just in case we're not running in GHA, don't exit on unset var
{
echo "outfile=${OUTFILE}.xz"
echo "version=${VERSION}"
echo "tag=${VERSION}.$(date -I)"
} | tee -a "$GITHUB_OUTPUT"
set -u
ENDGROUP