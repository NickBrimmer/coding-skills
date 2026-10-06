# Project Context

Every skill in this repo is a generic process. Anything specific to one project — its
conventions, how to run it, its tracker, its architecture — lives outside this repo, in a
private folder the skills find by path.

## Where it lives

```
~/Developer/planning-files/<project>/
  context/
    conventions.md       security instantiation, authoring checklist, pre-merge checks
    dev-loop.md          how to run, query, and verify the project locally
    tracker.md           ticket key, tracker and MR tools, trunk, branch and file naming
    repo-map.md          architecture orientation; read when planning only
    worked-examples.md   past plans that show a technique going wrong or right
  plans/                 one planning file per ticket
  reviews/               one review file per MR
  evidence/              repro recipes, query output, sample methods
  archive/               superseded history
  tomorrow.txt           end-my-day handoff
```

`<project>` is the repo's folder name: `basename "$(git rev-parse --show-toplevel)"`.

## How a skill uses it

- **Read the file the step names, if it exists.** A missing file or folder means the
  generic step runs as written. Never stop to ask for one.
- **The repo's own docs win.** An `AGENTS.md`, `CLAUDE.md`, or ADR in the repo overrides
  a context file, and a context file overrides the generic defaults in a skill.
- **A repo can point here.** An untracked `AGENTS.local.md` in the repo root is a good place
  for a short list of these files. Keep it untracked with `.git/info/exclude` if the
  repo's `.gitignore` doesn't cover it.

## What never goes in this repo

Process belongs here; facts about a project or a person do not. Never commit:

- employer, product, customer, or colleague names; your own name or email;
- ticket keys, internal hosts or URLs, work repo names, absolute home paths;
- how a work system is built, deployed, or secured.

Examples use invented placeholders: `TICKET-123`, `app/x.tsx`, `acme`. The leak check in
`scripts/` enforces this at write, commit, and push time — see the README.
