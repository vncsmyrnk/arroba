#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

_sops="$(command -v sops)"
sops() {
  PATH="${CURRENT_PATH:-"$PATH"}" "$_sops" "$@"
}

sops "$CONFIG_PATH/default.env"
