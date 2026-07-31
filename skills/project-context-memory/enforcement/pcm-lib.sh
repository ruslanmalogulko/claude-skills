#!/bin/bash
# Shared helpers for the project-context-memory enforcement hooks.
# A vault context file is any markdown under <vault>/03-Projects/<product>/Context/.

pcm_is_vault_context_file() {
  case "$1" in
    *"/03-Projects/"*"/Context/"*.md) return 0 ;;
    *) return 1 ;;
  esac
}

# Files whose history is append-only and shared across sessions.
pcm_is_append_only() {
  case "$1" in
    *"/Context/"*"/plans/"*.md) return 0 ;;
    *"/Context/"*"/memory/"*.md) return 0 ;;
    *"/Context/"*"/index.md") return 0 ;;
    *"/Context/PROJECTS.md") return 0 ;;
    *) return 1 ;;
  esac
}

pcm_reads_file() {
  local sid="${1:-nosession}"
  printf '%s' "${TMPDIR:-/tmp}/claude-pcm-reads-${sid//[^A-Za-z0-9_-]/_}"
}

pcm_deny() {
  # $1 = reason shown to the model, $2 = one-line message shown to the user
  python3 - "$1" "$2" <<'PY'
import json, sys
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": sys.argv[1],
    },
    "systemMessage": sys.argv[2],
}))
PY
}
