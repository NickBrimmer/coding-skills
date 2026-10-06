---
name: ticket-planning
description: Write an implementation plan for a ticket, issue, or feature before any code is written. Produces a planning file a junior engineer could execute without guessing and a staff engineer would not object to. Use when asked to plan a ticket/issue/story, break down a feature, scope work, write an implementation plan or technical spec, or when starting work on a ticket and the approach is not yet settled. Also use when returning to an existing plan to amend it.
---

# Ticket Planning

Follow these phases in order. Write simply and declaratively for a reader with zero
context: state what is true and what to do, give file+line instead of explaining, and
flag anything unclear instead of guessing. Verify every assumption against the code.
Zero context means the reader gets a pointer they can follow, not context pasted in.

**Keep each planning file under 500 lines.** Link to the canonical code (file+line)
instead of inlining it.

Read before writing:

- `references/plan-structure.md` — headings, the `Concern` / `Option` labels, and the
  writing rules (30-word lines, `Problem:` / `Fix:` shape, evidence tags). It wins over
  anything else.
- `references/project-context.md` — where this project's private context lives. Phases 1,
  6, 7 and 9 read from it when it exists.
- `references/conventions-checklist.md` — at Phase 7.

---

## Phase 1: Setup & Orientation

- Create the planning file in the project's private `plans/` folder, named per
  `context/tracker.md` (see `references/project-context.md`). No private folder → the
  project's existing planning directory, else `planning/<ticket-id>-<slug>.md`.
- Read the ticket in full before writing anything.
- Write the purpose in one sentence. Can't write it → the ticket is under-specified.
- List every explicit requirement as a DOD item.
- List the tests required to validate the DOD.
- Flag missing info and garbled/contradictory ticket text as blockers. Don't guess at
  either.
- Open the plan with a `⛔ STOP GATE` table: question, who/what resolves it, what
  changes if the answer surprises. No implementation until every blocker is confirmed.
  A question that changes no code is a clarification, not a blocker — put it in the
  Final Outstanding Questions table instead. Scope expansion found mid-implementation
  stops the session for approval.
- Part of a multi-ticket epic: open with `**Depends on:**` / `**Blocks:**` /
  `**Build type:** NET-NEW | ADAPT | SHELL`.
- **Returning across sessions: amend the plan in place** — update the STOP GATE table,
  DOD, and scope directly. Never append a dated session log; the plan is a living
  document, not a journal.
- Once a blocker resolves, compact it to `<question>` → `<solution label + pointer>`
  (file+line or ticket ref). Drop the reasoning that got there — the code is the source
  of truth for how, the plan only records what.
- Still over 500 lines after compacting: move genuinely historical detail (a superseded
  decision, a resolved investigation) to `archive/<ticket-id>-history.md`, linked.

## Phase 2: Research & Context Gathering

- Branching off something other than the trunk (feature branch, infra branch)? Research
  its conventions first.
- **Define exactly what you need first** (a component pattern, a loader shape, a query),
  then search narrowly for that specific thing — don't dig through unrelated layers.
  Cite file+line. Don't invent a pattern that already exists.
- Using a third-party library in a new way? Define the exact capability needed, find the
  specific official doc page for it — not general familiarity with the library — and
  link it in the plan so the implementing session can read it directly. A project skill
  for that library takes priority over general docs.
- Grep for existing usage before planning a new query/API call — **existing usage is the
  spec.**
- Read real code for naming conventions, not docs.
- Read every function you didn't write before calling it — signature, return, error
  behavior. Don't infer from the name.

## Phase 3: Data & Architecture Analysis

- Map this feature's actual data flow as a diagram — where its data originates and every
  stage it passes through and affects. Not every feature has every stage;
  `source → loader → client state → action → DB → read back → component` is one common
  shape, not a required one. **Gaps in the diagram are gaps in the implementation.**
- List every validation gate in order (client, schema, server handler, DB). Missing a
  gate is a security issue; a duplicate is maintenance debt.
- If this feature stores a name/label alongside an ID instead of just the ID
  (denormalized for lookup speed), flag it explicitly and list every write path (create,
  edit, import, background job) that must keep the copy in sync when the source changes.
- Grep for every file that reads the data you're writing. Does it need to change, and if
  not, does it degrade gracefully?
- Confirm transaction scope — check whether a transaction is already open on this path
  and add to it rather than opening a second one.
- Verify soft-delete vs. hard-delete by reading the actual handler, not by assuming.

## Phase 4: Scope, Risk & Assumptions

**Scope Creep Pass** (re-run after every review round):
- Every file in "Files to Touch" must trace to a specific ticket requirement — cut it
  if not.
- "While we're here" cleanup is a separate ticket.
- Prefer the more decoupled approach when one exists.
- Don't tighten validation on existing fields — that's a separate ticket.

**Assumptions & Edge Cases:**
- List every unverified assumption, verify each by reading code.
- Test a fallback against the exact input that triggers it, not just "in general."
- Read the full handler including soft-delete restore paths, not just the happy path.

**Parallel Branch Merge Risk** (when the trunk has related work since this branch
diverged):
- Run `git diff HEAD...<trunk> --name-status` and the reverse before merging — build a
  "do not lose" inventory.
- After merging, absence of conflict markers isn't proof nothing collided — grep
  overlapping files for both branches' key symbols.
- Resolve one conflicting file at a time; verify before moving to the next.

**Generalization Audit** (1 → N changes — a single case becoming several): grep the
whole repo for the old constant/assumption, not just the files already in scope. This
is the highest-yield check in the guide — the full pattern is in the `bug-hunt` skill.
The project's `context/worked-examples.md`, if present, points at past plans that show it.

**Deployment & Operational Risk:**
- State migration-before-deploy explicitly if code depends on it.
- Write the rollback story — reversible migration? easy flag disable? data state if the
  flag is toggled off after writes?
- Confirm the app works with the feature fully disabled.
- New env vars/secrets go in the example env file, documented, with load timing
  (startup vs. lazy) noted.
- New packages get a security audit + maintenance check + justification over
  reimplementing.
- Flag any cross-file type-contract pair (new required prop, changed signature) that
  must be committed atomically.

Run the `code-review` skill's checklist against the plan — most items are covered above;
additionally check for N+1 queries, large client payloads, O(n²) client loops, and
unconditional subqueries that run even when the feature is off.

## Phase 5: Design Review

- Check for a linked design (Figma CLI/MCP `get_design_context`/`get_screenshot`, or
  whatever the team uses) before writing any UI code — pull the actual linked file,
  don't work from memory of a similar screen.
- Record from the design: input order/grouping, exact label/placeholder copy,
  selected/error/empty/loading states, modal sizing, any copy changes, list/table
  treatment for new data.
- Capture every user-facing string verbatim in the plan and spell-check it — don't
  paraphrase.
- Accessibility: every input/dropdown has an associated label; keyboard-operable
  (Tab/Enter/Space/arrows); errors linked via `aria-describedby`; color never the sole
  indicator; icon-only controls get `aria-label`.
- List design questions the design file doesn't answer — a team call, not a guess.

## Phase 6: Security & Validation

OWASP Top 10 pass, written as **this codebase's instantiation** of each — not the
generic definition. The project's `context/conventions.md` (Phase 6 section), if present,
says how this codebase does each one; the defaults below apply otherwise:

- **Injection** — parameterized queries only, no raw interpolation.
- **Broken Auth** — every loader/route re-verifies permission server-side.
- **Broken Access Control** — the write handler re-verifies access server-side and never
  trusts client-sent IDs. A disabled UI control is not a guard.
- **Security Misconfiguration** — no hardcoded secrets or debug artifacts shipped.
- **XSS** — avoid raw HTML injection sinks.
- **Sensitive Data Exposure** — queries return only what the UI needs.

Additionally:
- New fields get non-empty/shape validation **at this ticket's boundary only**.
- Flag-gated features gate the write independently of the validation check, and the
  server re-reads the flag from its source of truth — never trusts client-sent flag
  state.

## Phase 7: Repo Convention Checklist

Read `references/conventions-checklist.md`, then the project's `context/conventions.md`
if present, and apply the sections that exist in this repo. The project file wins over
the generic checklist, and a real call site wins over both.

**These apply to code authored in this repo directly. Never raise a Phase 7 item as a
review finding on someone else's diff.**

## Phase 8: Handoff Quality Checks

Run in order after the plan is otherwise complete.

- **Jr Engineer Test:** could a junior act on each line on a first read, without asking?
  Every step is one declarative instruction at a `file:line` · an unfamiliar pattern gets
  a pointer to a canonical example, not an explanation · a changed signature shows
  before → after, one line each · every place that must stay in sync is listed. Plain
  words over precise jargon. A line that needs a second read gets rewritten, not expanded.
- **Staff Engineer Test:** no duplicated logic that should share one source of truth ·
  no outage window from migration order · flag gate consistent across
  validation/UI/write · unconditional-query trade-offs documented · degraded downstream
  states documented or ticketed · logging on every write path · safe rollback.
- **Scope Creep Final Pass:** re-run Phase 4's Scope Creep Pass against the finished plan.
- **Copy & Spelling Pass:** read every user-facing string aloud, spell-check it, confirm
  it matches the design exactly.
- **Concision Pass:** every line meets the writing rules in `references/plan-structure.md`;
  its length check lists any line over the cap.
- **Final Outstanding Questions Pass:** list every unresolved question; sort blocker vs.
  clarification. Blockers become `⚠️ Implementation check` notes; clarifications go in
  the DOD.

## Phase 9: Implementation Verification

Add as a standing section to every plan; it runs during and after implementation.

- **Read the repo's own docs first.** `find . -maxdepth 3 -name "*.md" | grep -v
  node_modules | grep -v "\.git"` — read every result. An agent-instructions file
  overrides general convention; `docs/decisions/` are the ADRs; the README has
  setup/build/deploy. **Doc wins on conflict** — update the plan, add a code comment,
  move on.
- **Find each new file's nearest neighbour.** Before writing any new file, find the
  closest existing file doing something similar, read it in full, and use it as the
  template (naming, imports, query shape, error handling). Note it in the plan:
  `**Reference file for `write.ts`:** `path/to/neighbour.ts``
- **Verify directly, don't infer from the diff.** Run the dev server backgrounded and
  read its stdout; query the dev DB through whatever mechanism the project actually uses
  (check the README — the obvious client may not connect); hit handlers directly to
  bypass the UI. Full technique in the `bug-hunt` skill; the project's specifics are in
  `context/dev-loop.md` if present.
- **Flag plan/convention conflicts before committing.** Scan every pre-written code
  block against the repo's agent-instructions file. Add a one-line code comment for each
  justified deviation.
- **Pre-merge checklist** (plus the project's own, in `context/conventions.md`):
  - [ ] Every flag-gate marker comment present on every gated block.
  - [ ] `grep -r "<TICKET-ID>" .` returns exactly the plan's listed touch points.
  - [ ] No stray debug logging — the project's logger only.
  - [ ] Migration down-path actually tested by running it.
  - [ ] Generalization Audit re-run: grep the old constant/assumption, confirm every
        sibling site was updated or is a deliberate no-op.

---

## What Makes a Plan "Done"

1. A competent junior with AI help could execute every step without guessing.
2. A staff engineer would have no architectural objections not already documented and
   resolved.
3. Every open question is answered or explicitly flagged as an implementation-time check.
4. The DOD is specific enough that "done" is unambiguous.
