---
name: code-review
description: Review a pull request, merge request, branch, or diff against a structured checklist covering ticket fidelity, scope creep, security (OWASP), accessibility, testing, error handling, and repo conventions. Use when asked to review a PR/MR/diff/branch, check someone's changes before merge, or self-review work before opening a PR. Also use when asked whether a change is ready to merge.
---

# PR Review

A framework for reviewing and writing code. Apply to every ticket and merge request.

Read `references/best-practices.md` for the standards the checklist's **B — Best
Practices** item refers to. If the change generalizes something from one case to many,
or claims to fix a bug, invoke the `bug-hunt` skill — those two situations have their
own technique and are where reviewer-found bugs actually come from. If the change is one
where being wrong is expensive to undo — a migration, access control, money, permissions —
run the `adversarial-review` skill instead and let the author defend it.

**Review someone else's diff against the ticket and the checklist below. Do not raise
repo-authoring conventions (comment style, migration file layout, logger naming) as
findings on a diff unless the change actually violates a standard the repo enforces.**

---

## The PRIMES STOATEUS BCFFILE OPENS Checklist

### Ticket & Purpose
- **T — Ticket Details** — Are the ticket details abundantly clear, or are there terms
  or expectations that need to be defined?
- **P — Purpose** — What is the functional purpose / essential problem this ticket is
  trying to solve?

### Initial Response
- **R — Response** — Can I get a response from the code? Or does it flat out break or
  error in the console? **Don't rely solely on the PR description's claims** — verify
  directly against a running instance (server logs, direct DB query, or calling the
  route/handler directly) wherever practical. See the `bug-hunt` skill.
- **I — Intended** — Is everything in this PR intended? Does anything look odd, out of
  place, or forgotten to clean?
- **M — Missed** — Was any point from the ticket description or implementation plan
  forgotten or left unfinished?
- **E — Errors** — Are there errors that come up via navigation, using the app, or in
  testing?
- **S — Spelling + Syntax** — Spelling errors on user-facing labels, syntax errors in
  the code?

### Scope & Standards
- **S — Scope** — Is this staying within the scope of concern, or beginning to touch
  things unrelated to the ticket? Can the code be structured to be as reasonably
  scope-decoupled as possible?
- **T — Team Conventions** — Check the repo for existing patterns before accepting a new
  one.
- **O — OWASP Top 10** — Broken Access Control, Cryptographic Failures, Injection,
  Insecure Design, Security Misconfiguration, Vulnerable/Outdated Components,
  Identification & Auth Failures, Software & Data Integrity Failures, Security Logging
  Failures, SSRF.
- **A — Accessible** — Is this a11y accessible? Does it meet industry standards for
  aiding people with disabilities?
- **T — Testing** — Are there UI, request, or DB tests that should be written or updated?
- **E — Error Handling and Validation** — Are requests wrapped in a try/catch, and are
  inputs/outputs being validated properly?

### Affected & Unnecessary
- **A — Affected** — Do these changes affect the app beyond the scope of the changes?
  What connects to this, and is it still working? Can it be decoupled? **This is where
  the generalization bug lives — see `bug-hunt`.**
- **U — Unnecessary** — Is any code here unnecessary, or can this be done more minimally?
- **S — Simplest** — Is this the simplest and most minimally disruptive/invasive code
  possible?

### Best Practices & Conventions
- **B — Best Practices** — See `references/best-practices.md`.
- **C — Conventions (in the repo)** — What are the repo conventions, paradigms, and
  already-implemented solutions we can follow or avoid duplicating?
- **F — Functions** — Are we using functions we didn't write, and do we understand their
  purpose, params, and output?
- **F — Faster** — Is there any way to optimize this for speed?
- **I — Improvements** — Any general improvements to make this code better?
- **L — Labels** — Are there labels *in only the code written* that could be named more
  descriptively or appropriately?
- **E — Edges + Inputs** — Are there ways to break or exploit this input, API, or
  request in ways it was not meant to be used?

### Final Checks
- **O — On and Off** — Does the app work with *and* without this feature? Is it
  decoupled enough to break safely?
- **P — Other People's Code Preferences** — Be mindful of collaborators' conventions and
  established patterns in shared areas.
- **E — Environment Stuff** — Environment variables, container setup, or
  runtime/language-specific problems to watch out for?
- **N — Package Audit** — Run a dependency security audit or equivalent (`npm audit`,
  `yarn audit`, `pip-audit`, `cargo audit`) if dependencies changed.
- **S — Solved** — Is every concern on this ticket solved, and has it met the necessary
  requirements for safety, security, and efficiency?

---

## What NOT to flag

The checklist above is **28 prompts, not 28 findings.** An item you checked and found
nothing on produces nothing — it does not produce a hedged observation to show the work.
Most items on most PRs are silent. A review that returns three real bugs is better than
one that returns three real bugs buried in twenty nitpicks, because the second one gets
skimmed.

Before reporting anything, drop it if it is:

- **Pre-existing** — the problem was there before this branch. Not this PR's job, unless
  the change makes it materially worse or the ticket is to fix it. Check with git blame
  rather than assuming.
- **Caught by tooling** — type errors, missing imports, formatting, lint rules, failing
  tests, import ordering. CI reports these better than you do. Don't run the build to
  find them either.
- **Deliberately silenced** — a lint-ignore, a documented deviation comment, an explicit
  `// intentional`. Read the justification; argue with it only if it's actually wrong.
- **A pedantic nitpick** — something a senior engineer reviewing a colleague would let
  go. Naming preferences, a helper you'd have extracted, a ternary you'd have written as
  an if.
- **Speculative** — "this could break if someone later…" with no concrete trigger in the
  current code. Find the caller that does it, or drop it.
- **Intentional and in-scope** — a behavior change that is obviously part of what the
  ticket asked for, even if it wasn't spelled out in the description.
- **A repo-authoring convention** — comment style, migration file layout, logger naming.
  Those are for code you write (see `ticket-planning` Phase 7), not findings on someone
  else's diff, unless the repo actually enforces the rule.

### The one exception: unmodified lines

Ordinarily "this line is real but the author didn't touch it" is a reason to drop a
finding. **It is not, when the line is a sibling of something this PR generalized.**

That is the entire point of the generalization audit: the missed call site is *always*
on a line the diff never touched, in a file that isn't in the PR. If you found it by
grepping for the old assumption and it's now wrong because of this change, it is this
PR's bug and it gets reported. See the `bug-hunt` skill.

The test is causation, not location: *did this change make that line wrong?*

### Calibrate before reporting

For each surviving finding, ask: **could I state the input and the resulting wrong
behavior?** If not, it's an impression, not a bug — either go verify it or label it
clearly as a question.

Then sort into three buckets and label them as such:

1. **Bug** — verified wrong. Concrete failing input/state. Leads the review.
2. **Risk** — probably wrong, not reproduced. Say what you'd need to confirm it.
3. **Preference** — you'd have done it differently, and the current code is fine.
   Optional, goes last, explicitly marked non-blocking.

Never let bucket 3 masquerade as bucket 1. The security, accessibility, and testing
items on this checklist are real findings when a gate is genuinely missing — they are
bucket 3 when you'd merely have written the test differently.

## Reporting findings

- Lead with the correctness bugs. Quality and style findings go after, clearly separated.
- Every finding names a file and line and states the concrete failure: what input or
  state produces what wrong output.
- Distinguish "this is wrong" from "I'd have done this differently." Say which one you
  mean.
- If the PR claims a fix and you could not reproduce the original bug, say that
  explicitly rather than approving on the strength of the description.
