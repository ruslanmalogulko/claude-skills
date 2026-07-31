# Context Package Contract

**Load this when:** creating or maintaining `index.md`, adding frontmatter or relationships, deciding whether a PR deserves its own folder, or proposing any structural change to a context package.

A **context package** is one top-level folder under the Context root representing one bounded implementation topic: a feature, subsystem, bug batch, investigation, rollout, or temporary initiative.

## The shape

Only `plans/` and `specs/` are load-bearing today. Everything else is optional and arrives when it earns its place.

```
topic-name/
├── index.md        # routing document. Optional. Add when the package has >1 plan or any cross-context link worth recording.
├── specs/          # requirements and intended behaviour. Authoritative on "what should happen".
├── plans/          # the active plan and its ledger. Authoritative on "where are we".
├── artifacts/      # screenshots, reports, diagrams, exports, evidence.
├── transcripts/    # raw source conversations and investigation logs.
├── memory/         # durable knowledge. Add at the first durable finding, not before.
└── prs/            # PR knowledge objects. Add only for a PR that earns one.
```

**Gradual adoption is mandatory.** A package with only `plans/` and `specs/` is a valid package. Never make progress on a task conditional on a package being migrated first, and never migrate a package as a side effect of doing other work.

## Frontmatter

### `index.md`

```yaml
---
type: context
context: entity-questionnaire     # must equal the folder name
status: active                    # active | paused | shipped | archived
aliases:
  - entity questionnaire
  - company details form
identifiers:                      # every ticket, PR and epic that lands in this package
  - EEI-767
  - EEI-768
  - PR-4347
related:
  - fn-field-validation
depends_on: []
last_reviewed: 2026-07-31
---
```

`aliases` and `identifiers` exist so a future search finds this package by the words a person would actually type. They are the highest-value fields in the file. Fill them even if you write nothing else.

### `prs/PR-4347/index.md`

```yaml
---
type: pr
id: PR-4347
context: entity-questionnaire
status: open                      # open | merged | closed | abandoned
tickets:
  - EEI-768
  - MAN-4042
head: 25d2dcc1d                   # the commit this file's claims were established at
produces_knowledge:
  - ../../memory/known-failure-modes
---
```

### `memory/*.md`

Memory files need no frontmatter. Each *entry* inside carries its own provenance (see `memory-distillation.md`).

## Relationship vocabulary

Use these names, in frontmatter or in prose. Do not invent new ones.

| Relationship | Means |
|---|---|
| `related` | Overlapping subject matter. The weakest claim. |
| `depends_on` | This work cannot complete until that one does. |
| `implements` | This package builds what that spec describes. |
| `supersedes` | This replaces that. The superseded thing stays on disk. |
| `informed_by` | A decision here was shaped by evidence there. |
| `produces_knowledge` | This work generated the durable note it points at. |
| `affects` | Changing this changes the behaviour of that. |
| `verified_by` | The claim here was checked against that evidence. |

**Verified relationships go in frontmatter. Unverified ones go in prose, worded as a hypothesis.**

A relationship is verified when you have read both sides and can state what specifically connects them. "Both mention validation" is not verification. "`fn-field-validation` owns the enum-rule generator that this form's schema would have to call" is.

```markdown
<!-- verified: goes in frontmatter -->
related:
  - fn-field-validation

<!-- unverified: goes in prose, and nowhere else -->
## Possibly related

`fn-color-batch` may share this form's error-summary component. Not checked - if you
confirm it, promote this line into `related:` and delete it from here.
```

## Links

Obsidian wiki-links, relative to the vault:

- Inside a package: `[[plans/EEI-768-company-profile-prompt-plan]]`
- To a sibling package: `[[../fn-field-validation/index]]`
- To a memory entry's heading: `[[../memory/known-failure-modes#Effects reacting to server errors must not key on object identity]]`

**Never write a link to a file that does not exist**, unless you create that file in the same pass. A dangling link is worse than no link: it reads as evidence that something was recorded when nothing was.

Before writing any link, confirm the target exists. Before writing a heading anchor, confirm the heading text matches exactly.

## `index.md` body

Keep it short. This is a routing document, not a summary of the work. If it grows past roughly one screen, the content belongs in a plan, a spec, or a memory file.

```markdown
# Entity Questionnaire

## Purpose

v2 entity onboarding questionnaire, plus the prompt that makes companies onboarded on v1
fill the fields v2 requires.

## Current work

- [[plans/EEI-768-company-profile-prompt-plan]] - active, PR #4347 awaiting human review
- [[specs/EEI-768-company-profile-prompt-spec]]

## Durable knowledge

- [[memory/known-failure-modes]]
- [[memory/decisions]]

## Related contexts

- [[../fn-field-validation/index]] - owns the shared field-rule generator

## Important PRs

- [[prs/PR-4347/index]] - 8 tickets, substantive bot review history
```

## When a PR earns its own folder

Default is **no folder**. The plan's ledger already carries review history and provenance.

Create `prs/PR-####/` only when at least one holds:

- it spans multiple tickets;
- its review history is substantive enough that the ledger section is getting hard to read;
- it uncovered durable defects or architectural knowledge;
- it has unusual migration, rollback, CI, or deployment behaviour;
- it is likely to be re-investigated later;
- it holds acceptance evidence (screenshots, verification tables) worth finding again.

```
prs/PR-4347/
├── index.md          # purpose, current state, key changes, verification, review history
├── implementation.md # optional
├── review.md         # optional
├── timeline.md       # optional
├── screenshots/
└── artifacts/
```

**The PR folder owns history and provenance. It does not own canonical knowledge.** Durable conclusions live in `memory/` and link back to the PR. A PR folder that accumulates architecture notes has become a second source of truth, which is the failure it was supposed to prevent.

Offer the folder. Do not create it unasked: it is four to six new files, and the ledger it duplicates is still the thing people read.

## Structural changes need approval

Creating `index.md` or `memory/` in the one package you are actively working, at the moment a real finding needs somewhere to live, is routine work. It needs no separate conversation.

Everything below needs explicit approval **before** any file is touched:

- creating scaffolding across more than one package;
- moving, renaming, or deleting any existing file;
- introducing a new directory level or a new naming convention;
- changing the information architecture, including the Context root layout;
- backfilling frontmatter across packages.

"Go ahead, I trust you" is not approval for a mass migration. It is a statement about trust, not a review of a plan that does not exist yet. Produce the plan, show the counts (packages touched, files moved, files created), and get a yes.

When approval is granted, prefer one pilot package first, then stop and show the result before continuing.
