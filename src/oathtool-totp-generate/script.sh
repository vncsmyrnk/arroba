#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

entity="${1:-""}"
if [[ -z "$entity" ]]; then
  echo "entity argument is required." >&2
  exit 1
fi

secret_file="$CONFIG_PATH/$entity.gpg"
if [[ ! -f "$secret_file" ]]; then
  echo "secret not found for entity." >&2
  exit 1
fi

totp_key=$(
  gpg -d -q "$secret_file"
)

totp_code=$(
  oathtool --totp -b --now "5 seconds" - <<<"$totp_key"
)

echo -n "$totp_code" | wl-copy --type text/plain
echo "successfully copied to clipbloard."
