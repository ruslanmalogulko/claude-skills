# Examples

**Load this when:** you want a concrete shape to copy - a discovery pass, a state block, an `index.md`, a conflict report, or a checkpoint report.

All examples are from the ManifestOS vault, EEI-768 in `entity-questionnaire`.

## A discovery pass, start to finish

Task: *"Continue EEI-768. The current plan is in the Obsidian ManifestOS context."*

```bash
# 1. one level of the Context root, to see topic names. Not recursive.
ls "$CTX"

# 2. the identifier decides it
ls "$CTX/entity-questionnaire/plans" "$CTX/entity-questionnaire/specs"

# 3. map the plan before reading any of it
grep -n '^#\{1,4\} ' "$CTX/entity-questionnaire/plans/EEI-768-company-profile-prompt-plan.md"
#   1:# EEI-768 Company Profile Update Prompt Implementation Plan
#  15:## Global Constraints
#  31:### Task 1: ...
# 488:## Findings ledger
# 508:### State of play (update on every pass ...)
# 766:### PR #4347 review-feedback pass, 2026-07-31
# 796:## Out of scope
```

Now three targeted reads: `Read` at offset 488 for the ledger header and legend, offset 508 for the state block, offset 766 for the newest pass. Roughly 120 lines instead of 802.

Then Layer D, targeted, not traversal:

```bash
ls "$CTX/_platform/memory" 2>/dev/null
grep -rl -e 'EEI-768' -e 'company-details' -e 'companyDetailsRequiredSchema' \
  "$CTX"/*/memory "$CTX"/*/specs 2>/dev/null
```

Report:

```
Context: entity-questionnaire
Plan: plans/EEI-768-company-profile-prompt-plan.md (ledger legend + state block + 2026-07-31 pass)
Also loaded: nothing - no memory/ exists in this package yet
Ambiguity: the state block names head 25d2dcc1d; the PR head has moved twice since. Reconciling before I act.

Blockers before any implementation:
- browser screenshots not attached to PR #4347 (attach-media upload was refused)
- no human review yet (reviewDecision: REVIEW_REQUIRED)
```

**What not to do:** three paged `Read` calls covering lines 1-802, one of which is rejected for exceeding the 25k-token cap.

## A state block

The one mutable block. Keep it short enough that it is obviously the answer to "where are we".

```markdown
### State of play (update on every pass - this table is the answer to "where are we?")

Updated: 2026-07-31, re-checked against GitHub rather than carried forward on trust.

**Objective:** land the EEI-768 surfaces plus the MAN-404x fixes, and get PR #4347 approved.

**Status:** implementation complete, all bot findings resolved, CI green. Waiting on a person.

**Current PR:** #4347 (8 tickets) · **head:** `25d2dcc1d` · **required check:** `ci-status` pass

| Bucket | Count |
|---|---|
| ✅ RESOLVED | 24 |
| 🔴 OPEN | 3 |
| ⛔ REJECTED | 2 |

**Open blockers**

- browser screenshots not attached to the PR
- no human review (`REVIEW_REQUIRED`)
- form does not bound `phone`; the API's 30-char cap is the only guard

**Next action:** attach screenshots, request human review, then work any findings.
```

When you replace it, preserve what you removed:

```markdown
#### Superseded snapshot: state of play as of 2026-07-30

> Last updated: 2026-07-30, head `d72248d66` plus uncommitted unwind work. Four commits landed
> locally, NOTHING pushed. b1 is DEFERRED and parked in `stash@{0}`.
> Merge blockers right now: CHANGES_REQUESTED, red `lint` (SLOC), and the two open Cursor bugs.

Every claim above is now false and each has its own dated entry below: #4210 merged 2026-07-30,
the four commits were replayed onto #4347, the SLOC guard stopped firing after the rebuild.
```

## An `index.md`

Written only once the package had two plans and a verified cross-context link.

```markdown
---
type: context
context: entity-questionnaire
status: active
aliases:
  - entity questionnaire
  - company details form
  - company profile prompt
identifiers:
  - EEI-767
  - EEI-768
  - MAN-4041
  - PR-4347
related:
  - fn-field-validation
depends_on: []
last_reviewed: 2026-07-31
---

# Entity Questionnaire

## Purpose

v2 entity onboarding questionnaire, plus the prompt that gets companies onboarded on v1 to fill
the fields v2 requires.

## Current work

- [[plans/EEI-768-company-profile-prompt-plan]] - active; PR #4347 awaiting human review
- [[specs/EEI-768-company-profile-prompt-spec]] - approved 2026-07-27
- [[plans/EEI-767-entity-questionnaire-fields-plan]] - merged

## Durable knowledge

- [[memory/known-failure-modes]]
- [[memory/decisions]]

## Related contexts

- [[../fn-field-validation/index]] - owns the shared field-rule generator this form would call

## Possibly related

`h1b-mvp-bugs` holds MAN-404x tickets fixed inside PR #4347, and one of its specs contradicts what
shipped. Not a validated dependency - see the conflict note in the plan. Do not promote to
`related:` until someone decides which document governs.
```

Note the split: the verified link is in frontmatter and the body; the unvalidated one is prose under a hedged heading.

## A conflict report

Two sources disagree. Discovery first, then one question.

```
Conflict on the ops company-details surface. Both sources found; neither silently applied.

Contradictory:
- entity-questionnaire/plans/EEI-768-...-plan.md, 2026-07-31, shipped in PR #4347: the lenient
  (ops) schema now requires country/city plus state+ZIP (US) or postal (non-US) whenever the
  physical address differs from mailing. Verified in a browser on 2026-07-31.
- h1b-mvp-bugs/specs/MAN-4041-ops-address-spec.md, status "draft, not reviewed", sourced from a
  hallway conversation: the ops surface must keep the whole block optional except line1, because
  ops paste partial records and need to save and return.

Authority: the plan describes approved, shipped, browser-verified behaviour. The spec is an
unreviewed draft, and its own "Open question" section says nobody made the product decision - which
implementation then made for it.

That is a product call, not a code call. Which governs: does the ops surface keep requiring the
full block, or should #4347's change be cut back to the ZIP-format half?
```

Then log it as `🔴 OPEN` in the plan and stop. Do not implement either branch, and do not edit the spec to agree with the code. Annotating the draft with "what shipped contradicts this, see PR #4347" is fine.

## A checkpoint report

```
Updated:
- entity-questionnaire/plans/EEI-768-...-plan.md - state block replaced (old snapshot quoted
  below it); appended "### Context pass, 2026-07-31" with 3 entries in the plan's own markers
- _platform/memory/known-failure-modes.md - 2 new sections
- entity-questionnaire/index.md - created (2 plans + 1 verified cross-link earned it)

Durable findings: 2
- effects reacting to server errors must not key on object identity
- resolveOnboardErrorLocation runs before the toast fallback, so a throw there loses both

Not promoted: green CI, the update-branches 502, the non-fast-forward push, the screenshot
permission refusal, the test counts. All left in the ledger.

Links added: entity-questionnaire/index.md -> ../fn-field-validation/index (verified: shared
field-rule generator). h1b-mvp-bugs left in prose as unvalidated.

Blockers unchanged: screenshots not attached; no human review.

Could not verify: the 8058-test count and the browser-verification table - carried from the plan on
trust, not re-run. MAN-4041's ✅ RESOLVED marker: the requiredness half shipped, the ZIP-format half
did not, so I left it 🔴 OPEN rather than upgrading it.
```

## A concurrent edit, handled

This happened. Treat it as the expected case, not the unlucky one.

A checkpoint pass read the plan, spent several minutes verifying claims against `git` and the GitHub API, then wrote a new state block and appended a checkpoint section. Between that read and that write, **another session appended its own checkpoint covering two of the same findings.**

What saved it was mechanical, not deliberate: the writes were targeted edits against unique anchor strings, so the concurrent append survived. A whole-file rewrite from the stale read would have destroyed it silently, and the loss would have looked like nothing at all.

What the pass then did, after noticing:

1. **Compared the two accounts instead of merging blindly.** The other session's was better on the shared findings - it had verified one by running a probe rather than by reading, and carried two corrections the first pass did not have.
2. **Deleted its own duplicates** and left a pointer to the other section. Two competing accounts of one finding is worse than either alone: the next reader cannot tell which is current.
3. **Kept every unique fact** it had established - CI state on the current head, and why `mergeStateStatus` was blocked.
4. **Recorded the collision itself** in the plan, as provenance:

```markdown
**Concurrent edit, worth recording as provenance.** The section directly above was appended by
another session *between* my read of this plan and my write to it. I did not overwrite it - the
edit was surgical - but I also had not re-read before writing, which is the mistake and not the
save. It owns the two unresolved cursor findings and carries two corrections mine did not. Not
duplicating any of that here.
```

Note what is *not* in that entry: no apology, no narration of the near-miss beyond its consequence. It exists so the next reader knows why two sections cover adjacent ground and which one is authoritative.

**The rule this earns:** re-read immediately before writing, and prefer the anchored edit. Deferring to the better-verified account costs one paragraph. Silently clobbering another session's verified work costs whatever it found.

## Not triggering

Task: *"rename the local variable `mf` to `missing`."*

Correct behaviour: rename it. Do not list the Context root, do not open a plan, do not announce this skill. A function-local identifier has no project context that could change the edit.
