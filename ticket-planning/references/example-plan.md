# TICKET-123 — Orders report clean-up

A miniature planning file: one or two lines per section to show the shape.
The rules behind it are in `plan-structure.md`; this file is not a template to copy whole.

**Branch:** `ticket-123-orders-cleanup` · **Ticket:** TICKET-123 · **Depends on:** <ticket> (MR !38)
**Build type:** ADAPT — changes shipped report code; no new tables, flags or routes
**Not doing:** saved filters — moved to <follow-up ticket>

## ⛔ STOP GATE

| Question | Resolved by | What changes if the answer surprises |
| --- | --- | --- |
| None open | | |

Resolved:
- Low-volume label rule → Product: drop it; the label follows the % — Concern #1 [read]

## Status
At `abc1234`, MR !40. Next: browser check of Step 3.
- [x] Steps 1–2 [ran: checks clean, tests pass]
- [ ] Step 3 — built, browser check open
- `[my call]` ×1: list height, Open questions

## Goal
Apply the review feedback to the Orders report before its feature flag is removed.

## Scope
- [ ] The filter panel's ghost button reads "Clear All" — `filter-panel.tsx:88` [read]
- [ ] The Region list sorts A-Z, 10 rows visible, more on scroll — Concern #2
- [ ] Order Volume's label always follows its % change — Concern #1

## Existing code to build on
- Offset paging with limit+1: `customer-search.tsx:40-55` [read]

## Concerns

### Concern #1, Order Volume reads "Stable" at −40%
Problem: the under-100 rule counts filtered orders, so stacked filters force "Stable" — `order-metrics.ts:62` [ran]
Option 1: count orders unfiltered; tiny filtered samples then get a full label.
Option 2: drop the rule; the label always follows the %.
Fix: Option 2 — Product ruling in the ticket comments [read]

### Concern #2, the region source cannot page
Problem: the regions API rejects `offset` (400) and orders by id; 900 rows, about 0.5 s [ran]
Fix: return every region sorted once; the client reveals more on scroll.

## Open questions
- "10 rows visible": rows are 28 px, so the list is `max-h-70` `[my call]`

## Implementation steps
1. `filter-panel.tsx:88` → `Clear All`
2. `order-metrics.ts:62`: delete the under-100 line and its parameter — Concern #1
3. `regions.ts`: list all, sorted with `localeCompare`; the list reveals 50 more on scroll — Concern #2

## Tests Required
- Order Volume at −40% on 30 orders reads "Falling"; replaces the under-100 tests.
- Browser check: click the empty Region input → A-Z list, 10 rows; scroll → more load.

## Notes
- Follow-up: saved filters — <follow-up ticket>
