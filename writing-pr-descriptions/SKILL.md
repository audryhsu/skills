---
name: writing-pr-descriptions
description: Use when writing or drafting a pull request description, before running gh pr create or editing a PR body
---

# Writing PR Descriptions

**REQUIRED BACKGROUND:** Use writing-plain-prose for prose style. This skill covers only what is specific to PRs.

A PR description explains **why** the change exists and **what impact** it has. The diff already shows what changed. The description tells reviewers and future engineers what they _can't_ see in the diff.

## Purpose and audience

The purpose is to help a reviewer decide whether to approve this diff. The reviewer is a senior engineer who didn't work on this feature. They need:

- **Context**: why this PR exists and the state of the world today
- **Risk**: what could go wrong, and the blast radius
- **Decisions**: the tradeoffs you made and why

They don't need implementation details they can read in the diff, design doc references or working notes, or details about PRs and branches that don't exist yet.

## The litmus test

**For every sentence, ask: does this change what the reviewer checks, approves, or worries about in this diff? If not, cut it.** The ticket and design doc hold the rest. When any section's guidance conflicts with this test, the test wins.

After drafting, make one pass with the opposite goal: try to remove each sentence and section, and keep only what survives the test.

### Anti-pattern: epic and session context leak

When a PR caps off a long design discussion, you accumulate context: sibling tickets, carved-out scope, debated alternatives, tangents from review. Most of it belongs in the ticket. **Default to excluding it.** Write for someone who sees only the diff.

## Before writing

1. **Find the PR template.** Check `.github/pull_request_template.md`, then `.github/PULL_REQUEST_TEMPLATE/`, then `pull_request_template.md` at the repo root. The template is the skeleton: fill in every section and complete any checklist. Without a template, use Summary, Changes, Testing, and Related.
2. **Ask the human about dependencies.** Don't guess from branch names. Ask which dependent PRs are merged, which are still open, and whether there are deploy-order constraints. Only an open PR that must merge before or after this one is a dependency. Merged work is context.
3. **Gather context:** the ticket, the problem today and who it affects, the tradeoffs you made, and what you chose not to do.

## Sections

### Opening: the problem first

The first one or two sentences explain the problem or motivation, not the code change. A reviewer should know why this PR exists before reading any diff.

**Good:**

> Hub tests have had a high failure rate, mostly from `SUPPLY_CONSTRAINT` errors during test pod deployment. The retry loop was retrying the same GPU type 3 times, and stale `allowedCudaVersions` in user configs were filtering out machines with newer CUDA drivers.

**Bad:**

> Updated the retry logic in hub tests to try different GPU types.

### Root cause (bug fixes)

Name the mechanism, not just the symptom, either in a `## Root Cause` section or in the opening.

> The resolver's legacy path for requests without `input` used a Prisma `include: { machines }` that didn't inherit the `where` filters, so it counted GPUs from **all machines globally** instead of the target datacenter.

### Changes

Group changes by **impact**, not by file, with a bold label for each group:

> - **GPU pool fallback**: when a test pod fails with `SUPPLY_CONSTRAINT`, the retry loop now tries a different GPU type on each attempt.

Mention a file only when it tells the reviewer where the important logic is, as opposed to mechanical cleanup.

### Key decisions

Add this section only for tradeoffs a reviewer might question. Each entry answers "why this approach over the alternatives?", not "what does the code do?"

> - **SQS content-based dedup** instead of DB-backed tracking: simpler, no schema change, and a 5-minute dedup window is acceptable for now.

Not: "`stopReason` is only acted on when `isHostDaemon()` is true." The reviewer can see that in the code.

### Out of scope

List an item only if a reviewer looking at _this_ diff would ask "why didn't you also handle X?" Prefer zero lines over a list of ticket IDs from the epic.

> **Out of scope:** consolidating `Configure` and `TemplateFormHook` into one form. This PR only fixes the blocking bug.

### Related PRs and dependencies

Name a PR or ticket only when the reviewer must act on it: a hard dependency or a deploy-order constraint.

> **Depends on:** https://github.com/runpod/RunPod/pull/4207 (adds `poolMemberships` to the User GQL type). Backend must deploy first.

Mention merged prerequisites as context in the opening, not as dependencies. Describe pending follow-ups briefly, without internal branch names or file paths.

### Testing

State what you actually did, with exact results: test counts ("31 passing, 22 new"), manual steps and what they showed, and what you did _not_ test. "N/A, documentation only" is fine for trivial changes. "Tested locally" is not.


## Checklist

- [ ] Every PR template section is filled in
- [ ] The opening states the problem, not the code change
- [ ] Dependency state confirmed with the human; only open PRs listed as dependencies
- [ ] No internal branch names, design doc paths, or working notes
- [ ] Key decisions are tradeoffs, not details visible in the diff
- [ ] Out-of-scope lines answer a question this diff raises; no epic sibling tickets
- [ ] Testing has concrete results
- [ ] Every surviving sentence passes the litmus test
