# Repo Convention Checklist (Phase 7)

Applies to code authored in this repo directly. **Never raise one of these as a review
finding on someone else's diff** — they are authoring standards, not review criteria.

Every section below is a *default*. Where the repo does it differently, the repo wins —
grep a real call site before trusting anything here.

---

## DB & Migrations

- Date-prefixed migration directory with a paired up/down. Never edit a migration once
  it is on the trunk.
- Timestamp columns get a real timestamp-with-timezone type, not an integer.
- Soft-delete tables get `removed_at` + `removed_by_user_id` (or the repo's equivalent).
- Document the cascade-on-delete decision explicitly — inherit it by accident and the
  first bulk delete finds out for you.
- Index the primary access pattern, plus a partial index for active rows on a
  soft-delete table.
- The migration runs **before** deploy if code depends on it. State this in the plan.

## Code Comments

**One line, always.** It explains **why the next line exists** — not what it does, and
not how it came to be.

- Needs more than one line of context? The comment carries a **pointer** — a doc URL, or
  `file.ts:123` — and the context lives there or in the plan. Never a multi-line comment
  that inlines the whole story.
- **Never narrative.** No names, no dates, no session history, no story of how the code
  got here. `// We tell the user it's their filters (Nick, 2026-09-16)` and `// We tried
  the effect version first and it double-fired` are both wrong: git blame carries who and
  when, the plan carries what was decided and why.
- A plain causal "why" is right and is not narrative:
  `// Without this, the previous filter's bars flash before the new ones load` is fine.
- A **deviation from convention** is still one line — what the convention is, why this
  departs — with the pointer carrying the rest:

```ts
// Deviation: raw sql() not the nested-array helper — correlated subqueries break it; see <ticket> plan.
```

## Queries & Data Access

- Soft-delete diffing is read → diff → update-removed / upsert, not delete-and-reinsert.
- Use the query builder's nested-array helper for nested collections rather than N+1
  round trips.
- Wrap multi-step writes in one transaction.
- Never raw string interpolation into SQL.
- Conditional clauses use the builder's own conditional method, not host-language `if`
  breaking the chain.

## Routing & Data Loading

- Generated type files are generated. Never hand-write them.
- New routes register next to the closest related one, not appended to the end.
- Every route loader verifies permission server-side.
- Use the framework's own fetch primitive with a `disabled` option rather than calling a
  hook conditionally.
- Use the typed link/href helper for internal links, not string literals.

## Validation & Write Handlers

- Follow the repo's existing action/handler creation pattern rather than hand-rolling.
- The validation guard goes **inside each branch** of a discriminated union, not once at
  the top against a union-wide schema.
- One single source of truth for submit-readiness (`canSubmit`), not several booleans
  the UI re-derives.

## Feature Flags

- A named constant, with a ticket-ID variable name (`hasABC1120Enabled`).
- Read in **both** the loader and the write handler — two independent reads from the
  source of truth. Never trust client-sent flag state.
- Start/end marker comments keyed to **the flag's ticket ID**, not the implementing
  ticket's.
- No "dump all flags" helper or debug logging shipped.
- **Map which layer the flag actually gates** (data / UI / write) before writing tests —
  a loader often returns full data regardless of flag state, and the gate is really in
  the component. Test behavior, not mechanism: one `describe` block per flag state, not
  per layer.

## Logging

- One logger instance per route/module, named for it.
- `.info()` on every write path, with entity IDs and counts.
- `.warn()` on auth failures.
- `.error()` on external API failures, with message + error + metadata.

## Analytics

- Every user action fires an event.
- `noun_verb` naming.
- Mirror the existing event-property shape rather than inventing a new one.

## State & UI

- Lazy `useState` initializers only run once — resync on remount if the instance is
  reused.
- Hooks are always unconditional; use a `disabled` option instead of a conditional call.
- Debounce is a `setTimeout` + cleanup at the repo's standard interval, mirrored from an
  existing component rather than re-derived.

## React Anti-Patterns

See the `code-review` skill's `references/best-practices.md` — single source of truth,
not duplicated here.

## Accessibility

See Phase 5 of the main skill.
