#!/bin/bash
# UserPromptSubmit: when the prompt names a ticket, PR or resume/checkpoint intent,
# tell Claude to load persistent project context before doing anything else.
# Injects context only - never blocks.
set -uo pipefail

input=$(cat)
prompt=$(printf '%s' "$input" | jq -r '.prompt // ""' 2>/dev/null) || exit 0
[ -n "$prompt" ] || exit 0

# Ticket ids (EEI-768, MAN-4042, PLA-832, CW-12), PR refs (#4347, PR-4347, "PR 4347"),
# or explicit continuity language.
if printf '%s' "$prompt" | grep -qEi '(\b(EEI|MAN|PLA|CW|KS)-[0-9]+\b)|(\bPR[ -]?#?[0-9]{3,}\b)|(#[0-9]{3,}\b)|\b(resume|continue|pick up|where (did |we )?left off|checkpoint|distil|distill)\b'; then
  python3 <<'PY'
import json
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": (
      "This prompt names a ticket, PR, or continuity intent. Before substantial work, "
      "invoke the `project-context-memory` skill to locate the context package and load "
      "the smallest sufficient context, and print its four-line orientation block "
      "(Context / Plan / Also loaded / Ambiguity). Never read a vault plan whole - grep its "
      "headings, then read the state block and the newest dated pass. If this is a trivial "
      "edit with no relevant project context, say so in one line and skip the skill."
    ),
  }
}))
PY
fi
exit 0
