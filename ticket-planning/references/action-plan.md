# Action Plans

A proposal for one change the engineer approves before it runs: a tracker edit, an MR
description or comment, a chat message, a rebase. It is shown in chat, not written to a file.

## Shape

Five parts, in this order, about 40 lines in all:

1. **What I checked** — each source with its evidence tag; the backup path for anything
   about to be overwritten.
2. **Decide first** — the one question that changes the result, under its own heading,
   with lettered options and a suggestion. Nothing to decide → leave the part out.
3. **Plan of action** — numbered steps, one line each. The last step is a read-back. Then
   one line naming what this will not touch.
4. **The exact draft** — the artifact itself, verbatim, in a code block. Never a
   description of it.
5. **Close** — one line: what approval runs, and what is still waiting on the engineer.

## Writing the draft

- Outcomes, not activity: "X shows Y", not "changed X to show Y".
- Group by area. "Not in this ticket" goes last, each item with its pointer.
- No narrative, no instructions to the reader, no dates or names.
- Lines of 100 characters or fewer. More is needed → a `file:line` or doc pointer.
- Keep the destination's structure and everything it embeds: attachments, images, links.
- One version. Rewrite in place; never append an "Update" section.

## Running it

- Back up before overwriting.
- Approval covers the draft shown. A change after approval is shown again first.
- Read the result back and report any difference from the draft.
- Approval for one write does not carry to the next.

## Example

````
**What I checked**
- Ticket description (6 bullets, 2 images), the plan file, the branch diff [read]
- Backup of the current description: `<scratchpad>/TICKET-123-before.json` [ran]

**Decide first: the export bug**
The plan moved it to the follow-up ticket; the follow-up as filed does not list it.
- (a) List it under "Not in this ticket" as not reproduced.
- (b) Add it to the follow-up too.
I'd suggest (a).

**Plan of action**
1. Replace the description in one edit; images stay beside their item. No comment.
2. Read it back; every item present, no line over 100 characters.
3. Not touching: status, links, the follow-up ticket.

**Proposed description**
```
Review feedback on the Orders report, shipped in MR !40.

Filters
• "Cancel" → "Clear All"                         [image]
• Region list sorts A-Z, 10 visible, more on scroll

Not in this ticket
• Saved filters → <follow-up ticket>
• Export bug: not reproduced                     [image]  ← (a) or (b)
```

Approve as written, or give me the (a)/(b) call and any wording changes.
````
