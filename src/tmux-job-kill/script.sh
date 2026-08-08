#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

session_name="$UTILITIES_TMUX_JOB_SESSION_NAME"

job_name="${1:-""}"
if [[ -z "$job_name" ]]; then
  echo "a job name is required." >&2
  exit 1
fi

if ! pane_id=$(tmux list-panes -t "$session_name":"$job_name" -F '#{pane_id}' 2>/dev/null); then
  echo "no running job found." >&2
  exit 1
fi

tmux send-keys -t "$pane_id" C-c
