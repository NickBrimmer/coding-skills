---
name: do
description: The engineer's go-ahead, in one word. With no argument it approves the most recent proposal printed in this conversation, exactly as shown, and carries it out. With an argument it is either an answer to that proposal's open decision ("b", "a, and drop step 3") or a new task described in place, done now without a planning round trip. Use only when the engineer types /do. Never invoke it on your own — running it is the authorization.
disable-model-invocation: true
---

# Do

The engineer has read what was proposed, or has just described the task, and wants it
done. This skill is that approval. Work it in one pass and hand back one short report.

**The proposal is the ask.** Do exactly what it showed, no more (§0a, §8). Anything
extra found on the way is recorded or offered in one line, not built.

**Approval never covers** committing, pushing, approving or merging, or anything
destructive the proposal did not show — those stay the engineer's (§0, and the private
`CLAUDE.md`). Approval for this proposal does not carry to the next one.

## 1. Work out what is approved

Read the argument, then the conversation, in this order:

| What is there | What runs |
| --- | --- |
| No argument, a proposal is pending | The most recent proposal, exactly as printed |
| An argument that answers or amends that proposal ("b", "use X instead") | The proposal with that change |
| An argument that describes something else | That description, as the whole ask |
| No argument, nothing pending | Nothing — say so in one line and stop |

A proposal is pending if it was printed in this conversation and has not run yet.

- **The proposal is a planning file's implementation steps** → follow the `start-coding`
  skill from its §1; this approval stands in for invoking it.
- **The proposal left a lettered decision open** → take the option it suggested, and name
  that in the report. No suggestion was given → ask that one question and stop.
- **Something changed since the proposal was printed** (the target was edited, the
  branch moved) → show what changed in one line and stop.

## 2. Do it

- **Local work** (source edits, files, notes): do it, then run the checks the repo's
  agent-instructions file names when source changed.
- **An outward-facing write** (a tracker edit, an MR description or comment, a chat
  message): run it only if its exact draft was shown in the proposal. A described task
  that needs one → do the local work, then show the draft in the shape of
  `ticket-planning/references/action-plan.md` and stop. `/do` again runs it.
- **Back up before overwriting.** Read the result back afterwards.
- **A ticket's planning file exists** → record what ran and what was found as it
  happens (`plan-structure.md`, Record as you go).
- **Stop early** only when the next action is outside this approval or a finding makes
  the rest wrong. Record why, then report.

## 3. Report

Five lines or fewer:

```
Done: <what ran> [ran: <read-back or check result>]
Took: option (a), as suggested
Not done: <anything stopped or skipped, and why>
Needs you: <commit, push, or the next decision>
```

Leave out any line with nothing to say. Do not repeat the draft back; name where it went.
