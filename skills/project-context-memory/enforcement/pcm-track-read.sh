#!/bin/bash
# PostToolUse(Read): record when a vault context file was read, per session.
# Feeds pcm-require-fresh-read.sh. Never blocks.
set -uo pipefail
. "$(dirname "$0")/pcm-lib.sh"

input=$(cat)
f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || exit 0
sid=$(printf '%s' "$input" | jq -r '.session_id // "nosession"' 2>/dev/null) || sid=nosession
[ -n "$f" ] || exit 0
pcm_is_vault_context_file "$f" || exit 0

store=$(pcm_reads_file "$sid")
printf '%s\t%s\n' "$(date +%s)" "$f" >> "$store" 2>/dev/null || true
exit 0
