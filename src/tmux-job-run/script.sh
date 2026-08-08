#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

session_name="$UTILITIES_TMUX_JOB_SESSION_NAME"

job_name="$1"
if [[ -z "$job_name" ]]; then
  echo "a job name is required." >&2
  exit 1
fi

job_path="$CONFIG_PATH/$job_name"
if [[ ! -x "$job_path" ]]; then
  echo "file not executable." >&2
  exit 1
fi

if ! job_content=$(cat "$job_path"); then
  echo "failed to read job file." >&2
  exit 1
fi

if tmux list-panes -t "$session_name":"$job_name" >/dev/null 2>&1; then
  echo "job already running." >&2
  exit 1
fi

if ! tmux list-windows -t "$session_name" >/dev/null 2>&1; then
  tmux new-session -d -s "$session_name" -n "$job_name" "$job_content"
  exit 0
fi

tmux new-window -t "$session_name" -n "$job_name" "$job_content"
