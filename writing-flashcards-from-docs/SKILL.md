---
name: writing-flashcards-from-docs
description: Use when turning a documentation link or article into spaced-repetition flashcards - fetches and extracts core ideas, compares against existing cards/notes, right-sizes output by source density and existing coverage, updates only incorrect/outdated cards, and creates missing cards with strict citation, slug, and tag rules
---

# Writing Flashcards From Docs

## Overview
Turn a source link (docs/article) into **high-signal flashcards** without damaging accurate existing cards.

**Core principle:** *Don’t churn the vault.* Only change a card when you can point to a specific, authoritative source section showing it is wrong/outdated.

## When to Use
Use this when you are asked to:
- “Make flashcards from this link” / “turn this doc into cards” / “update our cards from docs”
- Refresh cards for an exam (#SAP-C02, etc.)
- Merge new documentation into an existing knowledge base

Do **not** use this when:
- The input is not a stable source link (no URL / no permalink)
- The task is pure note-taking (not Q/A recall)

## Output Format (Non‑Negotiable)
Each flashcard must be exactly:

```md
**<question>** #card <optional tags>
<answer>
[^<slug>]: <source link>
```

**No extra structure:** don’t add `###`, `Card 1`, `Q:`/`A:` labels, bracketed headers like `[topic]`, horizontal rules, tables-of-contents, or trailing metadata blocks.

**Hard requirement:** The final output must contain only flashcards.

**No exceptions:** If anything like `<task_metadata>…</task_metadata>`, `session_id`, tool output summaries, or any other non-card text appears, delete it and output only flashcards.

Rules:
- `#card` is mandatory.
- Output **only cards** (no headings like `###`, no commentary, no extra metadata).
- Never use vault links in the **question** (no `[[...]]` in questions).
- Answer may use Markdown: lists, tables, code blocks.
- For internal vault references in the **answer**, use wiki links:
  - `[[AWS Lambda]]`
  - `[[AWS Lambda|Lambda]]` (override display text)
- When you mention a topic that likely has an existing note (languages, services, core concepts), prefer a wiki link (e.g., `[[Python]]`, `[[Java]]`). If you’re unsure a note exists, leave it unlinked.
- The footnote must reference the **original source document**, not other flashcards.

## Quick Reference

Before you output anything:
1. Fetch the source link.
2. Extract candidate facts/contrasts (don’t target a fixed number).
3. Search vault for existing coverage.
4. For each candidate: **Update** (wrong), **Create** (missing), or **Skip** (already covered).
5. For each output card: verify format + deep link + slug policy (unique per source link).

## Workflow

### 1) Fetch, Extract, and Right-Size
1. Fetch the provided documentation/article URL.
2. Identify:
   - Definitions (what is X?)
   - Contrasts (X vs Y)
   - Rules/limits (quotas, thresholds, defaults, constraints)
   - “If/then” behaviors (decision rules, exceptions, fallbacks)
   - Lists you must memorize (states, phases, enum values)
3. Prefer subsections that are stable/permalinkable. If anchor links exist, use them.
4. If you cannot confidently support a detail from the source, **omit it** (do not “fill in” from memory).

**Right-size how many cards you create.** Do not precommit to a number (e.g., “make 30 cards”). The correct card count depends on:
- **Information available in the source:** short + shallow sources yield few cards; long + dense references yield more.
- **Existing coverage quality:** if the vault already covers it accurately, you will mostly **skip** (and may output very few cards).
- **Requested difficulty (if provided):** difficulty changes *what* you select and how deep you go.

If the user demands a fixed quota, treat it as a preference, not a requirement. Never pad with redundant or low-signal cards.

### 2) Compare With Existing Knowledge
Before writing anything new:
1. Search for existing cards/notes about the same topic.
2. Classify each candidate:
   - **Accurate** → do not touch
   - **Outdated/wrong** → update (minimal edit)
   - **Missing** → create a new card

**Update rule:** Update old flashcards **only** if they contain outdated or wrong information.

### 3) Create / Update Cards
For each extracted idea, pick the right action:
- **Update** if the existing card contains a factual error, contradicted by the new source.
- **Create** if the idea is missing in the vault.
- **Skip** if the info is already covered by an existing card/note.

Keep cards:
- Atomic (one fact/contrast per card)
- Specific (avoid vague “tell me about X”)
- Testable (answer can be checked against source)

## Citations, Slugs, and Links

### Source Link
- Use the original documentation/article you were given.
- Prefer a deep link to a subsection/anchor (e.g., `#pod-phase`).
- Do not cite *additional* documents unless explicitly allowed; keep cards grounded in the provided source.
- If you can’t deep link, cite the closest stable section URL.

### Slug
- Slug is a short identifier derived from the question/topic: kebab-case.
- Slug is **unique per source link** (URL).
- If multiple cards cite the exact same URL, they may reuse the same slug (slug uniqueness is scoped to the source link, not to a card).
- Put exactly **one** footnote per card.
- Good: `lambda-runtimes`, `pod-phase`, `iam-managed-vs-inline`.

## Tags
- Always include `#card`.
- Optionally include:
  - `#<exam-code>` (e.g., `#SAP-C02`)
  - `#<secondary-topic>` (e.g., `#iam`, `#sqs`, `#ec2`, `#k8s`)
  - `#<difficulty-level>` (`#easy`, `#medium`, `#hard`) when the user asked for a level

## Difficulty Calibration
When difficulty is specified, select facts and write questions accordingly.

### Easy (`#easy`)
Goal: basic terminology + core concepts; enough to not be lost in a conversation.
- Focus on: definitions, purpose, basic distinctions, common examples.
- Avoid: edge cases, deep tradeoffs, specialized procedures.
- Think: conversational foundation (e.g., intro survey course; beginner language level; “home cook” fundamentals).

### Medium (`#medium`)
Goal: working knowledge; enough to make informed decisions and justify choices.
- Focus on: tradeoffs, constraints, common failure modes, “when to use X vs Y”, practical rules-of-thumb.
- Include: a few key defaults/limits that change real decisions.
- Think: decision-making competence (e.g., intermediate musician choosing technique; marketer selecting strategy; project lead choosing approach).

### Hard (`#hard`)
Goal: expert-level recall; enough to operate at specialist depth.
- Focus on: nuanced exceptions, tricky edge cases, rare-but-important constraints, internals only if the source supports them.
- Include: precise limits, compatibility rules, and “gotchas” that commonly cause real failures.
- Think: specialist mastery (e.g., litigator-level doctrine nuances; clinician-level differential edge cases; competition-level technique).

## One Good Example
```md
**What is the difference between an IAM managed policy and an inline policy?** #card #easy #iam
Managed policies are standalone and reusable across identities; inline policies are embedded in exactly one identity (user/group/role) and aren’t reusable.
[^iam-managed-vs-inline]: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html
```

## Common Mistakes
- Editing cards “to refresh wording” even when accurate (churn).
- Citing another flashcard instead of the source doc.
- Using a top-of-page link when a subsection anchor exists.
- Creating duplicates instead of linking to existing notes with wiki links like `[[AWS Lambda]]`.
- Multi-fact cards that mix definitions + exceptions + limits.

## Rationalization Table (Do Not Believe These)
| Excuse | Reality |
|--------|---------|
| “Boss wants everything refreshed” | Only update when wrong/outdated; accuracy > churn. |
| “Duplicates are fine” | Duplicates rot; link to `[[Existing Note]]` (or `[[Existing Note|Label]]`) or skip. |
| “I can’t deep-link, I’ll cite the root” | Try anchors first; cite the closest stable subsection URL. |
| “I’ll add one more AWS/K8s link to be safe” | Use only the provided source unless explicitly allowed. |
| “I know this from memory; the doc probably says it” | If the source didn’t back it, omit it. |

## Red Flags — STOP
- “I’ll rewrite all cards for consistency.”
- “This seems right from memory; no need to fetch.”
- “The doc is long; I’ll cite the top.”
- “Duplicates are acceptable.”
- “I’ll cite extra docs / API pages to pad accuracy.”
- “I’ll infer missing details.”
