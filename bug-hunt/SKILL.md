---
name: bug-hunt
description: Hunt for bugs the diff doesn't show — missed call sites after a one-case-becomes-many generalization, broken invariants between paired values, and fix claims that were never actually reproduced. Use when investigating a bug, verifying a claimed fix, auditing a change that made something configurable or turned a single case into several, or when a review needs to go deeper than reading the diff. Also use when asked to find what a change might have broken elsewhere.
---

# Bug Hunt

Two techniques. Both exist because the bug was **not visible in the diff** — the diff
looked complete and correct in isolation, and the defect lived in a file it never
touched, or in a claim nobody reproduced.

Reading the diff again will not find either one. Run the technique.

---

## 1. Incomplete Generalization

**The pattern.** Something gets generalized from handling one case to handling several —
a single report/flag becomes a map, a fixed layout value becomes a configurable prop, one
panel becomes two on the same page. The "obvious" call site (usually the access-check or
data layer) gets updated correctly, but **sibling call sites that quietly baked in the
old single-case assumption are missed.**

They don't surface from re-reading the diff. The diff is fine. The bug is elsewhere.

### The audit

Don't stop at "does the site I changed still work." **Grep the whole repo for the exact
constant, value, or pattern being generalized, and check every hit** — not just the ones
in the ticket's own file list.

Three shapes to look for:

1. **A hardcoded default used as a shortcut elsewhere** — `DEFAULT_X`, or a single
   ID/flag treated as "the only one." Every other usage needs the same generalization,
   not just the access-check/data layer that prompted the change.

2. **A hardcoded value with an inverse or paired relationship to the newly-configurable
   one** — two percentages that must sum to 100, two IDs that must stay in sync, a
   width and its complement. Changing one without auditing the other silently breaks
   the invariant. Nothing errors; the layout is just wrong.

3. **A second instance of an existing coordinated pattern** — a second side panel, a
   second state machine — built as fresh local state instead of reusing the mechanism
   the first instance already uses. Check how the first instance solved the same problem
   before writing new state/logic for the second.

### Worked example

A ticket generalized single-report access control into a feature-flag map. The
access-check loader was fixed correctly. Then:

- Three sibling call sites — the nav tab's link, an index route's redirect, and a
  loading-skeleton's default pick — all still hardcoded `DEFAULT_REPORT_SLUG`.
- The same page gained a second side panel. The first panel used a shared
  `useSidePanelSlot` mechanism; the second was built with raw `useState`.
- A configurable sidebar-width prop was added, but the sibling main-panel width stayed
  hardcoded — so the two no longer summed to 100.

**Four bugs, one root cause.** Every one of them was found only by deliberately
re-grepping for the old assumption after the fact — none by re-reading the ticket's own
diff.

### Checklist

- [ ] Name the old assumption out loud: which constant, value, or "there is only one X"?
- [ ] `grep -rn "<the constant>"` across the whole repo. Every hit gets a decision:
      updated, or a deliberate documented no-op.
- [ ] Any value with an implicit relationship to the new one (sums, pairs, mirrored IDs)?
      Grep for it too.
- [ ] Is this the second instance of a pattern? Read the first instance in full and reuse
      its mechanism.
- [ ] Re-run the grep after implementation, before merge.

---

## 2. Verify Claims Directly

For any change claiming a **bug fix, a data-correctness fix, or a performance
improvement** — don't take the description's word for it, and **don't stop at "the code
looks right."** Reproduce and confirm directly, the same way during review as during
investigation.

### The loop

- **Run the dev server backgrounded and read its stdout yourself.** Don't ask the author
  to paste log output, and don't infer behavior from the code. Restart after any
  schema/code change.

- **Query the dev database directly** to confirm the claimed before/after state. **Find
  out what the dev DB actually is first** — read the README. An embedded/file-backed dev
  DB will not accept a connection from the standard client for that engine, and reaching
  for the obvious CLI returns "nothing there," which reads exactly like "the bug is
  fixed." If the project ships its own SQL browser route or script, use that.

- **Call the changed route/handler directly, bypassing the UI.** Reproduce the original
  bug against the base branch first, then confirm it's fixed on the branch. A repro you
  never saw fail is not a repro. Watch for handlers that run on a retry — hitting one
  twice can double-apply a write.

- **Build disposable fixtures with one direct write**, not by clicking through the UI.

- **For repeatable writes** (granting a flag, seeding fixtures), write a small typed
  script against the project's own data layer rather than curl plus output parsing. Stop
  the dev server first if the dev DB is single-writer — a second connection while the
  server holds it open can corrupt state.

- **Cross-check external APIs independently** — raw curl or a standalone script, no app
  code, checked against the published schema. This is what separates "our bug" from
  "their API changed."

- **Reserve the browser for final end-to-end confirmation only.** It is the slowest and
  least precise instrument here, not the first one.

### Caveats that have bitten before

- A dev DB that isn't the production engine **may not reproduce real concurrency races.**
  A clean local repro is not proof a race is fixed.
- A fix that type-checks is not a fix. Hit the real endpoint or the real dataset.
- Naive line-counting breaks on multi-line CSV fields. Parse, don't count.

---

## 3. Edges & Inputs

When hunting rather than auditing a specific change, work the boundaries:

- What breaks this input, API, or request when used in ways it was not meant to be?
- Empty vs. missing vs. null vs. zero — does each take a different path, and is that
  intended? An empty state rendered as an error state (or vice versa) is a common gap.
- What happens on the second call? On a retry? On a concurrent call?
- Does the fallback path get tested against **the exact input that triggers it**, or only
  "in general"?
- Read the full handler including soft-delete and restore paths, not just the happy path.
- Does the feature work with itself fully disabled?
