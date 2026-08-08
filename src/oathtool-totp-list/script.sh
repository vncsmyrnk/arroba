#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

for f in "$CONFIG_PATH"/*; do
  basename "$f" | rev | cut -f2 -d "." | rev
done
