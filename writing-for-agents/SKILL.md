---
name: writing-for-agents
description: Style guide for text an agent will read — skills, CLAUDE.md or AGENTS.md, working-agreement sections, hook messages, planning files, retro suggestions. Use before writing or editing any of these, when proposing a new rule or skill, or when another skill says to load it.
---

# Writing for Agents

An agent reads every word, every time, with no one to ask. Write so the one reading it
cold acts right on the first try, at the lowest token cost.

## Put it in the right place

| Text | Goes in | Why |
| --- | --- | --- |
| A rule a script can check | A hook, linter, or CI job | A check never forgets; prose does |
| Where to find something | One pointer in `CLAUDE.md` / `AGENTS.md` | Those load every session; keep them small |
| A judgement call for review | The review checklist | The reviewer has the least context pressure |
| A how-to for one kind of task | A skill, or a skill's `references/` file | Loaded only when the task matches |
| A fact about one project | The private context folder | This repo is public (`ticket-planning/references/project-context.md`) |

One rule lives in one place. Elsewhere, point to it — never copy it.

## The description is the trigger

- A skill's `description` is the only part loaded until it matches. Write it the way
  the engineer would ask out loud, with the trigger phrases they use.
- Say what it does, then "Use when …". Say what it does not do if a nearby skill does it.
- User-only commands: `disable-model-invocation: true` and "Use only when the engineer
  types /x."

## Writing rules

- **Commands, not essays.** Each line is something to do or a fact to act on.
- **Short.** One idea per line. Plain words, short sentences.
- **Pointers over inlining.** More than a line of context → `file.md:12` or a heading name.
- **Say the why once, in one line,** when a rule would look wrong without it.
- **Tables for choices.** "If X → do Y" beats a paragraph of cases.
- **Show the output shape** in a code block when the result has a fixed form.
- **Placeholders in examples:** `TICKET-123`, `app/x.tsx`, `acme`.
- **No narrative.** No names, dates, or how the rule came to be.

## Cut what does nothing

Before adding a line, ask: would an agent act differently without it? If not, cut it.

- Restating default behaviour ("be careful", "write good code").
- A rule already enforced by a check.
- A rule repeated from another file — replace it with a pointer.
- A dead idea or a past attempt.

## Error and hook messages

A message an agent sees mid-task says what happened, why, and the next step. A setup
problem never reads like a content problem.
