# claude-skills

Personal [Claude Code](https://claude.com/claude-code) skills.

## Skills

| Skill | What it is for |
|---|---|
| [`project-context-memory`](skills/project-context-memory) | Persistent project-context discovery and maintenance for long-running implementation work: find the right context package in a knowledge vault, load the least of it that answers the question, and promote only verified durable knowledge back into shared project memory. Designed as a companion to [Superpowers](https://github.com/obra/superpowers), not a replacement for any of it. |

## Install

Skills are directories containing a `SKILL.md`. Drop one into your personal skills directory and Claude Code picks it up:

```bash
# default location
git clone https://github.com/ruslanmalogulko/claude-skills.git
cp -R claude-skills/skills/project-context-memory ~/.claude/skills/

# or symlink, so a git pull updates the skill in place
ln -s "$PWD/claude-skills/skills/project-context-memory" ~/.claude/skills/project-context-memory
```

If you run Claude Code with a custom `CLAUDE_CONFIG_DIR`, use `$CLAUDE_CONFIG_DIR/skills/` instead of `~/.claude/skills/`.

Confirm it registered by asking Claude to list its available skills.

## How these are built

Each skill is developed with the TDD-for-documentation loop from Superpowers' `writing-skills`:

1. **RED** - run the target scenarios with fresh subagents and **no** skill, and record what they actually do, verbatim.
2. **GREEN** - write the skill against the specific failures observed, not against imagined ones.
3. **REFACTOR** - re-run the same scenarios with the skill, close whatever loopholes the agents find, repeat.

Each skill ships its scenarios in `evals/evals.json`: trigger cases that probe the frontmatter description for false positives and false negatives, plus behaviour scenarios with explicit `must_do` and `must_not_do` lists.

Guidance is only included when a baseline agent actually got it wrong. Several rules that seemed obviously necessary were dropped because the unguided baseline already handled them, and one rule exists purely to stop the skill firing on work it should ignore.

## Licence

MIT
