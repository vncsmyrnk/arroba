#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

gpg_email="${1:-""}"
if [[ -z "$gpg_email" ]]; then
  echo "email is required." >&2
  exit 1
fi

if ! tmp=$(mktemp -d); then
  exit 1
fi
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

gpg --export-secret-keys --armor "$gpg_email" >"$tmp/${gpg_email}-private-key-backup.asc"
gpg --export --armor "$gpg_email" >"$tmp/${gpg_email}-public-key-backup.asc"
gpg --export-ownertrust >"$tmp/trust-backup.txt"

find "$tmp" -type f | rbackup generate --prefix "$gpg_email-gpg" --junk-paths -
