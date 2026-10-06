# Planning File Structure, Vocabulary & Writing Rules

One scheme and one writing style, used in every planning and review file. A reader
arriving cold — the engineer or a fresh agent session — should be able to act on any line
without learning the file's private labels or reading the line before it.

This file wins over any skill's or template's own labelling or writing format.

## Section headings

Follow the house structure, matching the sibling plans in the same epic:

`## Goal` · `## Scope` · `## Existing code to build on` · `## Open questions` ·
`## Tests Required` · `## Notes`

A new top-level section needs a reason. "This file grew its own workflow over many
sessions" is not one.

## Labels

- **`Concern #1`** — a problem or bug in the code. Numbered in the order found; never
  renumbered once something references it.
  - **Merge or new — never nest.** A finding that is the same problem as an existing
    concern is added to that concern as evidence. One not similar enough to collapse is
    its own `Concern #N`. No `Concern 1.a` sub-labels.
- **`Option 1` / `Option 2`** — the different ways to solve a concern or build a feature.
  Only ever a path forward, never a label for the problem itself.
  - **`Option 1.a` / `Option 1.b`** — sub-concerns or open questions that apply only to
    that option.

**Don't invent a parallel scheme.** No `Track A`, no `Round 3 item 4`, no per-file letter
codes, no checklist letter codes. "Track" means a parallel workstream and is wrong for a
problem to fix. A file carrying competing schemes forces the reader to hold all of them
to parse one sentence.

**Name the thing alongside its label** — "Concern #2, the empty-vs-error gap" — so a
cross-reference still reads if the numbering ever moves.

## Writing rules

**Line cap.** One sentence per line, 30 words or fewer. A longer line is a finding not
yet understood, or detail that belongs behind a pointer. Don't hard-wrap a sentence in a
planning file, or the length check can't see it.

**Concern shape.** A heading and two lines, nothing around them:

```
### Concern #4, search loader ignores the filter
Problem: q="" returns all 4k rows — `app/x.server.ts:22` [ran]
Fix: server-side guard, mirroring `app/x.tsx:88`
```

- `Problem:` is the input or state, the wrong result, and the `file:line`.
- `Fix:` is the proposed change and where it goes. Undecided → `Fix: open — <the question>`.
- A real choice replaces `Fix:` with `Option 1:` / `Option 2:` lines, one line each.
- Review threads (`Review:` / `Author:`) go under these two lines, under the same cap.

**Evidence tag, not prose.** End each claim with how it was checked: `[ran]` (executed
it), `[read]` (read the code at the pointer), or `[unverified]`. Never write "verified by
reading" as a sentence.

**Edit in place.** The file is the current state, not a transcript. Correct your own line
by rewriting it, never by adding a line below it. Never append a dated session log.

**Closed concerns shrink immediately.** Don't wait for a close-out.

- `WITHDRAWN` → delete the whole concern. Its number is not reused.
- `RESOLVED` → one line: `Concern #N, <name> — fixed at <file:line>`.
- `RISK` → keep as written.

**Evidence lives in its own file.** Repro recipes, sample methodology, query output,
local setup, and diff stats go in the project's `evidence/` folder (see
`project-context.md`), linked from the concern they support. Superseded history goes to
`archive/`.

**No dates or names in the body.** Git carries who and when. Record a ruling as the
ruling plus a pointer (a ticket comment, an MR thread), not "(Sam, 2026-01-15)". Pin state
with a commit SHA, not a date.

**"Checked, no findings" is one line** naming what was checked. What each check returned
goes in the evidence file.

**Review file header is three lines:** branch at SHA, MR and ticket, spec source. The MR
already shows the diff, so don't paste a stat or summarize the change.

**Length check.** List every line over the cap:

```sh
awk '/^```/{c=!c;next} !c && NF>30 {print FILENAME":"NR": "NF" words"}' <file>.md
```

## Header block

Open a plan with whichever of these apply:

```markdown
**Depends on:** <ticket-id>
**Blocks:** <ticket-id>
**Build type:** NET-NEW | ADAPT | SHELL

## ⛔ STOP GATE

| Question | Resolved by | What changes if the answer surprises |
| --- | --- | --- |
| ... | ... | ... |
```

No implementation until every STOP GATE row is confirmed. A question that changes no
code is a clarification, not a blocker — it belongs in the Final Outstanding Questions
table instead. Once a row resolves, compact it to `<question>` → `<answer + pointer>`.
