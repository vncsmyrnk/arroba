#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

session_name="$UTILITIES_TMUX_JOB_SESSION_NAME"

if ! pane_ids=$(tmux list-panes -s -t "$session_name" -F '#{pane_id}' 2>/dev/null); then
  echo "no running jobs." >&2
  exit 1
fi

xargs -I{} tmux send-keys -t {} C-c <<<"$pane_ids"
