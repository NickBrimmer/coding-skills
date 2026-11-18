---
name: retro
description: Retrospective on a coding session — reads the session log, the ticket's planning
  file and tomorrow.txt's RETRO lines, then suggests changes to the agent's environment (skills,
  hooks, checks, steering files) in order of severity, each naming the file the fix belongs in.
  Use only when the engineer types /retro. Never invoke it on your own.
disable-model-invocation: true
---

# Retro

Suggest changes to the agent's environment so the next session goes better. A retro proposes;
it builds nothing (§0a). The engineer picks what to fix, usually through `/check` or `/do`.

## Steps

1. Call the Skill tool with `writing-for-agents` for the writing style guide.

2. **Read the sources.** The session is the current one unless the engineer names another;
   logs are `~/.claude/projects/<slug>/*.jsonl`, newest first. Also read, where they exist:
   - the ticket's planning or review file — a finding said in chat but missing here is evidence
   - `RETRO` lines in `~/Developer/planning-files/<project>/tomorrow.txt`
   - the steering in force: `working-agreement.md`, the private `~/.claude/CLAUDE.md`, the
     repo's `CLAUDE.md` or `AGENTS.md`, and `context/conventions.md`

3. **Look for these.**
   - **Navigation** — the session spent long finding a file or fact. Fix: a pointer in
     `context/repo-map.md` or the repo's `CLAUDE.md`.
   - **Automated checks** — read the repo's hooks, CI and check scripts first; an existing
     check left unwired is the finding. A mechanical mistake gets a check, never a rule.
     A repo with no hook and no CI running its checks is a finding on its own.
   - **Review checklist** — the reviewer is `code-review`. A judgement call it missed goes in
     its checklist or `context/conventions.md`; a mechanical one goes to a check.
   - **Working agreement** — the agent broke a rule: name the section, and whether it needs a
     hook, sharper wording, or nothing.
   - **Steering weight** — a rule that a hook or the review checklist could carry instead, or
     one that changes no behaviour (a no-op). Suggest moving or deleting it.
   - **Recording** — something found that never reached the planning file (§14).
   - **Tool economy** — an expensive or repeated call a script or flag would shorten.
   - **Information access** — something the agent needed and could not see: logs, a
     read-only service, a dev server.

4. **Name where each fix lives.** Public (this repo, process only, §12): skills, hooks,
   scripts, `working-agreement.md`. Private: `~/.claude/CLAUDE.md`, the project's `context/`.
   A fix that needs a private fact goes private, whatever it is about.

5. **Report in chat only.** Nothing is written to a file. List the findings most severe first,
   each with its tag (`[ran]`, `[read]`, `[unverified]`) and the file its fix belongs in, as
   suggestions (§1). Feedback about how we work together → ask whether it belongs in the
   working agreement (§5).
