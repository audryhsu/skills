# Drawing rules: details and edge cases

## Views (Kruchten 4+1)

| View | Shows | Does NOT show |
|---|---|---|
| Structure | what exists and what depends on what | call order; regions, clouds, hosts, or runtimes as boxes |
| Behavior | what happens over time for one scenario | every possible path; infrastructure grouping |
| Deployment | where things run (cloud, region, cluster, DC) | call order, internal modules |

In a structure diagram, the runtime goes in the element's type label (`Go, ECS`), not in a surrounding box. A boundary box around one container's components (L3) is structure and is fine.

## Labels

- Element: name, type or technology, and a one-line responsibility, e.g. `Scheduler - Go service - picks host, reserves GPU`. Use a generic type (`service`, `module`) when the technology is unknown.
- Edge: verb plus protocol, e.g. `enqueues start-pod job (SQS)`. Label state machine transitions with their trigger when it's known.
- A protocol implied by the named technology counts as sourced: MySQL for PlanetScale, the Stripe API for Stripe. For calls between modules in one service, write `(in-process)`.
- Name the intent (`reserve GPU`), not the signature (`Reserve(hostID, podID)`). Put `file:line` in prose under the diagram. Table, queue, and topic names are fine.
- If a fact is unknown, don't fill it in. Write the verb alone and list the gap under the diagram as an open question.

## Legends (Moody: semiotic clarity)

Don't use a legend for conventional encodings. Readers already know these:
- rectangle = service or component
- cylinder = data store
- person or stadium shape = user or actor
- solid arrow = calls or sends to
- in a sequence: solid arrow = request, dashed arrow = reply

Add a legend entry only for what a reader could misread:
- **colors** (always: what does red or green mean here?)
- dashed or dotted lines outside sequence diagrams
- unusual shapes, icons, or line weights
- arrows meaning something other than "calls": data flow, dependency, or ownership
- boundary boxes, when what they group isn't obvious from their title

If no encoding needs explaining, skip the legend. If a style isn't worth a legend entry, don't use it. Legends are per diagram.

Use one arrow meaning per diagram. Don't mix call arrows and data-flow arrows. If your sources say two things interact but not exactly how, draw the edge with the verb alone and list the details as an open question. Leave an edge out only when nothing says the interaction exists. If you don't know the direction for most edges, draw the whole diagram as data flow and say so in the legend.

## Showing new vs. changed (design docs)

Reviewers want to see what a change adds. Tag the element label `[NEW]` or `[CHANGED]` so the meaning survives without color. Add a fill color if the renderer supports it, and give the colors a legend entry. An existing element that gets new behavior is `[CHANGED]`. Leave unchanged elements untagged.

## Simplifying

- Collapse a component and the store it wraps (e.g. Inventory + its Redis cache) into one element, unless the question is about that boundary.
- Draw a store that several services share once. If you aren't sure it's shared, draw it once and list that as an open question.
- Merge actors with the same role into one element: the Console, REST API, and SDK become "Clients", and two image registries become "Image registries".
- In a sequence, make stores lifelines if you stay within 6. Otherwise fold them into a note that names the store.
- Drop cross-cutting concerns (logging, metrics, auth middleware) unless they're the question. Mention them in one prose line.

## Layout and naming (Larkin & Simon, Moody)

- Put the entry point first and flow left-to-right or top-to-bottom. Place things that interact next to each other.
- Keep a name identical across levels. If the L2 box is "Scheduler", the L3 diagram is titled "Scheduler" and the code reference uses that name.
- Don't call one thing "Storage Backend" in one diagram and "Ceph cluster" in another.
