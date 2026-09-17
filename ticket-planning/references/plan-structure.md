# Planning File Structure & Vocabulary

One scheme, used in every plan. A reader arriving cold should not have to learn a file's
private labels before they can follow a cross-reference.

## Section headings

Follow the house structure, matching the sibling plans in the same epic:

`## Goal` · `## Scope` · `## Existing code to build on` · `## Open questions` ·
`## Tests Required` · `## Notes`

A new top-level section needs a reason. "This file grew its own workflow over many
sessions" is not one.

## Labels

- **`Concern #1`** — a problem or bug in the code. Numbered in the order found; never
  renumbered once something references it.
  - **`Concern 1.a` / `Concern 1.b`** — sub-problems that exist only inside that concern.
- **`Option 1` / `Option 2`** — the different ways to solve a concern or build a feature.
  Only ever a path forward, never a label for the problem itself.
  - **`Option 1.a` / `Option 1.b`** — sub-concerns or open questions that apply only to
    that option.

## Don't invent a parallel scheme

No `Track A`, no `Round 3 item 4`, no per-file letter codes. "Track" in particular means
a parallel workstream and is wrong for a problem to fix.

A file carrying several competing schemes at once forces the reader to hold all of them
to parse one sentence. That is the failure this section exists to prevent.

## Name the thing alongside its label

"Concern #2, the empty-vs-error gap" — so a cross-reference still reads if the numbering
ever moves.

## Header block

Open the plan with whichever of these apply:

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
table instead.
