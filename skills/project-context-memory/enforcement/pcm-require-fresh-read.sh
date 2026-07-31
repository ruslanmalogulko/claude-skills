#!/bin/bash
# PreToolUse(Edit): refuse to edit an append-only vault file unless it was read RECENTLY.
#
# The Edit tool already requires a read at some point in the session. What it does not
# catch is a read that has gone stale: another session can append in the minutes you
# spend verifying things, and an edit written from the stale read reasons about a file
# that no longer exists in that form. This enforces the freshness the skill asks for.
set -uo pipefail
. "$(dirname "$0")/pcm-lib.sh"

MAX_AGE=${PCM_READ_MAX_AGE:-300}   # seconds

input=$(cat)
f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || exit 0
sid=$(printf '%s' "$input" | jq -r '.session_id // "nosession"' 2>/dev/null) || sid=nosession
[ -n "$f" ] || exit 0

pcm_is_vault_context_file "$f" || exit 0
pcm_is_append_only "$f" || exit 0

store=$(pcm_reads_file "$sid")
last=0
if [ -f "$store" ]; then
  last=$(awk -F'\t' -v target="$f" '$2 == target { t = $1 } END { print t + 0 }' "$store")
fi

now=$(date +%s)
if [ "$last" -eq 0 ]; then
  pcm_deny \
"Edit blocked: you have not read $(basename "$f") in this session. It is a shared append-only file - read it first, then edit against a unique anchor." \
"Blocked an Edit to $(basename "$f") - read it first."
  exit 0
fi

age=$((now - last))
if [ "$age" -gt "$MAX_AGE" ]; then
  pcm_deny \
"Edit blocked: your last read of $(basename "$f") was ${age}s ago (limit ${MAX_AGE}s). Another session may have appended since. Re-read it now, reconcile if it changed - defer to whichever account verified more and do not duplicate a finding already logged - then edit against a unique anchor." \
"Stale read (${age}s) on $(basename "$f") - re-read before writing."
  exit 0
fi
exit 0
