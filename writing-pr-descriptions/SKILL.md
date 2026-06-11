---
name: writing-pr-descriptions
description: Use when writing or drafting a pull request description, before running gh pr create or editing a PR body
---

# Writing PR Descriptions

Write PR descriptions that explain **why** the change exists and **what impact** it has — not a line-by-line changelog of what files were touched. The code diff already shows what changed. The description should tell reviewers and future engineers what they _can't_ see in the diff.

## Audience

The reviewer is a senior engineer who didn't work on this feature. They need to understand:

- **Context** — why does this PR exist, what's the state of the world
- **Risk** — what could go wrong, what's the blast radius
- **Decisions** — what tradeoffs were made and why

They do NOT need:

- Internal implementation semantics they can read in the diff (file names, function signatures, type definitions)
- Design doc references or internal working notes — the PR description should be self-contained
- Details about PRs or branches that don't exist yet — only mention concrete, landed work

## The litmus test

**For every sentence, ask: does this change what the reviewer checks, approves, or worries about in this diff? If not, cut it.** The ticket and design doc hold the rest.

This is the master filter. Every section below is a guide for what _can_ go in a PR — this test decides what actually does. When a section's guidance and this test conflict, the test wins.

### Anti-pattern: epic/session context leak

When a PR caps off a long design discussion, you accumulate context — sibling tickets, carved-out scope, alternatives debated, tangents raised in review. Most of it belongs in the ticket, not the PR. **Default to excluding it.** A reviewer reading the diff cold should not need the epic's roadmap.

This is the most common way a description bloats: the author knows too much. The diff is small; the discussion behind it was large. Write for someone who only sees the diff.

## Before Writing

### 1. Find the PR template

Every repo has one. Check in this order:

```
.github/pull_request_template.md
.github/PULL_REQUEST_TEMPLATE/        # multiple templates (rare)
pull_request_template.md              # repo root fallback
```

**The template is the skeleton. Never ignore it, never fight it.** Fill in every section it provides. If it has a checklist, complete the checklist. If it has a "Related" section, populate it.

If no template exists, use the minimal structure from the Writing the Description section below.

### 2. Clarify dependencies with the human

**Before writing, ASK the human about the state of any cross-repo or cross-PR dependencies.** Don't guess or assume based on branch names you've seen in the codebase. Specifically ask:

- Which dependent PRs have already been merged?
- Which are still open/pending?
- Are there deploy-order constraints (e.g. "backend must deploy before frontend")?

This matters because the PR description should only reference dependencies that are real and actionable for the reviewer. Mentioning merged PRs as dependencies is confusing. Mentioning branches that don't have PRs yet is noise.

**Rule:** Only list something as a dependency or "related" if it's an open PR that must merge before or after this one. Merged work is context, not a dependency.

### 3. Gather context

Before drafting, collect:

- The ticket/issue driving this work (Linear ID, GitHub issue)
- What problem exists today and who it affects
- Any related PRs — **confirmed with the human** as open and relevant
- Architectural decisions or tradeoffs made
- What you explicitly chose NOT to do

## Writing the Description

### The opening: Lead with why

The first 1-2 sentences under the title/summary should explain the **problem or motivation**, not describe the code changes. A reviewer should understand _why this PR exists_ before they read a single line of diff.

**Good** — problem-first:

> Hub tests have had a high failure rate, with the majority caused by `SUPPLY_CONSTRAINT` errors during test pod deployment. Investigation revealed that the retry loop was retrying the same GPU type 3 times, and stale `allowedCudaVersions` in user configs were filtering out machines with newer CUDA drivers.

> CPU endpoints with legacy `containerDiskInGb` values exceeding the instance limit could not be updated. The old flow has two problems stemming from the fact there are two separate react forms managing form state and validation in the EditEndpoint modal.

> The `dataCenters.gpuAvailability` resolver returned inflated `stockStatus` values (e.g., "High") compared to the `gpuTypes.lowestPrice` resolver (e.g., "Low") for the same GPU type and datacenter.

**Bad** — what-first:

> Updated the retry logic in hub tests to try different GPU types.

> Changed the EditEndpoint modal to use a single mutation.

> Modified the gpuAvailability resolver.

For small/obvious changes, the opening can be shorter but still explain _why_:

> Private pool eligibility for serverless deployments is fully rolled out. This removes the PostHog feature flag gate so pool eligibility is always checked.

### Root cause (when applicable)

If fixing a bug, include a `## Root Cause` section or weave it into the opening. Be specific about the mechanism, not just the symptom.

> **Root Cause:** The resolver had a legacy code path that ran when no `input` was provided. This path had two critical bugs:
>
> 1. The Prisma `include: { machines }` didn't inherit the `where` filters, counting GPUs from **all machines globally** instead of the target datacenter
> 2. Missing filters present in `getLowestPrice`: `registered`, `verified`, `poolState`, machine affinity, `NodeGroup` restrictions, `minPodGpuCount`

### Changes section

If the template has a Changes section (or the PR warrants one), organize by **impact**, not by file. Use bold labels to group logically:

> - **GPU pool fallback**: When a test pod fails to deploy with `SUPPLY_CONSTRAINT`, the retry loop now tries a different GPU type on each attempt.
> - **Test deployment progress logs**: Writes deployment progress to Tinybird so users can see retry attempts and failure details.
> - **S3 bucket policy**: Added `PublicReadGetObject` policy to match what's manually configured in prod.

Mention file names only when the audience needs them (e.g., so a reviewer knows which files have the important logic vs. mechanical cleanup).

### Key decisions (when tradeoffs exist)

Add a `## Key decisions` section when you made architectural choices that aren't obvious from the diff. Focus on **tradeoffs the reviewer might question** — not implementation details they can see in the code.

**Good** — tradeoffs the reviewer cares about:

> - **SQS content-based dedup** instead of DB-backed tracking — simpler, no schema change, 5-minute dedup window is acceptable for now. If it proves insufficient we can add explicit tracking later.
> - **Allowlist of stop reasons** instead of `if (stopReason)` — prevents future stop reasons from accidentally triggering the wrong notification template.

**Bad** — implementation details visible in the diff:

> - `lastStatusChange` string is **not modified** — it stays as `"Exited by RunPod: {date}"` for host daemon calls
> - `stopReason` is only acted upon when `context.auth.isHostDaemon()` is true
> - Fields are optional, so existing callers are unaffected

The reviewer can see these in the code. Key decisions should answer "why this approach over the alternatives?" not "what does the code do?"

### Out of scope

**Only list an out-of-scope item if a reviewer would otherwise flag it looking at _this_ diff** — e.g. "this code clearly touches X, why not handle it?" Do not enumerate adjacent tickets in the epic. **Prefer zero out-of-scope lines over a list of ticket IDs.**

The trap: "show you considered it" invites a laundry list. The point isn't to prove you thought broadly — it's to pre-empt the specific question this diff provokes.

> **Out of scope:** Eventually we should consolidate into 1 form in `Configure` or share a form controller between `Configure` and `TemplateFormHook`. This PR scopes to fixing the immediate blocking bug.

> **Not changed:** Oversubscription limits (1.5x per-endpoint per-machine, 5x total per-machine) are enforced by the control plane resolver, not here. This keeps the ai-api side simple.

Both examples work because a reviewer looking at the diff would naturally ask "why didn't you also touch this?" — the line answers a question the code raises. Don't over-explain. A sentence or two is enough.

### Related PRs and dependencies

Only mention PRs that are **open and relevant to the reviewer's decision**. Merged work is background context (mention it in the opening if needed), not a dependency.

**Good** — open PR with deploy-order constraint:

> **Depends on:** https://github.com/runpod/RunPod/pull/4207 (adds `poolMemberships` to User GQL type). Backend must deploy first.

**Good** — merged prerequisite mentioned as context in the opening:

> AE-1078 added the ability for the host daemon to stop pods with a reason (host and proxy PRs already merged).

**Bad** — listing merged PRs as dependencies:

> | Repo | Branch | Status |
> | host | ae-1078 | Merged |
> | proxy | ae-1078 | Merged |

**Bad** — referencing branches that don't have PRs yet:

> A follow-up host daemon PR (`audry/ae-2708-sls-stop-pod-with-reason`) will...
> Design doc is at `host-ae-2708/docs/design.md`

For pending follow-up work, keep it brief and forward-looking without referencing internal branch names or file paths:

> **Serverless path** — pending a follow-up host daemon change to call `podStop` via mproxy for serverless workers.

**Naming other tickets:** Name another ticket only when the reviewer must act on it — a hard dependency or a deploy-order constraint. "Related but not blocking" tickets are noise: the Linear ticket already links its siblings, so don't duplicate the graph in the PR.

### Testing section

Be specific. State what you actually did, not what you plan to do.

- Exact test counts: "31 passing (22 new + 9 existing)"
- Manual verification steps with concrete results
- Tables for before/after comparisons when they add clarity
- For trivial changes: "N/A - documentation only change" is fine

**Good:**

> - Deployed to audry stage and verified both APIs return matching `stockStatus` for the same GPU/datacenter
> - Tested with empty input, with explicit input, and confirmed parity with `lowestPrice` resolver
> - All 2251 unit tests pass, lint clean

**Bad:**

> - Tested locally
> - Looks good

## Voice Guide

Write like you're explaining the change to a sharp colleague over Slack — direct, specific, no filler.

- **Lowercase, conversational** — not corporate-formal. "this removes the flag" not "This change implements the removal of the feature flag."
- **Specific over vague** — name the actual values, counts, thresholds. "extended from 29 to 62 days" not "increased the lookback period."
- **Em dashes for asides** — use them naturally for parenthetical context.
- **Bold for emphasis** — use inline `**bold**` to highlight key terms and decisions.
- **No filler phrases** — cut "In order to", "This PR aims to", "As part of our effort to". Just state what's happening and why.
- **Backticks for code references** — function names, field names, config values, error messages.

## The deletion pass

After drafting, do one pass with the opposite goal: **try to remove each sentence and section.** For every line, ask the litmus test — does this change what the reviewer checks, approves, or worries about in this diff? Keep only what survives. Sibling tickets, debated alternatives, and "for context" asides are the first to go.

Drafting adds; this pass subtracts. Both are required. A description you only ever added to is almost always too long.

## Checklist

Before submitting:

- [ ] PR template sections are all filled in
- [ ] Opening explains the problem/motivation, not the code changes
- [ ] A reviewer can understand _why_ without reading the diff
- [ ] **Confirmed dependency state with the human** — only open PRs listed as dependencies, merged work is context
- [ ] No internal branch names, design doc paths, or working notes in the description
- [ ] Key decisions focus on tradeoffs, not implementation details visible in the diff
- [ ] Related PRs are linked with merge-order dependencies noted
- [ ] Testing section has specific, concrete results
- [ ] Out-of-scope lines only answer a question this diff raises — no epic-sibling ticket IDs
- [ ] Other tickets named only when the reviewer must act on them (hard dependency / deploy order)
- [ ] Ran the deletion pass — every surviving sentence passes the litmus test
- [ ] No "updated X", "changed Y", "modified Z" as the entire description
