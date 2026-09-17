# coding-skills

Personal Claude Code skills. Each folder is one skill: a `SKILL.md` with YAML
frontmatter (`name`, `description`), plus optional `references/` files the skill
reads on demand.

Claude Code loads only the frontmatter until a skill matches what you asked for.
That is why the `description` is long and lists trigger phrases.

## The skills

| Skill | Run it with | What it does |
| --- | --- | --- |
| `ticket-planning` | `/ticket-planning` | Writes an implementation plan before any code. Phased: verify every assumption against the code, cite file and line, flag what is unclear instead of guessing. |
| `code-review` | `/code-review` | Reviews a PR, branch, or diff against a checklist: ticket fidelity, scope creep, security, accessibility, testing, error handling, repo conventions. |
| `bug-hunt` | `/bug-hunt` | Finds bugs the diff does not show — missed call sites after a one-to-many change, broken invariants, fix claims nobody reproduced. |
| `end-my-day` | `/end-my-day` | Five closing questions. Writes what is in flight to `tomorrow.txt` and appends what you learned to the coding ledger. |
| `start-my-day` | `/start-my-day` | Reads `tomorrow.txt`, checks each item against the repo as it is now, and hands back a short plan with a concrete first action. |

`code-review` hands off to `bug-hunt` when a change generalizes one case to many or
claims to fix a bug. `end-my-day` and `start-my-day` are two halves of one loop: the
first writes `tomorrow.txt`, the second reads it.

### tomorrow.txt

One per repo, in the repo root, rewritten whole every evening. Plain text, no markdown.
Every "pick up here" line names a file and a line — a line with no location is a topic,
not a task. `start-my-day` opens each file it names before repeating the item back, so a
task that already landed gets dropped instead of re-planned.

The coding ledger lives outside this repo at `~/Developer/planning/coding-ledger.md`.

### Reference files

- `code-review/references/best-practices.md` — the standards behind the checklist's
  best-practices item.
- `ticket-planning/references/plan-structure.md` — headings and vocabulary every plan uses.
- `ticket-planning/references/conventions-checklist.md` — authoring defaults for code
  written in the repo. Not review criteria.

## Install

Clone, then symlink each skill into your Claude Code skills folder:

```sh
git clone git@github.com:NickBrimmer/coding-skills.git
cd coding-skills
./install.sh
```

`install.sh` links every folder holding a `SKILL.md` into `~/.claude/skills/`, so a new
skill needs no change to the script. Editing a file in the clone changes the live skill,
so `git status` always shows the truth.

Scope it to one project instead by linking into that project's `.claude/skills/`.

## Editing a skill

Change the file in this repo. The change is live in the next session — no reload step.
Keep `description` written the way you would ask for the thing out loud; that text is
the whole trigger.
