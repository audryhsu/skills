# Macro mode: understanding a system

Make a linked set of small diagrams, not one big map. Give each one its own question as its heading.

1. **L1 context** (optional): the system as one box, with users and external systems around it. Skip it if the reader already knows the boundary.
2. **L2 container structure:** 5-12 services, stores, and queues, with labeled edges. Leave out regions and clouds.
3. **One sequence per scenario the reader needs**, at L2, e.g. "How does a pod create request reach a host?". Background loops (heartbeats, billing jobs) get their own sequence. Don't append them to a request flow.
4. **State machine** if an entity's lifecycle matters to the reader.
5. **Deployment diagram** only if where things run matters to the reader: multi-region, partner-owned hosts, a single DB primary. It holds placement only, with no call arrows.

Decisions and option comparisons go in a table with the reasoning. Don't draw them.

## Common traps

- One "system map" that holds every fact from the notes. Split it by question.
- AWS, colo, and DC boxes wrapped around services in the structure diagram. Move them to the deployment view.
- An API Gateway, auth provider, or Datadog box that doesn't answer the question. Mention it in one prose line.
- More than 6 lifelines in the request sequence. Fold stores into a step such as `pick host (inventory + availability)`.
