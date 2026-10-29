---
name: pragmatic-plan-review
description: Review plans or implemented code using principles from The Pragmatic Programmer. Use after brainstorming or planning, or for a post-implementation code review.
---

# Pragmatic Design Review

Review the plan or implementation identified by the user or current context. If the target is unclear, ask which plan, diff, PR, or code to review. Preserve its goals, constraints, and scale. Propose corrections without modifying plans or code unless asked.

- **Plan review:** Read the agreed plan; inspect referenced code when needed to resolve a material claim.
- **Code review:** Inspect the implementation or diff, relevant callers, and tests. Use any agreed plan as context, but assess the actual code. Focus on the requested scope; follow dependencies only to establish concrete impact. Run focused checks when useful and feasible, and distinguish tests inspected from tests executed. A plan is not required.

## Review lenses

Prioritize these six:

- **Orthogonality:** Can one responsibility change without affecting unrelated behavior? Look for mixed responsibilities and hidden side effects.
- **Decoupling:** Are dependencies explicit and narrow? Look for knowledge of another component's internals, global state, and unnecessary ordering dependencies.
- **DRY:** Does each business rule or fact have one authoritative owner across code, schemas, configuration, and documentation? Similar syntax alone does not justify sharing; independently changing concepts should remain independent.
- **Easy to change:** Are likely changes localized? Prefer simple boundaries and composition; trace how a requirement change propagates.
- **Reversibility:** Which decisions would be expensive to undo? For consequential commitments, identify a practical replacement, migration, or rollback path and its cost. Add isolation only where switching risk warrants it.
- **Avoid speculative design:** Does each abstraction or extension point serve a demonstrated need or a plausible change grounded in requirements? Prefer the simplest sufficient design; defer flexibility whose current complexity outweighs its likely benefit.

Then check what applies:

- **Contracts and state:** Clear inputs, invariants, failures, resource ownership, and coordination of concurrent mutations.
- **Feedback:** Independently testable behavior, meaningful boundary cases, and a small end-to-end increment; use a prototype to resolve consequential uncertainty.
- **Pragmatism:** Explicit assumptions, domain vocabulary, user-visible success criteria, proportionate security/performance considerations, and repeatable validation and delivery.

## Apply judgment

Stress-test the design with two plausible changes grounded in its requirements: one business-rule change and one dependency or integration change (substitute another relevant change if there is no integration). Trace the affected components, knowledge owners, and tests. Identify where changes unexpectedly spread or require synchronized edits.

Use specific plan sections or code locations as evidence; distinguish inspected facts from assumptions. For code findings, identify a concrete failure or maintenance scenario, not just a stylistic preference. Missing detail is an uncertainty, not proof of a defect. Ask only questions whose answers could materially change the recommendation.

Recommend the smallest useful correction. Explain the concrete change it makes easier and the complexity it introduces. Do not prescribe services, interfaces, frameworks, or deduplication solely to satisfy a principle. Resolve competing principles in favor of simpler, safer changes within the actual scope.

## Return

Keep the review brief, usually under 400 words:

1. **Verdict:** Ready, Revise, or Needs clarification, with one sentence explaining why. Ready means no material design issue found within the reviewed scope.
2. **Core checks:** One compact line for each of the six priority lenses: supported, concern, or unknown, with evidence. Summarize the change scenarios here where useful; mark reversibility not applicable if there is no consequential commitment.
3. **Findings:** Only actionable issues, highest impact first. For each: plan section or file and line → consequence → smallest proposed correction. Separate necessary corrections from optional improvements; do not invent findings to fill a quota.
4. **Uncertainty and validation:** Only consequential unknowns or review limits; for code reviews, briefly state checks run and any relevant validation gaps. Do not imply unexecuted tests passed.

This is a focused design review, not certification of every practice in the book. The review procedure is an adaptation of Thomas and Hunt's *The Pragmatic Programmer*, 20th Anniversary Edition: [official tips](https://pragprog.com/tips/), [DRY excerpt](https://media.pragprog.com/titles/tpp20/dry.pdf), and [shared-state excerpt](https://media.pragprog.com/titles/tpp20/shared-state.pdf). These are background references; routine use needs no browsing.
