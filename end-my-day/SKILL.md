---
name: end-my-day
description: Close out the work day — capture what to remember for tomorrow, confirm the workspace is clean, note who to check in on, add what you learned to the coding ledger, and collect anything worth raising in retro. Writes it all to tomorrow.txt so the next session can pick it up. Use when the user says they are done for the day, wrapping up, signing off, shutting down, or asks to end their day.
---

# End My Day

Five questions, asked one at a time. The output is the project's private `tomorrow.txt`
that `start-my-day` reads back.

**Never ask a question cold.** Read the repo state first and open each question with a
draft answer. The user edits a draft in one line; composing from nothing takes five
minutes and gets skipped. A day that ends with a skipped question is a day the file
lies about.

**Never commit or push anything.** Ending the day is not permission to write history.
Leave the tree dirty and say what is uncommitted.

---

## 1. Read the state first

Before the first question, gather quietly — don't narrate this part:

- `git status -sb` — branch, staged, unstaged, untracked.
- `git log --oneline -10` — what landed.
- `git diff --stat` and `git diff --cached --stat` — what is half-done.
- Any planning file in the project's planning directory that changed today.
- Stray debug artifacts in the diff: a scratch `console.log`, a commented-out block, a
  hardcoded test value, a skipped test. These are the most common "I meant to clean that
  up" item.
- Any background process this session started and left running.

## 2. Ask the five

One at a time. Wait for each answer. Lead each with what you found.

1. **What do you need to remember for tomorrow?**
   Draft it from the uncommitted diff and the last thing that was being worked on. Name
   the file and the exact next action, not the topic. "Pick up the loader work" is
   useless tomorrow; "`app/routes/x.tsx:88` — the loader still returns the unfiltered
   list, filter goes in before the map" is not.

2. **Did you clean your physical and digital workspace?**
   List what you actually found: the debug artifacts from the scan, uncommitted files,
   background processes still running, open scratch files. Offer to remove the debug
   artifacts now. Leave the physical half to the user — just ask.

3. **Is there anyone or anything you need to check in on?**
   Draft from the day: an unanswered question, a PR waiting on review, a handoff to
   someone, a job or deploy that was still running.

4. **Did you learn anything to add to your coding ledger?**
   Look for the moment something was wrong and got corrected — a wrong assumption about
   an API, a convention discovered mid-task, a bug whose cause was not where it looked.
   A ledger entry is the lesson, not the story: what to do differently next time.
   Appends to `~/Developer/planning-files/coding-ledger.md` (private, never in a repo). Create that file if missing.

5. **Did anything happen today that you want to bring up in Retro?**
   Friction, not tasks: a slow pipeline, a flaky test, a blocked hour waiting on access,
   a process that made the work harder than the work.

Any question can be answered "no." Write nothing for it — do not invent a line to fill a
section.

## 3. Write the file

`~/Developer/planning-files/<project>/tomorrow.txt` — private, out of the repo, so it is never committed (see `ticket-planning/references/project-context.md`). Rewrite it whole every evening — never append. A stale
line left from last week reads as live work and costs someone a morning.

```
Updated: 2026-09-17
Branch: feature/skills-repo

PICK UP HERE
- app/routes/x.tsx:88 — loader returns the unfiltered list, filter goes before the map
- 3 files uncommitted, nothing staged

CHECK IN ON
- PR 412 still waiting on review

RETRO
- CI took 20 minutes to tell me about a lint error
```

Rules for the file:

- **Plain text, no markdown syntax.** It gets read in a terminal and by the next session.
- **Every "pick up" line names a file and line.** A line with no location is a topic, not
  a task.
- **Drop a section with no content.** An empty heading is noise.
- **The date line is the only date in the file.** It exists so `start-my-day` can tell
  you the file is stale. It is not a log — yesterday's version is gone.

## 4. Close out

Tell the user in three lines or fewer:

- Where the file is.
- What is uncommitted, and the exact `git` commands if they want to commit. Print them;
  never run them.
- Anything still running that they may want to stop.
