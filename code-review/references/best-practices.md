# Best Practices

## React Anti-Patterns to Avoid

- **Don't use `useRef` as a substitute for state** — refs don't trigger re-renders. If
  the UI needs to respond to a value changing, it should be state. Use refs only for DOM
  access or values that genuinely don't affect rendering (e.g. tracking previous render
  values for comparison).
- **Don't derive state from props in `useState` initialization** — `useState(props.value)`
  only runs once. If the prop changes, the state won't update. Derive directly in render,
  or use `useEffect` with caution.
- **Don't put logic that belongs in a parent into a child component** — if a child needs
  to call up to change something, that's a signal the state/logic lives in the wrong place.
- **Don't overuse `useEffect`** — most data transformations, derived values, and event
  responses don't need one. Prefer computing directly in render or in event handlers.
- **Don't create abstractions for one-off operations** — three similar lines is better
  than a premature helper. Only abstract when the pattern repeats meaningfully.
- **Don't add unnecessary loading/error states** — trust framework guarantees (router
  loaders, fetchers) rather than layering manual state on top.
- **Avoid conditional hook calls** — hooks must always be called in the same order. No
  hooks inside if-blocks, loops, or early returns. Use a `disabled` option instead.
- **Don't use two components where one will do** — particularly for toggle/success
  states: mounting/unmounting causes timing issues. Keep one component mounted and let
  state drive its appearance.
- **Don't use `useEffect` to sync one piece of state to another** — if a value can be
  derived from existing state or props, compute it directly in render. A `useEffect` that
  watches state A to set state B is almost always a sign that B shouldn't be state at all.
- **Don't define components or `renderX` functions inside a component body** — they get
  redefined on every render, break memoization, and are a holdover from class component
  patterns. Extract them outside the component or pass JSX as props.
- **Use the functional updater form when new state depends on old state** —
  `setState(prev => ...)` instead of `setState(currentValue + 1)`. Stale closures inside
  `useOptimistic`, `startTransition`, and async handlers will silently produce wrong
  state otherwise.
- **Don't overuse context** — context is easy to add but hard to remove. Prefer passing
  data explicitly through loaders/outlet context. If reaching for context, ask whether
  the data could come from a loader instead.

## General Code Quality

- **Minimal and as un-invasive as possible** — the right amount of code is the minimum
  needed. If a change can be smaller, make it smaller.
- **Scope-decoupled** — changes should not reach beyond what the ticket requires. If a
  fix requires touching something unrelated, flag it rather than silently expanding scope.
- **No backwards-compatibility shims for removed code** — don't rename to `_unused`,
  re-export removed types, or leave `// removed` comments. Delete cleanly.
- **Validate at boundaries, trust internals** — validate user input and external API
  responses. Don't add defensive checks inside code you control.
- **Follow existing repo patterns first** — before introducing a new approach, check how
  the repo already solves it.

## Security (from OWASP)

- **Always guard server-side mutations** — don't rely solely on UI locks. If a UI element
  is disabled, the server handler must also reject the request when the condition isn't
  met.
- **Validate and sanitize all inputs at the request boundary**, not deeper in.
- **Never trust client-sent identifiers or flag state** — re-read both from the server's
  own source of truth.
