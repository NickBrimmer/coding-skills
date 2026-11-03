# Planning File Structure, Vocabulary & Writing Rules

One scheme and one writing style, used in every planning and review file. A reader
arriving cold — the engineer or a fresh agent session — should be able to act on any line
without learning the file's private labels or reading the line before it.

This file wins over any skill's or template's own labelling or writing format.

## Section headings

Follow the house structure, matching the sibling plans in the same epic:

`## Status` · `## Goal` · `## Scope` · `## Existing code to build on` · `## Open questions` ·
`## Tests Required` · `## Notes`

A new top-level section needs a reason. "This file grew its own workflow over many
sessions" is not one.

## Status

The first section after the header block. A cold reader learns where the work stands
without reading the rest. Five lines at most, rewritten in place, never appended to.

```
## Status
At `abc1234`. Next: rebase on !123, then Step 3.
- [x] Steps 1–2 [ran: tests pass]
- [ ] Step 3: `app/x.tsx:40` done, `:52` not
- Waiting on the engineer: Concern #3; `[my call]` ×2
```

- Line one is always the commit and the single next action.
- A step is a tick and a pointer. How it was done goes in the evidence file.
- Work finished → the whole block becomes one line: `Done at <sha>, MR !N.`
- A review file's `## Handoff Status` is its Status block.

## Record as you go

The file is written before the engineer hears anything, not after. Anything that exists
only in chat is lost to a crash, a compaction, or a fresh session.

Write to the file, then report, when any of these happens:

- **A finding that would change what the engineer does** → its `Concern #N` straight
  away, tagged `[unverified]` until checked. Upgrade the tag when the check runs.
- **A step finishes or stops part-way** → tick or amend its Status line.
- **The engineer answers questions or decides something** → record every answer before
  any other tool call. A resolved STOP GATE row compacts in the same write.
- **Work is deferred** → a `Follow-up:` line under `## Notes`.
- **Something can only be checked by hand** → a `Browser check:` line under
  `## Tests Required`.
- **A call made while the engineer is away** → record it where it belongs, tagged
  `[my call]`. The tag comes off when the engineer confirms it.
- **About to report** → the file is current first. The report names what changed in the
  file ("Concern #13 added, Status updated"); it does not repeat it.

Line prefixes and tags, not new sections:

- `Follow-up: <one line> — <ticket to file, or the existing ticket>`
- `Browser check: <what to do> → <what to see>`
- `[my call]` — decided without the engineer; ask on their return.
- A user-facing string carries its source: `[design]`, `[ticket]`, or `[mine]`.

Terse beats complete. A line that only says work happened ("investigated the loader") is
noise: record the result, or nothing.

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

And a Status block over five lines:

```sh
awk '/^## /{s=($0 ~ /Status$/)} s && NF && !/^## /{n++} END{if(n>5) print FILENAME": Status has "n" lines"}' <file>.md
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
