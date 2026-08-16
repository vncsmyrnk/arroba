#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

stow() {
  if output=$(command stow "$@" 2>&1); then
    return
  fi
  mapfile conflicting_files -t < <(grep -oP '[ ]+\* cannot stow \K.+(?= over existing target .+ since neither a link nor a directory and --adopt not specified)' <<<"$output")
  if [[ -z "${conflicting_files[*]}" ]]; then
    echo "$output"
    return 1
  fi
  conflicting_files=("${conflicting_files[@]#*/}")
  printf "%s" "${conflicting_files[@]}"
  return 1
}

src=
while [[ $# -gt 0 ]]; do
  case $1 in
  -D | --delete)
    stow_flags+=("-D")
    shift
    ;;
  --)
    shift
    break
    ;;
  *)
    if [[ -n "$src" ]]; then
      echo "invalid extra argument." >&2
      exit 1
    fi
    src="$1"
    shift
    ;;
  esac
done

config=$(cat "$CONFIG_PATH/$src.json" 2>/dev/null || echo '{}')
if ! stow_target=$(jq -cre '.stow' <<<"$config" 2>/dev/null || echo "$HOME"); then
  exit 1
fi
stow_target=$(envsubst <<<"$stow_target")

target_name="$UTILITIES_CRYPTSETUP_PREFIX$src"
if ! mountpoint=$(
  lsblk -Q "NAME=='$target_name'" -n -o MOUNTPOINT
); then
  exit 1
fi

_stow+=(
  'stow' "${stow_flags[@]}" '-d' "$mountpoint"
  '-t' "$stow_target" '.'
)
if ! conflicts=$("${_stow[@]}" 2>&1); then
  tmp=$(mktemp -d -t utilities-cryptsetup-stow-conflicting.XXXX)
  while read -r conflict; do
    mv -i "$stow_target/$conflict" "$tmp"
  done <<<"$conflicts"
  echo "conflicting files moved to $tmp." >&2
  "${_stow[@]}"
fi
