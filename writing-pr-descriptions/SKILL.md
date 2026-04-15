---
name: writing-pr-descriptions
description: Use when writing or drafting a pull request description, before running gh pr create or editing a PR body
---

# Writing PR Descriptions

Write PR descriptions that explain **why** the change exists and **what impact** it has — not a line-by-line changelog of what files were touched. The code diff already shows what changed. The description should tell reviewers and future engineers what they *can't* see in the diff.

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

### 2. Gather context

Before drafting, collect:
- The ticket/issue driving this work (Linear ID, GitHub issue)
- What problem exists today and who it affects
- Any related PRs (especially ordering dependencies — "must merge first")
- Architectural decisions or tradeoffs made
- What you explicitly chose NOT to do

## Writing the Description

### The opening: Lead with why

The first 1-2 sentences under the title/summary should explain the **problem or motivation**, not describe the code changes. A reviewer should understand *why this PR exists* before they read a single line of diff.

**Good** — problem-first:
> Hub tests have had a high failure rate, with the majority caused by `SUPPLY_CONSTRAINT` errors during test pod deployment. Investigation revealed that the retry loop was retrying the same GPU type 3 times, and stale `allowedCudaVersions` in user configs were filtering out machines with newer CUDA drivers.

> CPU endpoints with legacy `containerDiskInGb` values exceeding the instance limit could not be updated. The old flow has two problems stemming from the fact there are two separate react forms managing form state and validation in the EditEndpoint modal.

> The `dataCenters.gpuAvailability` resolver returned inflated `stockStatus` values (e.g., "High") compared to the `gpuTypes.lowestPrice` resolver (e.g., "Low") for the same GPU type and datacenter.

**Bad** — what-first:
> Updated the retry logic in hub tests to try different GPU types.

> Changed the EditEndpoint modal to use a single mutation.

> Modified the gpuAvailability resolver.

For small/obvious changes, the opening can be shorter but still explain *why*:
> Private pool eligibility for serverless deployments is fully rolled out. This removes the PostHog feature flag gate so pool eligibility is always checked.

### Root cause (when applicable)

If fixing a bug, include a `## Root Cause` section or weave it into the opening. Be specific about the mechanism, not just the symptom.

> **Root Cause:** The resolver had a legacy code path that ran when no `input` was provided. This path had two critical bugs:
> 1. The Prisma `include: { machines }` didn't inherit the `where` filters, counting GPUs from **all machines globally** instead of the target datacenter
> 2. Missing filters present in `getLowestPrice`: `registered`, `verified`, `poolState`, machine affinity, `NodeGroup` restrictions, `minPodGpuCount`

### Changes section

If the template has a Changes section (or the PR warrants one), organize by **impact**, not by file. Use bold labels to group logically:

> - **GPU pool fallback**: When a test pod fails to deploy with `SUPPLY_CONSTRAINT`, the retry loop now tries a different GPU type on each attempt.
> - **Test deployment progress logs**: Writes deployment progress to Tinybird so users can see retry attempts and failure details.
> - **S3 bucket policy**: Added `PublicReadGetObject` policy to match what's manually configured in prod.

Mention file names only when the audience needs them (e.g., so a reviewer knows which files have the important logic vs. mechanical cleanup).

### Key decisions (when tradeoffs exist)

Add a `## Key decisions` section when you made architectural choices that aren't obvious from the diff:

> - `lastStatusChange` string is **not modified** — it stays as `"Exited by RunPod: {date}"` for host daemon calls
> - `stopReason` is only acted upon when `context.auth.isHostDaemon()` is true — prevents users from triggering the error log
> - Fields are optional, so existing callers are unaffected

This section answers the reviewer's "why didn't you just..." questions preemptively.

### Out of scope

When the PR intentionally leaves work undone, say so. This prevents review comments asking you to do things you already considered and deferred.

> **Out of scope:** Eventually we should consolidate into 1 form in `Configure` or share a form controller between `Configure` and `TemplateFormHook`. This PR scopes to fixing the immediate blocking bug.

> **Not changed:** Oversubscription limits (1.5x per-endpoint per-machine, 5x total per-machine) are enforced by the control plane resolver, not here. This keeps the ai-api side simple.

Don't over-explain. A sentence or two is enough. The goal is to show you thought about it, not to justify yourself.

### Related PRs and dependencies

If the change spans repos or has ordering constraints, call it out explicitly:

> **Depends on backend PR:** https://github.com/runpod/RunPod/pull/4207 (adds `poolMemberships` to User GQL type). Backend must deploy first.

> Related: https://github.com/runpod/host/pull/2235
> Related: https://github.com/runpod/proxy/pull/194

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

## Checklist

Before submitting:

- [ ] PR template sections are all filled in
- [ ] Opening explains the problem/motivation, not the code changes
- [ ] A reviewer can understand *why* without reading the diff
- [ ] Related PRs are linked with merge-order dependencies noted
- [ ] Testing section has specific, concrete results
- [ ] Anything intentionally left out is noted as out of scope
- [ ] Key tradeoffs are documented if applicable
- [ ] No "updated X", "changed Y", "modified Z" as the entire description
