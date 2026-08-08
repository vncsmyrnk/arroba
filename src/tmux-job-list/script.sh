#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

session_name="$UTILITIES_TMUX_JOB_SESSION_NAME"

jobs=$(
  tmux list-windows -t "$session_name" -F "#{window_name}" 2>/dev/null ||
    echo ""
)

for f in "$CONFIG_PATH"/*; do
  job_name=$(basename "$f")
  running=false
  if grep -qE "^$job_name$" <<<"$jobs"; then
    running=true
  fi
  rows+="$job_name $running"$'\n'
done

if [[ -z "$rows" ]]; then
  echo "no jobs found." >&2
  exit 1
fi

column -t -N 'NAME,RUNNING' <<<"$rows"
