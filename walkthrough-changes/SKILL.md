---
name: walkthrough-changes
description: Write a step-by-step browser walkthrough of a branch or merge request — setup and prerequisites first, then rough URL by rough URL what to click and what to look for — and watch the dev server logs while the engineer walks it. Use when the user is about to click through a branch, MR or PR in the browser, asks for a manual test script or QA walkthrough, asks what to click and look for, or wants to check a branch's features end to end. Produces the script and watches logs; it does not drive the browser or change source.
---

# Walkthrough Changes

Produce a script the engineer follows by hand, then stay on the logs while they do. The
output is a prerequisites list, a freshly restarted dev server whose logs you can read,
and an ordered checklist. You do not edit source, drive the browser, or approve or merge
anything.

Read `~/.claude/skills/ticket-planning/references/project-context.md` for where private
project context lives. Use `context/dev-loop.md` for the dev server, database and
feature-flag commands, and `context/tracker.md` for the trunk name. A missing file means
the generic step runs as written; never stop to ask for one. The repo's own docs win.

Examples below use `TICKET-123`, `main` and `app/x.tsx`.

---

## 1. Resolve the sources

Take whatever the engineer names: a planning file, a ticket key, an MR or PR, or nothing.
Nothing → the current branch against the trunk.

- Read the planning file or ticket in full — status, scope, decided behaviour, open
  concerns, and any list of what is not yet browser-tested. Those lists are the best
  source of "what to look for".
- Diff the branch against the trunk: `git diff --stat origin/main...HEAD`, then read the
  changed files that render UI, load data or run actions.
- Plan says X, diff shows no X → record it as a **mismatch**. Diff changes UI the plan
  never mentions → also a mismatch. Both go in the coverage check (§5).

The plan is intent; the diff is what exists. A step built only from the plan can
describe a feature that never landed.

## 2. Find the prerequisites

From the diff, list what the branch needs before step 1. Each item carries the file it
came from and a tag (`[read]`, `[ran]`, `[unverified]`):

- new or changed **migrations**, **seed** scripts, fixtures
- **feature flags** defined or checked in changed code, and how to grant one locally
- new **env vars**
- **dependency** or lockfile changes that need an install
- the **account, workspace or role** the feature needs, and any data it must already hold

Cheap checks run instead of being labelled: is the flag already granted, is the
migration already applied, does the data exist. Report the result.

## 3. Restart the dev server

The engineer's server may be running stale code or a stale schema. Restart it so you can
read its output.

1. **Look before killing.** Find what holds the dev port and show it to the engineer. Kill
   only a process that is plainly this project's dev server; anything else → ask.
2. **Apply prerequisites first** — migrations, seeds, flag grants — using the commands in
   `dev-loop.md`. Those change the engineer's local data, so list them and wait for a yes.
   Stop the server before any command the context file says needs it stopped.
3. **Start the server in the background**, output going to a log file in the scratchpad
   or a temp folder. Wait for the ready line. Never report it ready on a guess.
4. **Say where the log is**, and the local URL, login route and starting page.

No `dev-loop.md` and no obvious start command in the repo's README or scripts → say so
and ask for the command once.

## 4. Write the walkthrough

One checklist, ordered:

1. **Happy path** for each feature, in the order a user would meet them.
2. **Edge states** — empty, loading, error, long text, many items, no permission.
3. **Negative cases** — what must *not* happen: a blocked action, a skipped item, a
   toast that must not appear.
4. **Neighbours** — pages and shared components the diff touches but the ticket does not
   mention. A regression glance, not a full test.

Every step uses this shape, one line per field, none over about 30 words:

```
### 3. Add a skill to a role
- **Where:** /workspace/x/roles/…  (rough URL)
- **Do:** select two skills, choose Add, pick a role, press Submit
- **Expect:** a toast reports the count; the role shows both skills
- **Watch for:** console errors, a 4xx/5xx on the action, a flash of the old list
- **Basis:** plan "Scope" + `app/x.tsx:120` [read]
```

- **Where** is a rough URL with the dynamic parts as placeholders, plus a nav path when
  the route is not linkable. Derive it from the route config, not from memory.
- **Expect** states something observable. "Works" is not a state.
- **Basis** names the plan section or file line the expectation rests on. An expectation
  from design intent only, with no code or plan behind it → `[unverified]`.
- A design link in the plan goes on the step it governs, so the engineer can compare.
- Cap the whole walkthrough at what the engineer can finish in one sitting. A step that
  needs a long setup is a prerequisite, not a step.

## 5. Check coverage

Close the list with three short sections:

- **Plan items with no step** — each requirement or decided behaviour nothing exercises.
- **Changed UI with no step** — files in the diff no step reaches.
- **Not walkable in a browser** — behaviour only a test or a query can confirm, with the
  command that would.

## 6. Walk it

Default to **one step at a time**: the engineer says "step 3 done", you read the log
since the last mark and report errors, warnings, failed requests and anything that
matches the step's "watch for", against that step number. You cannot see the log between
those moments, so say that plainly instead of implying you were watching.

- A log line you cannot explain is reported as seen, not diagnosed.
- A finding inside the ticket's scope is noted against its step. A finding outside it is
  listed separately as a discrete item for a ticket, never fixed inline.
- The engineer may ask for the full list at once. Give it, and offer the log check at the
  end.

## 7. Save it

Write the checklist, with checkboxes and any findings so far, to the project's private
`evidence/` folder, named `walkthrough-<ticket-id>.md` — see `project-context.md`. No
private folder → `planning/walkthrough-<ticket-id>.md`. Rewrite it in place on a rerun;
add the reviewed commit short SHA at the top so a later session can tell if it is stale.

## Boundaries

- Never approve or merge an MR or PR, by any route.
- Never edit source, migrations or the planning file's decisions. Findings go in the
  walkthrough file; a fix is a separate, asked-for step.
- Never commit. The engineer does.
- Phrase anything that is a recommendation as a suggestion; facts stay plain.
- Do not drive the browser unless the engineer asks. The walkthrough is theirs to run.
