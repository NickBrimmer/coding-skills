---
name: soft-diff-plan
description: There appears to be a rebase or conflict issue between this branch and the base branch. Do a soft-diff against the base branch and create a plan to seek the engineer's approval before merging. Read-only — never merges or rebases without approval. Use when the engineer types /soft-diff-plan, says the branch is behind or out of date with its base, or asks what would conflict before a rebase or merge.
disable-model-invocation: true
---

# Soft Diff Plan

The engineer's words for this skill: "There appears to be a rebase or conflict issue between
this branch and the base branch. Please do a soft-diff against the base branch and create a
plan to seek my approval before merging. Do not merge or rebase without my approval."

**Read-only until approved.** No `merge`, `rebase`, `cherry-pick`, `reset`, `stash`,
`checkout` of another branch, or push. `git fetch` is allowed. A "soft diff" is every
comparison that leaves the working tree and history exactly as they were.

**Record as you go.** The ticket's planning file gets the result before the engineer hears
it (`ticket-planning/references/plan-structure.md`, Record as you go).

Examples use `main` and `TICKET-123`; the project's trunk name is in `context/tracker.md`.

## 1. Establish the two sides

- `git status -sb` — note uncommitted work; a rebase or merge would need it committed or
  stashed, and that is the engineer's call.
- `git fetch origin`, then the base: the branch's planning file header, else the trunk.
- `git merge-base HEAD origin/main`; count both ways with
  `git rev-list --left-right --count HEAD...origin/main`.
- Base moved since the planning file's SHA → every `file:line` in it is a hint.

## 2. Soft diff

- **Incoming:** `git log --oneline HEAD..origin/main` and
  `git diff --name-status HEAD...origin/main`.
- **Ours:** `git diff --name-status origin/main...HEAD`.
- **Overlap:** files in both lists. These are where conflicts can happen.
- **Trial merge without touching anything:** `git merge-tree --write-tree HEAD origin/main`.
  Exit 0 = clean; otherwise it lists each conflicted file. Read the conflict hunks it reports.
- **Uncommitted work:** check the same overlap against `git diff --name-only` too.
- **Silent collisions:** a clean merge is not proof. For each overlapping file, grep for
  both sides' key symbols — a renamed function, a moved export, a changed signature one
  side still calls (`ticket-planning` Phase 4, Parallel Branch Merge Risk).
- Lockfile or migration changes on either side get their own line.

## 3. Plan

For each conflicted or overlapping file: what each side changed, the resolution
(keep ours, keep theirs, combine — and how), and the check that proves it. Then:

- **Decide first:** rebase or merge, with a suggestion. Note that a rebase of a pushed
  branch needs a force-push, which is the engineer's (§0b in the private file).
- **Steps:** numbered, one line each — commit or keep uncommitted work, the git command,
  each file's resolution, the project's check/format/test commands, a read-back
  (`git log --oneline -5`, `git status`).
- **Not touching:** anything left as is.

Write it to the planning file as a `Concern`, then print it in the
`ticket-planning/references/action-plan.md` shape.

## 4. Stop

Wait for the engineer's approval in their words (or `/do`). Approval covers the merge or
rebase shown, never the push.
