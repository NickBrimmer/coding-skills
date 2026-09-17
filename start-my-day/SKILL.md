---
name: start-my-day
description: Open the work day — read tomorrow.txt for what was left in flight, check it against the current repo state, and turn it into a short plan for the day with a concrete first action. Use when the user says they are starting work, picking back up, getting going, or asks what they should work on, what is on the plate today, or to start their day.
---

# Start My Day

Read what last night left, check whether it is still true, and hand back a short plan.

**The plan is a proposal, not a start.** Present it and stop. Do not begin the first task
until the user says go — the morning's real priority often is not in the file.

---

## 1. Read tomorrow.txt

`tomorrow.txt` in the repo root, written by `end-my-day`.

- **Missing?** Say so in one line and build the plan from repo state alone (step 2).
  Offer `end-my-day` for tonight. Do not create an empty one.
- **Stale?** Compare the `Updated:` line to today. More than three days old, say so
  before anything else — the items are probably dead, and a stale file is more dangerous
  than no file.

## 2. Check the file against reality

The file says what was true last night. Verify each claim before repeating it back:

- **The branch.** Still exists? Still checked out? Someone may have merged it.
- **Every file and line it names.** Read them. If a "pick up here" line points at code
  that already has the fix, the work landed — say so and drop the item.
- **The working tree.** `git status -sb`. Does the uncommitted work it describes still
  exist? A cleaned tree means it was committed or lost.
- **What moved underneath.** `git log --oneline -15` and whether the branch is behind.
  Work merged overnight can make a planned task wrong.

Report each item as **still live**, **already done**, or **changed** — with the reason.
Never repeat a line back as live without opening the file it names.

## 3. Pull in the rest

- **The active planning file**, if the project has one. Its stop-gate or checklist is the
  real source of what is next; `tomorrow.txt` is only the last session's handoff.
- **Check-in items** from the file — a PR waiting on review, a question left unanswered,
  a job left running. These are usually faster than the code work and block other people.
  They go first.
- **Anything actually running** that got left up overnight.

## 4. Hand back the plan

Short. Three items at most — a list of ten is a list nobody follows.

- **Order it:** things blocking other people, then the one real task, then the rest.
- **Name the first action as a command or a file and line**, not a topic. The plan
  succeeds if the user can act on line one without deciding anything first.
- **Say what you dropped and why** in one line. An item that quietly vanishes will get
  re-planned next week.
- **Flag anything the file assumed that is no longer true**, loudly. That is the whole
  reason to check before planning.

Then stop and wait.
