#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

src="$DATA_PATH/$1.img"
if [[ ! -f "$src" ]]; then
  echo "container file not found." >&2
  exit 1
fi

config=$(cat "$CONFIG_PATH/$1.json" 2>/dev/null || echo '{}')
if ! target=$(jq -cre '.mountpoint' <<<"$config" 2>/dev/null); then
  target=$(mktemp -d -t utilities-cryptsetup.XXXXX)
else
  target=$(envsubst <<<"$target")
fi

target_name="$UTILITIES_CRYPTSETUP_PREFIX$1"
if ! cryptsetup open "$src" "$target_name"; then
  exit 1
fi

mkdir -p "$target"
mapper="$MAPPER_PATH/$target_name"

if ! mount "$mapper" "$target"; then
  cryptsetup close "$target_name"
  exit 1
fi
