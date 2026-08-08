#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

src="$DATA_PATH/$1.img"
if [[ ! -f "$src" ]]; then
  echo "container file not found." >&2
  exit 1
fi

loop_device=$(losetup -j "$src" -O NAME -n)
if [[ -z "$loop_device" ]]; then
  echo "device not mounted" >&2
  exit 1
fi

if ! mountpoint=$(
  lsblk "$loop_device" -Q 'MOUNTPOINT' -np -o MOUNTPOINT
); then
  exit 1
fi

if fuser -s -m "$mountpoint"; then
  fuser -v -m "$mountpoint"
  read -r -p "kill and procceed? (y/N) " answer
  if [[ ! "$answer" =~ ^([Yy])$ ]]; then
    exit 1
  fi
  fuser -s -m "$mountpoint" -k
fi

if ! umount "$mountpoint"; then
  exit 1
fi

target_name="$UTILITIES_CRYPTSETUP_PREFIX$1"
if ! cryptsetup close "$target_name"; then
  exit 1
fi

rm -rf "$mountpoint"
