---
name: check
description: Look before acting. The engineer describes a task after /check; investigate it read-only, then print a proposal in the action-plan shape (what was checked, the one decision first, numbered steps, the exact draft) and stop for approval. Pairs with /do, which runs the proposal. Use only when the engineer types /check. Never invoke it on your own.
disable-model-invocation: true
---

# Check

The engineer has described something and wants to see the plan before anything changes.
The argument is the task. Investigate it, print the proposal, and stop.

**Read-only.** Read code, tickets, MRs, logs; run tests, queries, dry-runs and dev-server
probes. Do not edit source, write to a tracker or MR, post a message, or run git that
moves history. The one write allowed: back up anything the proposal would overwrite to
the scratchpad, so the plan can name the backup path.

**Record as you go.** A ticket's planning file is still written before the report
(`plan-structure.md`, Record as you go). That is bookkeeping, not acting on the task.

No argument → ask what to check, in one line, and stop.

## 1. Investigate

- Read the governing ticket in full when there is one (§13).
- Check, don't label (§2a). A premise a cheap command can settle gets the command.
- Compare like with like: what the source of truth says against what the target holds.
  Every gap gets a pointer — `file:line`, a ticket section, a commit.
- A finding outside the task is noted for the report, not chased.

## 2. Print the proposal

Follow `~/.claude/skills/ticket-planning/references/action-plan.md` exactly:

1. **What I checked** — sources with evidence tags; backup paths.
2. **Decide first** — the one decision, lettered options, a suggestion. None → omit.
3. **Plan of action** — numbered, one line each, ending in a read-back; what is untouched.
4. **The exact draft** — the edit, description or message itself, verbatim.
5. **Close** — one line: `/do` runs it as shown; `/do b` takes option (b).

Nothing needs changing → say so in one line, with what was compared, and stop.

## 3. Stop

Wait. The engineer's `/do`, or their words, is the approval. Do not start on a guess.
