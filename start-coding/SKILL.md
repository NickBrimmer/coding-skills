---
name: start-coding
description: The engineer's go-ahead to implement a recorded plan — work the planning file's implementation steps in one uninterrupted pass, record every finding, decision and new question into the planning file as it happens, run the checks, then print what was done, what was found, and what still needs the engineer. Use only when the engineer invokes it or says to start coding, begin the build, implement the plan, or that they approve the plan. Never invoke it on your own — running it is the authorization.
---

# Start Coding

The engineer has read the plan and likes it. This skill is their approval to edit source
files against it — `working-agreement.md` §4's third step. Work every step in one pass,
**without stopping to ask**, and hand back one report at the end.

**The plan is the ask.** Build its steps and nothing else (§0a, §8). Anything the plan
does not cover is recorded, not built.

**Approval covers source edits only.** It never covers committing, pushing, approving or
merging, or anything destructive — those stay the engineer's (§0, and the private
`CLAUDE.md`). The engineer commits.

**This is execution work** (§6). If the session is on the higher tier, say so in one line
at the start and carry on; switching is the engineer's call.

Read before starting:

- `~/.claude/skills/ticket-planning/references/plan-structure.md` — every write to the
  planning file follows it.
- `~/.claude/skills/ticket-planning/references/project-context.md` — `context/dev-loop.md`
  for how to run and query the project, `context/conventions.md` for authoring and
  pre-merge rules. A missing file means the generic step runs.
- The repo's own agent-instructions file and the docs the plan's verification section
  names. They win over the plan on conflict — record the conflict and follow the doc.

Examples use `TICKET-123`, `main` and `app/x.tsx`.

---

## 1. Preflight

Find the planning file the way `start-branch` §3 does. Then check, in order:

- **On the plan's branch**, and `git status -sb` shows only changes the plan's Status
  accounts for. Anything else → stop; never stash or discard someone's work.
- **Steps exist.** No `Implementation steps` section → stop and offer `/ticket-planning`.
- **Which steps run.** Default: every step. An argument narrows it (`/start-coding 1-5`,
  `steps 2 and 4`). A step that waits on an open STOP GATE row, an unmerged dependency or
  an unanswered question is **skipped** — list it now, and keep going with the rest.
- **The base has not moved under the plan.** The plan's header names a SHA. If the
  branch is elsewhere, every `file:line` is a hint, not an address — §2 handles it.

A git step the plan names explicitly (a fast-forward, a rebase onto a merged dependency)
may run. If it does not apply cleanly, abort it, record a `Concern`, and stop — every
later line depends on it.

Write the Status block's first line before the first edit: `At <sha>. start-coding
running: Steps 1–9; skipping 6 (waits on !N).`

## 2. Work each step

Lowest-numbered first, unless the plan orders them otherwise. For each step:

1. **Re-read the step and every Concern it points at.** The Concern holds the why.
2. **Re-find each location by its quoted code or symbol, not its line number.** Found
   and unambiguous → edit there. Changed shape, or two candidates → skip that part and
   record it (§3).
3. **Make exactly the change the step describes.** A new file starts from its nearest
   neighbour, as `ticket-planning` Phase 9 says. Comments follow §9.
4. **Write or update the tests the plan's `Tests Required` lists for this step**, then run
   the narrowest set that covers the change. Red because of this change → fix it now.
   Red before the change too → confirm on the base commit in a throwaway worktree, record
   it as pre-existing, do not fix it.
5. **Tick the step in Status**, or mark it partial with a pointer to the Concern that
   explains why. Then the next step.

Do not batch the recording for the end. A crash at step 6 must leave steps 1–5 legible
in the file.

## 3. When something comes up — record, decide, continue

No question goes to the engineer mid-pass. Each one goes into the planning file, gets a
default, and the pass moves on.

| What came up | Record as | Then |
| --- | --- | --- |
| A bug or risk in the code or the plan | `Concern #N`, continuing from the highest number in the file | Fix it only if it is inside the current step |
| A choice the plan does not settle | The plan's stated default, else the smallest change that satisfies the ticket's words, tagged `[my call]` | Build that, keep going |
| A choice that cannot be undone by editing the diff — schema, data written, a public contract, a deleted file | A question under `## Open questions` | Skip that part of the step |
| Work the plan does not include | `Follow-up:` under `## Notes` | Do not build it |
| Something only a person can check | `Browser check:` under `## Tests Required` | Keep going |
| A doc or convention that contradicts the plan | A `Concern` naming both | Follow the doc |

Every line follows plan-structure.md: 30 words, `Problem:` / `Fix:`, evidence tags.
Check before calling something `[ran]` — §2a.

**The only reasons to stop early:** §1's preflight fails; a plan-named git step does not
apply cleanly; the next action needs something this approval does not cover (§0, a push,
anything destructive); or a finding makes every remaining step wrong. Then record why,
and go straight to §5.

## 4. Close out the pass

After the last step runs:

- **The project's full check, format and test commands**, from the agent-instructions
  file or `context/conventions.md`. Report the real result. A failure caused by this pass
  gets fixed; one that cannot be fixed inside the plan becomes a `Concern`.
- **The plan's Implementation verification list**, every item that can run without a
  browser: generalization audits, direct handler or API calls, dev server log checks.
  The `bug-hunt` skill has the technique. Items needing a person stay `Browser check:` lines.
- **Debris:** no stray debug logging, no leftover scaffolding, no commented-out code.
- **`git status`** — a changed lockfile with no manifest change is flagged, and I would
  suggest restoring it (§11). Nothing committed.
- **Rewrite the Status block** to the pass's end state, five lines at most.

## 5. Report

The planning file is current before this is printed. Keep it to one screen:

```
## start-coding — TICKET-123 at <sha>

Done: Steps 1–5, 7, 8 [ran: check, format, tests pass]
Partial: Step 9 — clear-X done; empty list skipped, Concern #16
Skipped: Step 6 — waits on !N
Checks: <check> ✓ · <format> ✓ · <tests> 412 passed, 1 pre-existing failure (Concern #17)

Findings
- Concern #16, <name> — <one line>

Needs you
- <question> — I took <default> `[my call]`; changing it means <what>

Browser checks
- <what to do> → <what to see>

git status: 9 files modified, no lockfile drift, nothing committed
```

- **Done / Partial / Skipped** cover every step selected in §1. Nothing goes unaccounted for.
- **Needs you** holds every new question and every `[my call]`, each with the default taken.
- **Suggest the next step in one line** — `/walkthrough-changes` for the browser checks,
  `/code-review` for a self-review — and stop. Do not run either.
