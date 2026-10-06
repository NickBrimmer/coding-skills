---
name: start-review
description: Set up a review of someone else's branch or merge request — check out the branch, read the ticket and the MR or PR, run the tests, and create or reopen a review file in the project's private planning folder that records the reviewed commit so later sessions can pick up where this one stopped. Use when the user asks to review a teammate's branch, MR or PR, starts a review, picks up an MR or PR number, or asks to get a review set up. Stops once setup is done; the review itself is code-review.
---

# Review Branch

Get a review ready and stop. The output is the branch checked out, a review file with a
handoff block, and a test result. The review itself is `code-review`.

## HARD RULE: never approve, never merge

No approve, no merge, no route to the same effect — through a CLI, an API, or the web UI.
The engineer clicks those. Posting a comment on the MR also waits for their go-ahead.

**Not your code.** The Phase 7 items in `ticket-planning` and the project's
`context/conventions.md` are authoring defaults for the engineer's own code — never raise
one as a finding on someone else's diff.

**Project specifics come from context.** The tracker and MR tools, ticket-key pattern,
trunk name, install and test commands, and file naming live in the project's
`context/tracker.md` — see `~/.claude/skills/ticket-planning/references/project-context.md`.
Examples below use `TICKET-123`, `!123` and `main`.

---

## 1. Find the MR and the branch

Use the MR skill or CLI that `tracker.md` names. Given an MR number, read its source
branch; given a branch, find its MR.

- Working tree must be clean (`git status -sb`). Dirty → stop and ask.
- `git fetch origin && git switch <branch>` (or `git pull --ff-only` if already on it).
- Record: HEAD short SHA, author, commits ahead of and behind the trunk
  (`git rev-list --left-right --count origin/main...HEAD`).

Pull the ticket key from the branch name using the project's key pattern. None → ask.

## 2. Read the ticket and the MR

- The ticket, with recent comments, through the tracker `tracker.md` names.
- MR description, reviewers, pipeline status, and **every existing discussion**. A
  concern someone already raised is not a new finding.
- The ticket's own plan, if one exists: search the private planning folder for the key.
  The author's plan is the spec the diff is checked against.

## 3. Install and run the tests

1. The project's install command (`tracker.md`, else the README).
2. **Lockfile drift:** `git status --short`. A lockfile changed with no manifest change →
   flag it and suggest restoring the lockfile. It also blocks step 4's switch.
3. Run the repo's test script (read the manifest's scripts — don't assume the name).
   Record pass/fail counts and the failing test names.
4. **Something failed → run just those tests on the trunk.** `git switch --detach origin/main`,
   rerun the failing files, `git switch -` back. Fails on the trunk too → pre-existing,
   not the author's. Passes on the trunk → the branch broke it. That difference changes
   what gets written to the author.

## 4. Create or reopen the review file

Path: the project's private `reviews/` folder, named per `tracker.md`; default
`review-ticket-123-<slug>.md`, slug from the branch name. Follow
`~/.claude/skills/ticket-planning/references/plan-structure.md` — its labels and writing
rules win over anything here.

- **Exists:** reopen it. Update the header and Handoff Status in place. If the reviewed
  SHA moved, `git diff <old sha>..HEAD --stat` is what's new since the last session — say
  so in the hand-back, not the file.
- **New:**

```markdown
# Review: TICKET-123 — <ticket summary>

**Branch:** `<branch>` @ `<sha>`, <N> ahead / <M> behind the trunk
**MR:** !<iid> · **Ticket:** TICKET-123
**Spec:** <the ticket, or the path to the author's plan>

## Handoff Status
**Tests:** <pass/fail counts; each failure marked branch-caused or pre-existing>.

## Goal
<the ticket's purpose in one sentence>

## Open questions

## Notes
```

Concerns go under `## Notes` as `Concern #1, <name>`, in the `Problem:` / `Fix:` shape.
No checklist letter codes, no round numbers, no diff stat — the MR shows the diff. Local
setup done for the review (data seeded, flags granted) goes in the `evidence/` folder.

## 5. Hand back

Three to five lines: MR and reviewed SHA, test result (with any branch-caused failures
named), anything already raised in discussions, the review file path. Offer `/code-review`
as the next step, and `/adversarial-review` if the change touches migrations, access
control, or money.

Then stop.
