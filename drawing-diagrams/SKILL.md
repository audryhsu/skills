---
name: drawing-diagrams
description: Use when drawing, reviewing, or planning any engineering diagram - system architecture, service map, onboarding overview, request or code flow inside a service, design-doc diagrams - in any tool (Mermaid, Figma, FigJam, excalidraw)
metadata:
  version: 1.0.0
  category: documentation
---

# Drawing Diagrams

## Overview

A diagram answers **one question for one reader**. Everything else follows from that question: which view, which zoom level, which form, what to leave out. This skill is tool-agnostic. Decide the content here, then render it with a tool skill (e.g. `mermaid-diagrams`, `figma:figma-generate-diagram`).

Grounded in ISO/IEC/IEEE 42010 (viewpoints per concern), C4 (zoom levels), Kruchten 4+1 (separate views), Vessey's cognitive fit, Moody's Physics of Notations, and Larkin & Simon (locality). Aim for a clear sketch, not notation compliance (Petre 2013).

## Step 1: Write the brief before drawing anything

For **each** diagram, write these five lines first. The brief is working notes. Don't paste it into the doc. Only the question goes in, as the diagram's heading or caption.

```
Question: How does a pod create request reach a host?
Reader:   new backend engineer, first week
View:     behavior            (structure | behavior | deployment)
Level:    L2 container         (L1 | L2 | L3 | n/a for state machines and deployment)
Form:     sequence diagram     (see form table)
```

If you can't write a single question, you have two diagrams. If the requester insists on one picture, draw the question that matters most, then cover the rest in tables and prose and say what you left out. Don't merge views to satisfy "one picture". If the facts you were given don't serve the question, leave them out. Being handed a fact is not a reason to draw it.

## Step 2: One view, one level per diagram

**Views (Kruchten): never mix them in one picture.**

| View | Shows | Does NOT show |
|---|---|---|
| Structure | what exists and what depends on what | call order, regions, clouds, hosts, runtimes as boxes |
| Behavior | what happens over time for one scenario | every possible path; infrastructure grouping |
| Deployment | where things run (cloud, region, cluster, DC) | call order, internal modules |

AWS/region/datacenter/k8s groupings are deployment. In a structure diagram, the runtime goes in the element's type label (`Go, ECS`), not in a surrounding box. A boundary box around one container's components (L3) is structure and is fine.

**Zoom levels (C4): never mix them in one picture.**

| Level | Elements | Typical question |
|---|---|---|
| L1 Context | the system as ONE box; users; external systems | "What does this system talk to?" |
| L2 Container | separately deployable/runnable units: services, DBs, queues | "Which services handle X and how do they talk?" |
| L3 Component | major modules inside ONE container; neighbor containers appear only at the edge | "How is the Scheduler organized internally?" |
| L4 Code | classes/functions. **Don't draw.** Link to the code. | n/a |

Dynamic (sequence) diagrams pick one level too. Lifelines are all containers (L2) or all components of one container plus edge neighbors (L3). Do not mix the two.

## Step 3: Match the form to the question (cognitive fit)

| Question is about | Form |
|---|---|
| order over time, causality, request flow | sequence diagram |
| structure, dependencies | box-and-arrow / component graph |
| an entity's lifecycle | state machine |
| comparing options or listing codes/fields | **table**, not a diagram |
| where things run | deployment diagram |

## Step 4: Drawing rules

- **5-12 elements per diagram** (Cowan: ~4 chunks of working memory). Sequence diagrams: at most 6 lifelines and 1 level of `alt`/`loop` nesting. Past that, split by sub-question or zoom out. Don't cram.
- **Label every element** with a name, a type or technology, and a one-line responsibility: `Scheduler - Go service - picks host, reserves GPU`. A generic type (`service`, `module`) is fine when the technology is unknown.
- **Label every edge** with a verb plus protocol: `enqueues start-pod job (SQS)`. Don't leave edges unlabeled. State machine transitions get their trigger (`backend provisioned`) when it's known.
- **Never invent a missing fact.** If the protocol or trigger is unknown, write the verb alone and list the gap as an open question under the diagram.
- **No function signatures or SQL in labels.** Name the intent (`reserve GPU`), and put `file:line` in prose under the diagram. Table, queue, and topic names are fine.
- **One symbol, one meaning, with a legend.** Use 2-4 shape types, each meaning one thing. Pick one meaning for solid arrows (call direction, data flow, or dependency) and state it. If you don't know who calls whom, use data flow. Every dashed line, color, note, or special shape gets a legend entry. If a style isn't worth a legend entry, don't use it. Each diagram has its own legend, so a dashed arrow can mean "reply" in a sequence and something else in a component graph.
- **Collapse a component and the store it wraps** (e.g. Inventory + its Redis cache) into one element, unless the question is about that boundary. Draw a store that several services share once.
- **Stores in sequences:** make them lifelines if you stay within 6. Otherwise fold them into a note that names the store.
- **Names stay the same across levels.** The L2 box "Scheduler" means the L3 diagram is titled "Scheduler" and the code reference uses that name. Don't use "DC storage backend" in one diagram and "Ceph cluster" in another for the same thing.
- **Layout follows the flow.** Entry point first, left-to-right or top-to-bottom. Put things that interact next to each other.
- **Drop cross-cutting noise** (logging, metrics, auth middleware) unless it's the question. Mention it in one prose line.

## The two common modes

**Macro: "help me understand the system."** Produce a linked set, not one map:
1. L1 context (system as one box). Optional if the reader already knows the boundary.
2. L2 container structure, 5-12 boxes.
3. One dynamic diagram per key scenario, at L2.
4. A state machine if an entity lifecycle matters.
5. A deployment diagram only if the reader's question involves where things run.

**Micro: "how does code flow inside service X?"**
1. L3 component structure of X. Neighbor containers appear as single boxes at the edge.
2. A sequence at L3 for the happy path. If error or retry paths would push nesting past one level, cover them in a second diagram or in a table of outcomes.
3. Link to the code for L4. Don't draw it.

## The doc around the diagram (Diátaxis)

Architecture diagrams are **explanation**: how and why the system works. In that section, keep:
- the diagrams, their questions, and why-prose (decisions, trade-offs)

Move these elsewhere and link to them:
- full lists of API fields, error codes, config and env vars → **reference**
- operational commands and procedures (`drain`, `rollback`) → **how-to / runbook**

These stay, because they explain behavior or a decision: an options-comparison table with the reasoning behind the choice, and an outcomes table for a flow's failure paths, even if it names error codes. If the reference or how-to page doesn't exist yet, leave a link stub saying what it should hold.

## Red flags: stop and split

- You can't state the question in one sentence
- You pasted the brief into the doc
- You wrote a protocol or trigger that wasn't in your sources
- Cloud/region/DC boxes appear in a structure diagram or sequence
- More than 12 boxes or 6 lifelines
- A service and its internal modules appear side by side
- A label looks like `Foo(bar, baz)` or contains SQL
- An unlabeled arrow, or a dashed line or shape with no legend entry
- The architecture section contains a CLI command or a field-constraints table

## Handoff to a rendering skill

Pass the brief (question, reader, view, level, form), the element list with labels, the edge list with verb + protocol, and the legend. The tool skill owns syntax and validation. This skill owns content.
