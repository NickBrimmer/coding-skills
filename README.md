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

`code-review` hands off to `bug-hunt` when a change generalizes one case to many or
claims to fix a bug.

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

`install.sh` links every skill folder into `~/.claude/skills/`. Editing a file in the
clone changes the live skill, so `git status` always shows the truth.

Scope it to one project instead by linking into that project's `.claude/skills/`.

## Editing a skill

Change the file in this repo. The change is live in the next session — no reload step.
Keep `description` written the way you would ask for the thing out loud; that text is
the whole trigger.
