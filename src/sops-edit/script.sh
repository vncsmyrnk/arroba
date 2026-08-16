#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

PATH="${CURRENT_PATH:-"$PATH"}" sops "$CONFIG_PATH/default.env"
