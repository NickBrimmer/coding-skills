---
name: handoff
description: Make the planning file hold everything this session knows, so a fresh session can resume from it alone. Sweeps this chat and Claude's auto-memory for anything not yet written down, records it in the ticket's planning or review file, deletes dead ideas, rewrites the Status block, and prints a one-line resume prompt. Use only when the engineer types /handoff. Never invoke it on your own.
disable-model-invocation: true
---

# Handoff

The engineer is about to leave this session — a clear, a compaction, a model switch, or
the end of a stretch of work. Anything that exists only in chat or in auto-memory is lost
when they do. Get it into the planning file, then stop.

**The file is the handoff.** No separate handoff document. The next session reads the
file's `## Status` block and carries on.

**Never commit or push.** Print the git commands; never run them.

Read before starting:

- `~/.claude/skills/ticket-planning/references/plan-structure.md` — every write follows it.
- `~/.claude/skills/ticket-planning/references/project-context.md` — where `plans/` and
  `reviews/` live.

Examples use `TICKET-123` and `app/x.tsx`.

---

## 1. Find the file

| What is there | File |
| --- | --- |
| An argument with a ticket key (`/handoff TICKET-123`) | That ticket's file in `plans/` or `reviews/` |
| No argument, branch starts with a ticket key | That key's file, found the way `start-branch` §3 does |
| No key anywhere | A new file in `plans/` with a new local key, e.g. `local-<slug>.md`, in `start-branch` §3's shape |

Name the file in the report. A key with no file yet → create it in the same shape.

## 2. Read the state

Quietly, without narrating:

- The planning file, whole.
- `git status -sb`, `git log -1 --oneline`, `git diff --stat`, `git diff --cached --stat`.
- Any background process this session started and left running.

## 3. Sweep for what is missing

**This chat.** Each of these that the file does not already hold:

- A finding that would change what the engineer does.
- An answer or decision the engineer gave.
- A `[my call]` made without the engineer.
- Work deferred, and checks only a person can run.
- A claim not yet checked — tagged `[unverified]`.
- The step in progress and where it stopped.

**Auto-memory.** The project's memory folder under `~/.claude/projects/`:

- A fact about this ticket → move it into the planning file.
- A process rule → offer a change to `working-agreement.md` or a skill in one line
  (working agreement §5). Do not write it.

## 4. Write it in

- Each item goes where `plan-structure.md` "Record as you go" puts it. Edit in place;
  never append a session log.
- Results, not reasons. The code explains itself. A why goes in only when it is needed,
  and then as one line.
- **Delete dead ideas** — dropped options, withdrawn concerns, failed approaches. No note,
  no strikethrough. A later session reading a dead idea treats it as open work.
- Resolved questions compact to the answer and a pointer.
- Strip dates, names, and placeholders.

## 5. Rewrite Status

Five lines at most, per `plan-structure.md`:

- Line one: the commit and the single next action.
- What is uncommitted, in one line.
- The suggested next skill and model tier (working agreement §6), e.g.
  `/start-coding, medium tier`.
- Anything waiting on the engineer.

## 6. Check

- Run the two awk checks in `plan-structure.md` "Length check". Fix every hit.
- **Cold-read test:** read only the header and `## Status`. If they do not say what to do
  next and where, fix them.
- Nothing was missing → edit nothing and say so.

## 7. Report

Five lines or fewer:

```
File: <path> — Concern #7 added, Status rewritten, 2 dead options deleted
Memory: 1 process rule found — suggest adding to working-agreement §1
Uncommitted: 3 files
Still running: dev server on :3000
Resume with: Read <path> ## Status, then continue.
```

Leave out any line with nothing to say.
