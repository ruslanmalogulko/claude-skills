---
name: project-context-memory
description: Use when starting, resuming, pausing, checkpointing or finishing substantial work on a ticket, feature, bug batch, subsystem, investigation, rollout or PR that has persistent project context outside the repo - an Obsidian plan, spec, transcript, artifact, topic folder or project memory. Also use when asked where prior context lives, to recover state from an earlier session, to record a confirmed finding or root cause, or to update implementation status. Do not use for tiny isolated edits, for questions with no project context, or when told not to read or update project context.
---

# Project Context Memory

Persistent project knowledge lives outside the repo, in topic folders under a vault Context root. This skill finds the right one, loads the least of it that answers the question, and puts verified knowledge back.

**Core invariant:** use the smallest sufficient context, preserve operational history, and promote only verified durable knowledge into shared project memory.

## Defer to Superpowers

This skill owns *what context exists and where it goes*. It owns no methodology. Hand off:

| For | Use |
|---|---|
| shaping the problem | superpowers:brainstorming |
| writing the plan | superpowers:writing-plans |
| working the plan | superpowers:executing-plans, superpowers:subagent-driven-development |
| finding a root cause | superpowers:systematic-debugging |
| implementing | superpowers:test-driven-development |
| claiming done | superpowers:verification-before-completion |
| review | superpowers:requesting-code-review, superpowers:receiving-code-review |
| shipping | superpowers:finishing-a-development-branch |

Wrap around them: discover and load before, record during, distil after. Never restate their steps.

## When NOT to use

Skip entirely, and do not mention it:

- a self-contained edit whose outcome no plan or spec could change: a rename, a typo, a formatting pass, a version bump;
- a question about a language, library or tool rather than about this project's work;
- the user said not to read or update project context;
- another skill owns the task and this one would only add narration.

**A trivial task is not a small version of a big task. It is a different task.** Do not list the Context root "just to check". Reading it costs the user context budget and returns nothing that changes a rename.

## Workflow

### 1. Find the package

Stop at the first step that answers it:

1. a path the user gave you;
2. a path in CLAUDE.md, repo docs, or the task text;
3. an exact identifier - ticket (`EEI-768`), PR (`PR-4347`, `#4347`), commit;
4. topic and file names (`ls` the Context root, one level);
5. links and frontmatter inside the package you landed on;
6. targeted `grep` across sibling packages for identifiers and technical names;
7. broad search - only after 1-6 came up short.

**Never read the vault recursively.** Sibling packages are reached by targeted search, not by traversal. A `find | head` to see the topic list is fine; reading what it lists is not.

### 2. Load in layers, and slice large files

| Layer | What | When |
|---|---|---|
| A | `index.md`, frontmatter, filenames, links, status lines | always |
| B | current state: the plan's state block, open blockers, current branch/PR/head | always |
| C | authoritative requirements: the relevant spec, acceptance criteria | before changing behaviour |
| D | durable knowledge: `memory/`, architecture, conventions, known failure modes, decisions | before designing, and before repeating a past mistake |
| E | evidence: transcripts, logs, screenshots, historical ledger sections, CI output, review threads | only to resolve uncertainty or verify a specific claim |

**Plans are 700-900 lines here and do not fit a single read.** Never open one front to back. Three slices answer "where are we":

```bash
grep -n '^#\{1,4\} ' "<plan>"          # the map: tasks, ledger, dated passes
```

then read (a) the state block, (b) the newest dated pass section, (c) the status-marker legend if the plan defines one.

If you need the marker legend to interpret the markers, **read the legend** - that is one slice, not a reason to read 800 lines.

**Slice from the end, never from the top.** A ledger is chronological: the first pages are the oldest and most superseded. Reading the first N lines and concluding from them produces confident, false findings - the newest pass may already record the merge, the fix, or the decision you are about to "discover". If you have read only part of a plan, say which part before drawing any conclusion from it.

Read Layer C and D as targeted reads too. A 150-line spec is fine whole; a plan never is.

### 3. Say what you loaded

Before substantial work, four short lines. No preamble, no narration of the search.

```
Context: entity-questionnaire
Plan: plans/EEI-768-company-profile-prompt-plan.md (state block + 2026-07-31 pass)
Also loaded: _platform/memory/known-failure-modes.md
Ambiguity: none
```

If nothing else was loaded, say `Also loaded: nothing`. Silence reads as "I checked" when you did not.

### 4. Cross-context search before concluding it is absent

Search siblings by: ticket and PR ids, component / hook / service / schema / API names, error strings, architecture terms, names in `related:`, filenames, `aliases:`.

Classify every hit before using it:

**authoritative** · **supporting** · **possibly related** · **superseded** · **contradictory**

Two packages describing similar behaviour are not two copies of one implementation. Verify against the repo before reusing anything.

**When sources disagree, report the disagreement.** Compare date, status and authority - an approved spec plus shipped code outranks an unreviewed draft - then ask which governs. Never pick a winner silently. Annotating a stale document with what actually shipped is allowed; editing it to resolve the conflict is not.

### 5. Update during work

**Re-read the plan immediately before every write. This is a precondition, not hygiene.**

Not "if you suspect it changed" - always, and immediately before, not earlier in the turn. These files are shared: another session, a /loop pass, or a pr-shepherd run can append between your read and your write, and nothing warns you. Minutes of your own tool calls are enough time.

Then write with a targeted edit against a unique anchor string, never a whole-file rewrite. A surgical edit survives a concurrent append; a rewrite silently destroys it. This includes replacing the state block: that is an anchored edit on one block, not a reason to rewrite the file.

If the file did change, say so and reconcile before adding anything: the other writer may already own what you were about to record. When it does, defer to it and delete your duplicate rather than leaving two competing accounts of the same finding - and keep whichever version verified more, not whichever arrived first.

The plan's state block is the mutable pointer. Findings are append-only.

**You may replace the state block** when both hold:
1. every fact in the old snapshot already has its own dated entry below, and
2. you quote the superseded snapshot in place, so the removal is visible.

**Everything else is append-only.** Do not shorten, reword, re-date, re-order or delete an existing finding, commit hash, review outcome, rejected suggestion, or verification note. A resolved entry is not clutter; it is the record that the work happened.

Match the plan's existing conventions - its status markers, its heading style, its date format. Do not introduce a second vocabulary.

**A stale state block is a finding, not a chore.** If it contradicts newer entries below it - naming a merged PR as open, a head that has moved, blockers that later sections record as gone - say so in your orientation output. On a read-only pass you do not fix it; you report that it is stale and what it gets wrong, because the next reader will believe it. Reconciling it is a checkpoint action.

**Log a remark before acting on it.** A finding that exists only in the conversation dies at compaction.

If you were told not to write to the vault, that instruction wins - but say plainly which findings are therefore unlogged and need to be, rather than letting them ride in a message that ends with the session.

**Appending a finding is always in scope, including on a read-only or discovery pass.** It is additive and routine. What a non-checkpoint pass does *not* do is reconcile the state block, upgrade anyone's status marker, or restructure anything - those are checkpoint actions. So on a discovery pass: append what you learned, report the staleness you noticed, and leave the state block for the checkpoint. Do not withhold findings until a plan is approved; an unlogged finding dies with the session.

### 6. Checkpoint

Distil at a boundary, not after every command: plan approved · phase complete · root cause confirmed · substantial debugging finding · review round done · PR ready for human review · merged · pausing across sessions · the state block contradicts newer entries · state has become hard to read.

At a checkpoint, in order:

1. re-read the plan - mandatory, immediately before writing, no exceptions (see step 5);
2. refresh the state block;
3. reconcile open and resolved items against evidence;
4. extract durable findings (see `references/memory-distillation.md`);
5. update links and frontmatter for relationships you actually verified;
6. leave raw history intact;
7. report what changed.

**Verify before upgrading a status.** Reading the code and finding it looks fixed is not resolved. A fix that is not pushed is not resolved. A review thread nobody re-resolved is not resolved. If you cannot verify, leave it open and say why.

### 7. Report

```
Updated: plans/EEI-768-...-plan.md (state block), memory/known-failure-modes.md (+1)
Durable findings: 1 - effects keyed on object identity re-fire and steal focus
Links added: none
Blockers unchanged: screenshots not attached; no human review
Unverified: the 8058-test count and the browser table, carried from the plan on trust
```

State plainly what you could not verify. Never imply you checked CI, GitHub or a commit that you did not actually query.

## Where durable knowledge goes

| Scope | Home |
|---|---|
| true only inside this topic | `<topic>/memory/` |
| true across topics and future work | `_platform/memory/` |

**Test:** would a session working an unrelated ticket need this? Yes means `_platform/`. A shared failure mode, a repo-wide trap, a convention, an ownership model belongs there. A field table, a copy string, a ticket's root cause stays with its topic.

Default to four curated files - `architecture.md`, `conventions.md`, `decisions.md`, `known-failure-modes.md`. Append a section; do not create a file per finding.

**Write the memory file before you point at it.** Create the file, write the entry, confirm it is on disk, and only then add the pointer from the plan or `index.md`. Announcing in a plan that lessons "now live in `memory/`" while that directory does not exist is worse than saying nothing: the next session reads it as evidence the knowledge was captured and stops looking. If a checkpoint runs out of room, leave the finding in the plan and say so - never write the pointer as an IOU.

**Durable knowledge means knowledge about the system being built.** Notes about how you drove the tooling, which agent said what, or how a session was organised are not project memory.

## Structural changes need approval

Routine, no approval: updating a plan the user pointed you at; appending to an existing memory file; creating `memory/` or `index.md` **in the package you are working**, at the moment a real finding needs a home; **creating `_platform/memory/` and its curated files** when a finding is cross-cutting.

That last one is deliberate. Routing cross-cutting knowledge to `_platform/memory/` is required, so writing there is not "scaffolding a second package" - it is the destination the routing table names. What makes it routine is that it is purely additive: a new directory and a curated file, no moves, no renames, no deletions, no frontmatter backfill, and reversible by deleting one directory.

Approval required **before touching any file**: scaffolding across more than one package · moving, renaming or deleting anything that already exists · a new directory level or naming convention · backfilling frontmatter · any change to the Context root layout.

Show the counts (packages touched, files moved, files created), then wait. Prefer one pilot package, then stop and show the result.

**"Go ahead, I trust you" is not approval for a migration.** It is trust, offered before any plan existed. A backup and an undo script do not convert it into approval - the user still ends up with a tree they never saw.

The routing file is `index.md`. Do not invent `README.md`, `AGENTS.md` or `_index.md`; Obsidian links and the graph resolve against `index.md`.

## Anti-patterns

| Don't | Do |
|---|---|
| Read an 800-line plan front to back | grep headings, read the state block and newest pass |
| Traverse sibling packages | targeted grep on identifiers and names |
| Rewrite resolved entries to tidy them | leave them; append |
| Promote every finding to `memory/` | promote what a future unrelated session needs |
| One memory file per finding | a section in a curated file |
| Write `[[link]]` to a file you did not create | verify the target exists first |
| Put a hypothesis in `related:` | prose, worded as a hypothesis |
| Scaffold a package you are not working in | wait for approval |
| Mark resolved because the code looks right | verify, or leave it open |
| Say "checked CI" when you read it from the plan | name what you took on trust |
| Write from a read you did earlier in the turn | re-read immediately before writing, every time |
| Rewrite a whole plan file | targeted edit against a unique anchor |

## Red flags - stop

- about to `Read` a plan with no offset;
- about to `ls` or `grep` the Context root for a rename or a typo;
- about to shorten an old entry "for clarity";
- about to tick a box for something not pushed;
- about to create files in a second package;
- thinking "I trust you means I can restructure";
- thinking "this lesson is obviously reusable" without asking who would need it;
- writing a link without having confirmed the target;
- about to write to a plan when the read was not the immediately preceding step;
- thinking "nobody else is touching this file" - you cannot know that, and the cost of checking is one read.

## References

- `references/context-package-contract.md` - package shape, frontmatter, relationship vocabulary, links, PR knowledge objects, approval boundary.
- `references/memory-distillation.md` - the durable-versus-operational test, entry format, worked promotions and rejections.
- `references/examples.md` - a full discovery-to-report pass, an `index.md`, a state block, a conflict report.
