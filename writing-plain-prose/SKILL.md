---
name: writing-plain-prose
description: Use when writing anything a person will read - reports back to the user after a task or research, summaries, PR descriptions, code review comments, Slack replies, emails, design docs, plans, SOPs, root cause analyses, audits. Also use when another writing skill defers to it for prose style.
---

# Writing Plain Prose

## Overview

Readers are busy and have limited working memory. Every word, sentence, and section should reduce the effort it takes to understand and act. Simpler must never mean less accurate.

When rules conflict, `references/research.md` explains why each one works so you can weigh them.

If another skill sets the format (a PR template, Slack markdown, a doc template), its format wins. Apply these rules to the prose inside it.

## Before you write: purpose and audience

Name both before writing a word. They go together: the purpose decides what to say, and the audience decides how much to explain.

- **Purpose**: what is this document for? Sharing knowledge, getting a decision, opening a discussion, documenting a procedure, or explaining a failure each lead to a different document.
- **Audience**: who reads it, and what do they already know? Write for what they know, not for what you know.

If you can't name either one with confidence from the request and its context, ask the human before writing. Editing can't fix a document written for the wrong purpose or the wrong reader.

## Order

Every document follows this order. In a short message, each step may be a single clause.

1. **Purpose and problem statement.** What this document is for, and the problem it addresses. If the purpose is a decision, say which decision and who makes it. This frames everything after it.
2. **Context the reader needs.** Only what this audience lacks to understand the problem and judge what follows, such as how the system works.
3. **The main content, most important first.** Findings, the recommendation, steps, or options. Order by importance, not by the order you discovered things.
4. **Open items.** Open questions, owners, and next steps, in their own labeled section.

## Stay accurate while simplifying

Compressing findings tempts you to round claims up. Don't.

- State only what your sources support. Don't turn "some" into "most", "tested on staging" into "verified", or a correlation into a cause.
- Tables invite filling every cell. If your sources don't cover a cell, leave it blank or write "unknown".
- Keep the exact numbers, names, and dates the reader needs.
- Say uncertainty once, where it applies. No blanket hedging.

## Drop agent habits

- **Labels you coined while working** ("Option B", "problem 1", "the v2 path"). The reader never saw them. Name the thing itself.
- **Telegraphic shorthand**: arrows (→), dropped articles, slash-lists ("fix/verify/ship"). Write full sentences.
- **Process narration** ("First I checked X, then Y"). Report the result. Mention a ruled-out cause only if the reader would otherwise ask, and put it after the finding.
- **Preambles and recaps**: restating the question, "Here's a summary", a closing paragraph that repeats the opening.
- **Headers and bold on short messages.** Under about 150 words, use plain paragraphs.

## Words

- Prefer common, short words. Define jargon on first use or cut it.
- Prefer concrete words: a number, a name, an example.
- Use verbs, not nouns made from verbs: "decide", not "make a decision".

## Sentences

- One main idea per sentence. Split sentences that carry two.
- Keep the subject and verb close together, near the start.
- Put familiar information first and new or important information last.
- Use active voice unless the actor is unknown or doesn't matter.

## Paragraphs

- One idea per paragraph, with the point in the first sentence.
- Make links explicit with "because", "so", and "however".
- Cut anything that doesn't serve the document's purpose, even if it's interesting.

## Long documents

Readers scan for the point, read the parts relevant to them, and come back later to look things up.

- Write headings that carry the point. Weak: "Database". Strong: "Use Postgres; DynamoDB doesn't fit our query patterns". The headings alone should give the gist.
- Use at most two or three heading levels, with one topic per section.
- When several things need action, number them and name each owner.
- For plans, show steps, owners, and dependencies at a glance. A table often works.

## Formatting

- Use enough formatting to help scanning, and no more.
- Use bullets only for parallel items: options, steps, requirements. Keep reasoning and tradeoffs in prose, where "because" and "so" survive.
- Bold only the few words a skimmer must not miss.
- Use tables to compare several items across the same attributes.
- Use code formatting for identifiers the reader will search for or type.

## Final pass

Reread it cold, as the reader. Then:

- Check every claim against your sources.
- Cut every sentence that doesn't serve the purpose.
- Confirm the purpose and problem statement come first.
