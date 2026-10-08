# coding-skills

Personal Claude Code skills and working agreement — the single source of truth for *how*
I work, carried across machines and projects. Each folder is one skill: a `SKILL.md` with
YAML frontmatter (`name`, `description`), plus optional `references/` files the skill
reads on demand.

Claude Code loads only the frontmatter until a skill matches what you asked for.
That is why the `description` is long and lists trigger phrases.

**This repo is public and holds process only.** Facts about a project, an employer, or a
person live in private files the skills find by path — see [Privacy](#privacy).

## The skills

| Skill | Run it with | What it does |
| --- | --- | --- |
| `ticket-planning` | `/ticket-planning` | Writes an implementation plan before any code. Phased: verify every assumption against the code, cite file and line, flag what is unclear instead of guessing. |
| `code-review` | `/code-review` | Reviews a PR, branch, or diff against a checklist: ticket fidelity, scope creep, security, accessibility, testing, error handling, repo conventions. |
| `bug-hunt` | `/bug-hunt` | Finds bugs the diff does not show — missed call sites after a one-to-many change, broken invariants, fix claims nobody reproduced. |
| `adversarial-review` | `/adversarial-review` | A hostile two-session review. One session attacks the diff and its assumptions, the other defends and fixes, in short capped lines in the ticket file. |
| `end-my-day` | `/end-my-day` | Five closing questions. Writes what is in flight to the project's private `tomorrow.txt` and appends what you learned to the coding ledger. |
| `start-my-day` | `/start-my-day` | Reads `tomorrow.txt`, checks each item against the repo as it is now, and hands back a short plan with a concrete first action. |
| `start-branch` | `/start-branch` | Creates or confirms the branch, reads the ticket, and creates or reopens the ticket's planning file. Stops before planning. |
| `start-review` | `/start-review` | Checks out a teammate's MR or PR branch, reads the ticket and discussions, runs the tests, and opens a review file recording the reviewed SHA. Stops before reviewing. |
| `walkthrough-changes` | `/walkthrough-changes` | Writes a step-by-step browser walkthrough of a branch: prerequisites, a restarted dev server whose logs it can read, then rough URL, click and expectation per step, with a coverage check. |

`code-review` hands off to `bug-hunt` when a change generalizes one case to many or
claims to fix a bug. `adversarial-review` is the heavier version for changes where being
wrong is expensive — migrations, access control, money — and it leans on both. `end-my-day`
and `start-my-day` are two halves of one loop: the first writes `tomorrow.txt`, the second
reads it.

### Running an adversarial review

Two terminals on the same repo, `/adversarial-review` in each. The ticket's planning
`.md` is the only channel between them — each side writes a line and stops, and you move
the other session. You rule on anything the evidence does not settle, and you decide when
it is over.

### Reference files

- `ticket-planning/references/plan-structure.md` — headings, the `Concern` / `Option`
  labels, and the writing rules (30-word lines, `Problem:` / `Fix:` shape, evidence tags)
  every planning and review file follows. Every skill points here.
- `ticket-planning/references/project-context.md` — where a project's private context
  lives and how skills read it.
- `ticket-planning/references/conventions-checklist.md` — generic authoring defaults for
  code you write. Not review criteria.
- `code-review/references/best-practices.md` — the standards behind the checklist's
  best-practices item.

## Working agreement

`working-agreement.md` is how I want an agent to work with me: never approve a merge,
do exactly what was asked, suggest rather than command, label verified vs assumed, plan
before building, and the rest. Load it on each machine by importing it from your private
user-level `~/.claude/CLAUDE.md`:

```markdown
@~/Developer/coding-skills/working-agreement.md
```

Machine- and employer-specific rules go in that private `CLAUDE.md` under the same section
numbers.

## Private context

Skills stay generic. Anything specific to a project lives outside this repo:

```
~/Developer/planning-files/<project>/
  context/        conventions.md · dev-loop.md · tracker.md · repo-map.md · worked-examples.md
  plans/  reviews/  evidence/  archive/  tomorrow.txt
~/Developer/planning-files/coding-ledger.md
```

`<project>` is the repo's folder name. A skill reads the context file a step names if it
exists, and runs the generic step if it doesn't. Full convention:
`ticket-planning/references/project-context.md`.

## Privacy

**Never in this repo:** employer, product, customer, or colleague names; your own name or
email; ticket keys; internal hosts or URLs; work repo names; absolute home paths; how a
work system is built, deployed, or secured. Examples use invented placeholders —
`TICKET-123`, `app/x.tsx`, `acme`.

**Enforced in three places by `scripts/leak-check.sh`:**

| When | How | Set up by |
| --- | --- | --- |
| An agent writes or edits a file here | Claude Code `PreToolUse` hook, `scripts/claude-leak-hook.sh` | Your `~/.claude/settings.json` (below) |
| `git commit` | `.githooks/pre-commit` scans every staged file and path | `install.sh` |
| `git push` | `.githooks/pre-push` scans added lines and messages | `install.sh` |

The script checks two kinds of pattern. Generic ones live in the script: ticket keys
(`TICKET-123` is allowed), emails, `/Users/` and `/home/` paths, internal hostnames.
Private terms live only in `~/.config/coding-skills/denylist.txt` — one case-insensitive
regex per line, matched as a whole word. **That file never goes on any remote**; copy it
to a new machine by hand. Without it, commits and pushes are refused rather than waved through.

Agent hook, in `~/.claude/settings.json`:

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Write|Edit|MultiEdit",
      "hooks": [{ "type": "command", "command": "sh \"$HOME/Developer/coding-skills/scripts/claude-leak-hook.sh\"" }]
    }
  ]
}
```

Audit the whole history at any time:

```sh
git log -p --all | grep '^+' | scripts/leak-check.sh --label history
```

**Metrics:** zero hits in a staged diff, zero hits in history, zero planning-file lines
over 30 words (the length check in `plan-structure.md`).

## Install

Clone, then link each skill into your Claude Code skills folder and turn on the hooks:

```sh
git clone git@github.com:NickBrimmer/coding-skills.git ~/Developer/coding-skills
cd ~/Developer/coding-skills
./install.sh
```

`install.sh` links every folder holding a `SKILL.md` into `~/.claude/skills/`, so a new
skill needs no change to the script, and points `core.hooksPath` at `.githooks/`. Editing
a file in the clone changes the live skill, so `git status` always shows the truth.

Then, on each machine: create the denylist, add the agent hook, and add the import line
to `~/.claude/CLAUDE.md`.

## Editing a skill

Change the file in this repo. The change is live in the next session — no reload step.
Keep `description` written the way you would ask for the thing out loud; that text is
the whole trigger. Keep project facts out — put them in the project's private context.
