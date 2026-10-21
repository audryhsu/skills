# Micro mode: code flow inside one service

The service is the container. Draw its components (L3), and nothing smaller.

1. **L3 component structure** (skip it if the sequence already shows every component and no one is asking how the service is organized): the service's major modules inside a boundary box titled with the service's L2 name. Neighbor containers (DBs, queues, callers) sit outside it as single boxes.
2. **Happy-path sequence at L3:** lifelines are the components plus at most one or two edge neighbors, 6 in total. Messages state intent (`reserves GPUs on chosen host`), not signatures.
3. **Failure and retry paths:** if they would push nesting past one level, cover them in a second sequence or in an outcomes table (situation, what the service does, what the caller gets, resulting state).
4. **Code links:** list the files or packages under the diagrams. Don't draw functions.

## Common traps

- Function calls as messages: `Candidates(gpuType, gpuCount, region)`.
- SQL or query details in notes. Write `locks host GPU rows`, not `SELECT ... FOR UPDATE`.
- A component and its cache or DB as separate lifelines. Collapse them unless the cache is the question.
- `alt` inside `alt` inside `loop`. Use the outcomes table.
- Drawing the auth interceptor or metrics calls. Mention them in prose.
