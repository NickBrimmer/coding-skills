---
name: adversarial-review
description: Run a hostile back-and-forth review of a change across two sessions — one attacks the diff and its unstated assumptions, the other defends and fixes, both writing one- to two-line entries into the ticket's planning file until the engineer calls it. Use when asked for an adversarial review, a red-team or devil's-advocate pass, a review fight or standoff, or to tear apart, stress-test, or poke holes in a PR, branch, or diff. Also use when a change is risky enough to need more than a normal review.
---

# Adversarial Review

Two terminal sessions on one repo. One attacks, one defends, both append to the ticket's
planning file. An engineer watches and has the last word.

**Harsh means a higher bar, not more findings.** Being told to attack makes padding free —
thirty findings costs nothing to generate and costs the author an afternoon. Every entry
here carries an input and the wrong output it produces, or it is not filed.

**Neither side folds to confident wording.** A disagreement closes by running something.
If the other side sounds certain and you have evidence, repeat the evidence.

---

## Pick your side first

- Wrote the code in this session → you are the **author**.
- Arrived to review it → you are the **reviewer**.

Unclear? Ask the engineer in one line. Do not guess — both sides attacking gets nothing
fixed.

## The ticket file is the channel

Append to a `## Adversarial Review` section in the ticket's planning `.md`. There is no
other channel. The two sessions cannot talk.

**Labels and writing follow
`~/.claude/skills/ticket-planning/references/plan-structure.md`, which wins over anything
in this skill.** Every problem is a `Concern #N`. Evidence goes in the project's private
`evidence/` folder — see `project-context.md` beside it.

```
## Adversarial Review

**Checked, no findings:** the diff + every caller of applyFilter; access checks and the migration.

### Concern #4, the search loader ignores the filter
Problem: POST /search with q="" returns all 4k rows — `app/x.tsx:88` [ran]
Fix: guard the empty query on the server, not only the client
Author: client guard added, app/x.tsx:88
Review: still open — x.server.ts:22 takes the same call with no guard
Author: server guard at x.server.ts:22; repro fails on main, passes here
Review: RESOLVED
```

Format, no exceptions:

- **Continue from the highest `Concern #` already in the planning file.** Never restart
  at 1, never renumber.
- **Merge or new — never nest.** Before filing, check whether the finding is the same
  problem as an existing concern. If it is, add the evidence under that concern. If it is
  not similar enough to collapse, it is its own `Concern #N`. No sub-labels (`1.a`), no
  round numbers, no letter codes, no side-prefixed numbers.
- **Name the thing beside its label** — `Concern #4, the search loader ignores the filter`.
- **`Review:` and `Author:` say which session wrote a line.** They are not labels and
  carry no number.
- **One sentence per line, 30 words or fewer** (plan-structure.md "Writing rules"). A finding that
  needs more is not understood well enough to file. Point at a file and line and let the
  code carry the detail; repro recipes and query output go in the evidence file.
- **A new concern opens with `Problem:` and `Fix:` lines** per plan-structure.md's Concern shape.
  `Problem:` names a location and a concrete wrong result: input or state → what goes
  wrong. No repro means it is a question, and it is labeled as one.
- **Every later `Review:` line answers the author** with a location and a result.
- **Every `Author:` line names where the fix landed.** Nothing else counts as an answer.
- **Open with one `Checked, no findings` line** naming what you read and checked. What each
  check returned goes in the evidence file. It is not a concern and gets no number. A diff
  that is rotten top to bottom is a padded review.
- **A concern ends on one word** from the reviewer: `RESOLVED`, `RISK` (real, not proven,
  merging anyway), or `WITHDRAWN` (the author was right). The reviewer shrinks it in the
  same write, per plan-structure.md — the one time a session edits the other side's lines:
  - `WITHDRAWN` → delete the whole concern. No strikethrough, no note; its number is not reused.
  - `RESOLVED` → one line: `Concern #N, <name> — fixed at <file:line>`.
  - `RISK` → keep as written. That is the point of the label — it merges knowing.

Writing rules, because two sessions share the file:

- **Re-read the section immediately before every write.** The other side has moved.
- **Never edit or delete a line the other side wrote.** Correct your own line by rewriting
  it in place, never by adding a line below it.
- **Write your line, then stop and hand back one line to your terminal** — `Concern #14
  filed, their turn.` The engineer moves the other session. Do not wait or poll.

## If you are the reviewer

Read the ticket and the diff. **Do not read the author's session or reasoning** — the
engineer reading this in six months will not have it either. If the code does not say
what the author meant, that is a finding.

Your best line of attack is not the code. It is **what had to be true for the code to be
correct**: assumptions about the data, ordering, concurrency, who can call this, what the
API returns, what happens the second time. List those premises, then go check each one
against the repo.

Then the two shapes that do not show up in a diff — a change generalizing one case to
many, and a fix claim nobody reproduced. Full technique in the `bug-hunt` skill.

Sort by `code-review`'s buckets before you file. Bugs and risks go in the file.
**Preferences do not get filed at all** — in an adversarial pass they are the padding.

## Verify, don't read

Reading the code tells you what the author meant. Running it tells you what it does. An
`Review:` line built from reading is a guess wearing a file path. The project's private
`context/dev-loop.md`, if present, says how to run and query it.

- **Run the dev server backgrounded and read its stdout yourself.** Not the author's
  pasted output, not an inference from the code. Restart it after any schema or code
  change.
- **Query the dev DB directly — after finding out what it actually is.** Read the README
  first. An embedded or file-backed dev DB refuses the standard client for that engine,
  and the obvious CLI answers "nothing there," which reads exactly like "the bug is
  fixed."
- **Call the changed handler directly, bypassing the UI.** Reproduce on the base branch
  first. **A repro you never saw fail is not a repro.** Watch for handlers that re-run on
  retry — hitting one twice can double-apply a write.
- **Build fixtures with one direct write**, not by clicking through the UI. For anything
  repeatable, a small script against the project's own data layer. Stop the server first
  if the dev DB is single-writer.
- **Cross-check external APIs with raw curl against the published schema.** That is what
  separates "our bug" from "their API changed."
- **The browser is last.** Slowest and least precise instrument here, not the first one.

Caveat worth a `RISK` line, never a `RESOLVED` one: a dev DB that is not the production
engine **may not reproduce a real concurrency race.** A clean local run does not prove
that one is fixed.

## Where the holes actually are

Distilled from `code-review` and `ticket-planning`. Not the full checklists — these are
the items that produce findings in a hostile pass.

- **What else connects to this?** The generalization siblings live on lines the diff
  never touched, in files not in the PR. LSP find-references on the changed symbol, then
  grep the old constant or assumption for string and non-TS uses, and check every hit.
- **Every validation gate, in order** — client, schema, server handler, DB. A missing
  gate is a security finding. A disabled UI control is not a gate.
- **Server-side re-verification** — the write handler re-checks access itself and trusts
  no client-sent ID or flag state. Parameterized queries only.
- **On and off** — does the app work with the feature and without it? A flag gate has to
  hold at every layer: validation, UI, and write.
- **Edges and inputs** — how would you break or exploit this input, on purpose? Empty,
  huge, duplicate, out of order, twice at once.
- **Denormalized copies** — a name stored beside an ID needs every write path that keeps
  it in sync named. Create, edit, import, background job.
- **Transaction scope** — is one already open on this path, and did this open a second?
- **Migration order** — is there an outage window between the migration and the deploy?
  Is the down-path real, and was it run?
- **Existing usage is the spec.** A new pattern where the repo already has one is a
  finding; find a real call site (LSP references, or grep) before claiming either way.
- **The repo's own docs win.** An agent-instructions file or an ADR beats your opinion.
  Read them before filing a convention finding.
- **Ticket points quietly dropped** — re-read the ticket against the diff, last.

## Not a finding

Attack mode makes these tempting. File none of them:

- **Pre-existing** — it was broken before this branch. Check with git blame, don't assume.
  The one exception is the generalization sibling above: if this change made that line
  wrong, it is this PR's bug.
- **Caught by tooling** — types, lint, formatting, failing tests. CI says it better.
- **Deliberately silenced** — an ignore comment or a documented deviation. Read the
  reason and argue with the reason, or leave it.
- **Speculative** — "this breaks if someone later…" with no caller that does it today.
  Find the caller (LSP find-references) or drop it.
- **Repo-authoring conventions** — comment style, file layout, logger naming. Those are
  for code you write, not findings on someone else's diff.

Withdraw loudly and immediately when the defense is right. Your withdrawal count is the
only honest read on whether this review was worth running.

## If you are the author

You may push back and you may win. Agreeing with everything produces churn, not fixes.

- **No fixing by rewording.** A rename, a comment, or a reworded claim is not an `Author:` line.
- **A fix ships with the repro that failed before it.** If you never saw it fail, you
  have not fixed it — say so instead.
- **"Works on my machine" is not a defense.** Name what you ran.
- **Concede in one line and move.** No apology, no restating the finding back.

## The engineer has the last word

The engineer calls the end. Neither session declares victory or decides it has done
enough.

Anything still open when they call it goes to them as a short list: the concern, both
positions, one line each. They rule, and the ruling is written as the closing line.

## Closing out

Closed concerns have already shrunk as they closed. When the engineer calls it, one
session finishes the section:

- **Write each ruling as its concern's closing word**, and shrink it the same way.
- **Check nothing closed was left unshrunk.** A dead finding left in a planning file reads
  as open work to the next person.
- **Add one line: findings filed, resolved, withdrawn.** Three numbers.

## What earns a fight

Run it on migrations, access control, anything touching money or permissions, anything
generalizing one case to many, and anything where being wrong is expensive to undo. Run
it on everything and you will stop running it.
