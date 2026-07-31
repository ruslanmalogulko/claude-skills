# Memory Distillation

**Load this when:** at a checkpoint, deciding what to promote out of a plan into `memory/`, or writing a durable entry.

Distillation is subtraction. Most of what a plan records is operational and belongs only in the plan. A `memory/` that grows as fast as the ledger has failed.

## The test

Promote a finding only if **all four** hold:

1. **Reusable** - a session working a different ticket would be better off knowing it.
2. **Durable** - it will still be true next month. Not a status, not a queue position, not a head commit.
3. **Verified** - you established it, or the plan records how it was established and by whom.
4. **Non-obvious from the code** - or obvious in the code but the *rationale* or *failure mode* is not.

Fail any one, leave it in the plan.

## Operational versus durable

| Operational - stays in the plan | Durable - promote |
|---|---|
| CI is green on head `25d2dcc1d` | the SLOC guard is a bare `exit 1` with no bypass, so a long branch must be rebuilt onto main rather than carried |
| the push was rejected, non-fast-forward | a merged-and-deleted branch plus a stale `origin` means `git push origin HEAD` resurrects a dead branch |
| human review still pending | "fixed in code" is not resolved while the review thread is open |
| screenshot upload was refused by the permission classifier | - nothing durable. This is a tooling permission, not project knowledge. |
| the transient 502 on `update-branches` | - nothing. A flake is not a failure mode. |
| 8058 tests green, 978 files | - nothing, unless the count encodes an invariant someone must maintain |
| four commits landed locally, nothing pushed | `[x]` means pushed; a green local run is not shipped |
| `stash@{0}` holds the b1 unwind | - nothing. Ephemeral by definition. |

The right-hand column is not a summary of the left. It is a different claim, at a different altitude, that happens to have been learned in the same hour.

## What is not project memory

**Durable knowledge means knowledge about the system being built.** Notes about how the work was organised are a different genre and do not belong in a topic's `memory/`:

- how to drive subagents, what a notification means, which tool returns what;
- which agent said what, or that a self-report turned out to be wrong;
- how a session was sequenced.

If it would read as a diary entry rather than an engineering fact, it is not memory. (Genuine harness traps - a Node version that silently breaks a test runner - are engineering facts and do belong, in `_platform/memory/`.)

## Where it goes

| Scope | Home |
|---|---|
| true only inside this topic | `<topic>/memory/` |
| true across topics | `_platform/memory/` |

**Test:** would a session on an unrelated ticket need it? Yes means `_platform/`.

Do not invent a third home. `_process/`, `lessons/`, `engineering-lessons.md` at the root - each new name splits the corpus and guarantees the next session looks in the wrong place. `_platform/memory/` or `<topic>/memory/`, nothing else.

Four curated files by default:

```
memory/
├── architecture.md          # how it is put together, and why
├── conventions.md           # what this codebase does by default
├── decisions.md             # what was chosen, what was rejected, why
└── known-failure-modes.md   # bug classes and traps that recur
```

Append a section. A dedicated file only when the subject is substantial, independently reusable, and likely to be linked repeatedly.

## Entry format

Heading states the finding as a claim, so a heading link is self-describing.

```markdown
## Effects reacting to server errors must not key on object identity

**Scope:** React forms in the web app that apply server validation errors. Confirmed in the
entity-questionnaire wizard; the shape is general, the fix is per-component.

**Finding:** An effect depending on an error *object* re-fires whenever a parent rebuilds that
object, even when nothing was rejected. `create-corporate-group-widget.tsx` built a fresh
`{formPath, message}` literal on every render of `renderCurrentStep()`, so the effect - and the
`scrollToFirstError` inside it - re-ran on unrelated wizard re-renders.

**Impact:** The user is scrolled away from the field they are typing in, with no error present.

**Preferred approach:** depend on stable semantic fields (`serverError?.formPath`,
`serverError?.message`), or consume the error once, or carry an explicit version/event.

**Evidence:** test rerenders with a value-equal, new-identity error and asserts
`scrollIntoView` is not called twice. Red at 2 calls, green at 1.

**Source:** [[../plans/EEI-768-company-profile-prompt-plan]] · PR #4347 · fixed in `be27b28ab`
**Discovered:** 2026-07-31, from a CodeRabbit finding that was confirmed by reading both files.
```

Required: **statement** (the heading), **scope**, **finding**, **evidence**, **source**, **date**.
Add **impact** when the consequence is not obvious. Add **confidence** when you are unsure:

```markdown
**Confidence:** medium. Established by reading the code, not reproduced. Re-check if it matters.
```

## Scope honestly

A locally verified detail stated as a universal law is worse than no note - the next session applies it somewhere it does not hold.

```markdown
<!-- overreaching -->
## Never gate validation on a mode field

<!-- accurate -->
## Gating validation on a mode field is only safe where the surface owns that mode
Scope: `worksites-manage-form.tsx` inherits `worksiteMode` from the entity and yields `''` for an
entity with no worksites, so gating there would have saved the first row unvalidated.
```

Name the boundary of what you checked. "Confirmed in X; the shape is probably general" is honest. Silently widening it is not.

## Rejections belong in memory too

A rejected suggestion with a reason is durable knowledge - it stops the next session relitigating it. Record it in `decisions.md` with the reason and a reopen condition.

```markdown
## Rejected: validating the whole issue when its path is malformed

CodeRabbit proposed making `isValidationIssue` reject an issue whose `path` is not an array. That
drops the issue's *message* too, contradicting its own stated intent of falling back to the
message. Validated `path` inside `describeIssue` instead, so a bad path is dropped and the message
survives. Reopen if a caller needs the whole issue rejected.
Source: PR #4347 · 2026-07-31
```

## Worked example: what this pass produced

From the EEI-768 debugging and review pass, a long ledger of dated entries:

**Promoted (2):**
- effects keyed on object identity re-fire and steal focus - reusable, durable, verified by a red-then-green test, and the rationale is invisible in the code;
- `resolveOnboardErrorLocation` destructured `issue.path` after checking only `message`, and it runs *before* the toast fallback, so a throw means the user gets neither walk-back nor toast - the ordering is the durable part.

**Rejected (5):**
- green CI on a named head - status;
- the transient 502 on `update-branches` - a flake;
- the non-fast-forward push - ordinary operational friction;
- the screenshot permission refusal - tooling permission, already in the ledger;
- the test counts - no invariant attached.

## How much is too much

Calibrate against the *scope of what you are distilling*, not against a fixed number.

- **One debugging pass or one review round** - expect one to three promotions. Ten means you are copying the ledger.
- **A whole multi-ticket effort being closed out** - a dozen or more can be right, because you are distilling weeks across several tickets, and decisions-with-reasons are individually cheap and individually load-bearing.

The count is not the test; the four conditions are. Apply them per entry and let the number fall out. If you cannot state a promotion's scope, rationale and evidence in three lines, it is not ready to be promoted - that failure is what "too much" actually looks like.

## Reconciling before you distil

Distillation is not the first step of a checkpoint. Reconcile first, because a wrong status produces a wrong lesson:

1. re-read the plan (it may have moved since your last read);
2. check the claims you are about to build on - is the head still current, did the branch merge, is the thread resolved;
3. only then decide what is durable.

A finding derived from a stale state block is confidently wrong. If you cannot verify a claim, say so and leave its status alone rather than promoting a conclusion that rests on it.
