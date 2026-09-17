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

- Wrote the code in this session → you are **D**, the author.
- Arrived to review it → you are **A**, the challenger.

Unclear? Ask the engineer in one line. Do not guess — both sides attacking gets nothing
fixed.

## The ticket file is the channel

Append to a `## Adversarial Review` section in the ticket's planning `.md`. There is no
other channel. The two sessions cannot talk.

```
## Adversarial Review

A0  read: the diff + every caller of applyFilter. Access checks and the migration look right.
A1  loader ignores the filter — POST /search with q="" returns all 4k rows  (app/x.tsx:88)
D1  client guard added, app/x.tsx:88
A1  still open — x.server.ts:22 takes the same call with no guard
D1  server guard at x.server.ts:22; repro fails on main, passes here
A1  RESOLVED
```

Format, no exceptions:

- **`A` or `D`, plus the thread number.** Same number the whole thread. New problem, new
  number.
- **One or two lines.** A finding that needs a paragraph is not understood well enough to
  file. Point at a file and line and let the code carry the detail.
- **Every `A` line names a location and a concrete wrong result.** Input or state → what
  goes wrong. No repro means it is a question, and it is labeled as one.
- **Every `D` line names where the fix landed.** Nothing else counts as an answer.
- **`A0` is the opening move**: what you read, and what you checked and found correct. A
  diff that is rotten top to bottom is a padded review.
- **A thread ends on one word** from the challenger: `RESOLVED`, `RISK` (real, not
  proven, merging anyway), or `WITHDRAWN` (the defense was right).

Writing rules, because two sessions share the file:

- **Re-read the section immediately before every write.** The other side has moved.
- **Append only. Never edit or delete a line the other side wrote.**
- **Write your line, then stop and hand back one line to your terminal** — `A3 filed,
  their turn.` The engineer moves the other session. Do not wait or poll.

## If you are A, the challenger

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
`A` line built from reading is a guess wearing a file path.

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
  never touched, in files not in the PR. Grep the old constant or assumption and check
  every hit.
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
  finding; grep a real call site before claiming either way.
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
  Find the caller or drop it.
- **Repo-authoring conventions** — comment style, file layout, logger naming. Those are
  for code you write, not findings on someone else's diff.

Withdraw loudly and immediately when the defense is right. Your withdrawal count is the
only honest read on whether this review was worth running.

## If you are D, the author

You may push back and you may win. Agreeing with everything produces churn, not fixes.

- **No fixing by rewording.** A rename, a comment, or a reworded claim is not a `D` line.
- **A fix ships with the repro that failed before it.** If you never saw it fail, you
  have not fixed it — say so instead.
- **"Works on my machine" is not a defense.** Name what you ran.
- **Concede in one line and move.** No apology, no restating the finding back.

## The engineer has the last word

The engineer calls the end. Neither session declares victory or decides it has done
enough.

Anything still open when they call it goes to them as a short list: the thread, both
positions, one line each. They rule, and the ruling is written as the closing line.

## Closing out

When the engineer calls it, one session collapses the section:

- **Delete every `WITHDRAWN` thread entirely.** No strikethrough, no note. A dead finding
  left in a planning file reads as open work to the next person.
- **Collapse each `RESOLVED` thread to one line**: the problem and where the fix landed.
- **Keep every `RISK` line as-is.** That is the point of the label — it merges knowing.
- **Add one line: findings filed, resolved, withdrawn.** Three numbers.

## What earns a fight

Run it on migrations, access control, anything touching money or permissions, anything
generalizing one case to many, and anything where being wrong is expensive to undo. Run
it on everything and you will stop running it.
