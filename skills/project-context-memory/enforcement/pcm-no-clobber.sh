#!/bin/bash
# PreToolUse(Write): refuse to Write over an EXISTING append-only vault file.
# Creating a new file with Write is fine - that is how memory/ and index.md get made.
# Replacing one wholesale is how another session's appended work disappears.
set -uo pipefail
. "$(dirname "$0")/pcm-lib.sh"

input=$(cat)
f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || exit 0
[ -n "$f" ] || exit 0

pcm_is_vault_context_file "$f" || exit 0
pcm_is_append_only "$f" || exit 0
[ -f "$f" ] || exit 0   # new file: allow

lines=$(wc -l < "$f" 2>/dev/null | tr -d ' ')
pcm_deny \
"Write is blocked on this file - it already exists ($lines lines) and its history is append-only. A Write replaces the whole file, which silently destroys anything another session appended since you last read it. Use Edit with a unique anchor string instead. If you genuinely need to restructure it, say so and ask first." \
"Blocked a Write over an existing vault file ($(basename "$f")) - use Edit."
exit 0
