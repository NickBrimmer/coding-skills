---
name: start-branch
description: Set up a new branch to start coding on — create or confirm the branch, read the ticket, and create or reopen the ticket's planning file in the project's private planning folder so every later session shares the same notes. Use when the user says they are starting a branch, starting a ticket, picking up a ticket by its key, kicking off new work, or asks to set up a branch. Stops once setup is done; it does not plan or write code.
---

# Start Branch

Get a branch ready to work on and stop. The output is a branch, a planning file, and a
short readout. Planning is `ticket-planning`; code comes after that.

**Setup, not a start.** Hand back the readout and wait. A ticket key is not
authorization to plan in depth or edit source files.

**Project specifics come from context.** The ticket-key pattern, tracker and MR tools,
trunk name, and file naming live in the project's `context/tracker.md` — see
`~/.claude/skills/ticket-planning/references/project-context.md`. Examples below use
`TICKET-123` and `main`; substitute the project's own.

---

## 1. Find the ticket and the branch

- **Given a ticket key** (`TICKET-123`) and not already on a branch for it: confirm the
  working tree is clean (`git status -sb`), `git fetch origin`, then create the branch off
  the trunk (`origin/main`) named per `tracker.md`; default `TICKET-123-<slug>`, the slug
  3–6 kebab-case words from the ticket summary. Dirty tree → stop and ask; never stash
  someone's work to make room.
- **No key given:** use the current branch. Pull the key from its name using the
  project's key pattern. No key in the name → ask for it. Never guess a ticket.
- **On the trunk with no key:** ask what the branch is for.

## 2. Read the ticket

Use the tracker skill or CLI that `tracker.md` names. Read the ticket in full, with its
recent comments, before writing anything. If it has a parent epic, note it and list its
siblings — a sibling may already have a plan this one depends on.

## 3. Create or reopen the planning file

Path: the project's private `plans/` folder, named per `tracker.md`; default
`ticket-123-<slug>.md` (lowercase key, same slug as the branch). Follow
`~/.claude/skills/ticket-planning/references/plan-structure.md` — its structure, labels,
and writing rules win over anything here.

**Look before creating.** Search the private planning folder for the key, case-insensitive
— a plan may already exist under another name, or in an older location `tracker.md` lists.

- **Exists:** reopen it and amend in place. Never create a second file, never append a
  dated session log.
- **New:** write only what the ticket supports:

```markdown
# TICKET-123 — <ticket summary>

**Branch:** `TICKET-123-<slug>` off `main` @ `<short sha>`
**Ticket:** TICKET-123 · **Epic:** <epic key, or none>
**Depends on:** / **Blocks:** (epic tickets only)

## Goal
<one sentence. Can't write it → the ticket is under-specified; say so as a blocker.>

## Scope
<every explicit requirement from the ticket, as a DOD checklist>

## Existing code to build on

## Open questions
<⛔ STOP GATE table: question · who resolves it · what changes if the answer surprises.
Garbled, missing, or contradictory ticket text goes here — never guessed at.>

## Tests Required

## Notes
```

Leave sections empty rather than fill them from inference. `ticket-planning` fills them
from the code.

## 4. Hand back

Three to five lines:

- Branch name and the SHA it is based on.
- Planning file path, and whether it was new or reopened.
- The goal sentence, and any blockers found in the ticket.
- Offer `/ticket-planning` as the next step.

Then stop.
