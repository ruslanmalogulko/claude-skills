# Enforcement hooks

The skill states rules. These hooks make some of them binding.

Without them, everything in `SKILL.md` is advice the model may skip - and it does. While building this skill I broke its own re-read-before-write rule *while holding the skill*, and a baseline agent skipped durable memory entirely without noticing. Hooks are the only mechanism in Claude Code that executes regardless of what the model decides.

## What each hook does

| Script | Event | Behaviour |
|---|---|---|
| `pcm-remind.sh` | `UserPromptSubmit` | When the prompt names a ticket (`EEI-768`, `MAN-4042`, `PLA-832`), a PR (`#4347`, `PR 4347`), or says resume / continue / pick up / where we left off / checkpoint / distil, injects an instruction to load context first and print the four-line orientation block. Silent on everything else. Never blocks. |
| `pcm-no-clobber.sh` | `PreToolUse(Write)` | **Denies** `Write` over an **existing** plan, `memory/` file, `index.md`, or `PROJECTS.md`. A `Write` replaces the whole file and silently destroys anything another session appended. Creating a *new* file with `Write` is allowed - that is how `memory/` gets made. |
| `pcm-track-read.sh` | `PostToolUse(Read)` | Records each vault-file read with a timestamp, per session, under `$TMPDIR`. Feeds the next hook. Never blocks. |
| `pcm-require-fresh-read.sh` | `PreToolUse(Edit)` | **Denies** an `Edit` to an append-only vault file if it was never read this session, or if the last read is older than 300s. The Edit tool already requires *a* read; it does not require a *fresh* one, and staleness is the failure that loses other sessions' work. |

Only the two `PreToolUse` hooks block. The other two are additive.

## Install

Copy the scripts into your Claude config directory and merge the JSON below into `settings.json`.

```bash
# ~/.claude, or $CLAUDE_CONFIG_DIR if you set one
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks"
cp enforcement/pcm-*.sh "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/"
chmod +x "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/"pcm-*.sh
```

Merge into `settings.json` - **merge, do not replace**, or you will drop any hooks you already have:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_CONFIG_DIR/hooks/pcm-no-clobber.sh\"", "timeout": 15, "statusMessage": "Vault append-only guard" }]
      },
      {
        "matcher": "Edit",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_CONFIG_DIR/hooks/pcm-require-fresh-read.sh\"", "timeout": 15, "statusMessage": "Vault fresh-read guard" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Read",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_CONFIG_DIR/hooks/pcm-track-read.sh\"", "timeout": 15 }]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_CONFIG_DIR/hooks/pcm-remind.sh\"", "timeout": 15 }]
      }
    ]
  }
}
```

If you do not set `CLAUDE_CONFIG_DIR`, replace it with `$HOME/.claude` in those four commands - it is not defined by default.

Requires `bash`, `jq` and `python3`.

## You will need to adjust the path pattern

**These hooks are written for one vault layout** and will do nothing on a different one. `pcm-lib.sh` decides what counts as a protected file:

```bash
pcm_is_vault_context_file()   # matches */03-Projects/*/Context/*.md
pcm_is_append_only()          # narrows to plans/, memory/, index.md, PROJECTS.md
```

If your knowledge base does not live under `03-Projects/<product>/Context/`, edit those two functions. They are the only place paths are decided; nothing else needs touching.

## Verify it works

Do not trust the config - prove it fires. Pipe a payload straight into a script:

```bash
# should print a deny decision
printf '{"tool_input":{"file_path":"/some/vault/03-Projects/X/Context/y/plans/z.md"}}' \
  | ./pcm-no-clobber.sh
```

Then prove it in a session: create a throwaway file at a matching path, `Read` it, and try to `Write` over it. A live hook returns *"Write is blocked on this file"*. Use a throwaway path - if the hook is **not** live, the write goes through.

If the pipe test passes but the in-session test does not, the settings watcher has not reloaded. Open `/hooks` once, or restart.

## Tuning

- `PCM_READ_MAX_AGE` - staleness window in seconds, default `300`. Raise it if legitimate multi-edit passes get blocked; lower it if you want stricter freshness.

## What these cannot do

They enforce **mechanics**: invoke on the right signal, never clobber a shared file, never write from a stale read.

They cannot enforce **judgement**: whether the right findings were distilled, whether a source was classified correctly, whether a memory entry was scoped honestly. Nothing mechanical can check those. `../evals/evals.json` is the only check on them, which is why the eval suite ships with the skill.
