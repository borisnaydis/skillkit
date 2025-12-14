---
name: writing-flashcards
description: Use when user requests spaced-repetition flashcards from a documentation/article URL or wants to merge/update an existing flashcard vault file - enforces strict card-only output formatting, deep-link footnote citations with stable slugs, and zero-duplicate minimal-churn updates based only on provided sources.
---

# Writing Flashcards

## Overview
Convert one or more documentation URLs into Q/A flashcards that are atomic, source-checkable, and deduplicated against an existing vault. Prefer *skipping* or *minimally updating* existing cards; create new cards only for missing, citation-backed facts.

## When to Use
- User asks: “make flashcards from this doc/article”, “exam refresh”, “merge docs into my existing vault”.
- You have (or can be given) an existing vault file/folder to deduplicate and update.

## When NOT to Use / Refuse
Refuse or stop if **any** of the following is true:
- No stable source URL/permalink is provided ("I read it yesterday" / screenshots-only / memory-only).
- User wants pure note-taking/summarization, not Q/A recall.
- You cannot cite using the provided URL(s) only and user did not explicitly allow additional sources.

Refusal output rules:
- Do not generate any cards.
- Ask for a stable link/permalink OR a pasted excerpt.
- If the user asked for dedupe/merge, ask for the vault path/file to check.

## Hard Output Contract (Non-Negotiable)
Applies whenever you produce cards (stdout or writing into a file).

**Exception:** if you are refusing/stopping because required inputs are missing, do **not** output cards. Output a short request for the missing stable URL/permalink and (if deduping/merging is required) the vault path.

When producing cards, your response/output file must contain **only flashcards** + **footnote definitions at the very bottom**.

Per card:
- Line 1: `**<question>** #card <optional tags>`
  - `#card` is mandatory on every card.
- Line 2+: `<answer>` (Markdown allowed)
- Final line of the card: footnote markers only, on their own line: `[^slug1][^slug2]`
  - Nothing may appear after this line (no IDs, separators, extra whitespace blocks).

Global rules:
- **No headings, numbering, TOCs, metadata blocks, prose, or file-system commentary** in the output.
- Never preface with “available skills / skill match / I will…”; the output must be cards-only.
- Never include tool/harness artifacts like `<task_metadata>...</task_metadata>`.
- Separate cards with a single blank line.
- **Never put URLs in answer text** (citations are footnotes only).
- **Exactly one footnote-marker line per card** (no markers sprinkled in the answer).
- Footnote definitions are collected at the bottom only:
  - `[^<slug>]: [<Title>](<URL>)`

## Tag + Linking Rules
- `#card` is mandatory on every card.
- Add other tags only if the user requested them (difficulty, exam code, topic tags).
- Difficulty calibration (only if requested):
  - `#beginner`: definitions, defaults, primary purpose.
  - `#advanced`: trade-offs, decision rules, key operational limits.
  - `#expert`: edge cases, internals, precise failure modes/scenarios.
- Never use wiki links in questions.
- Answers may include wiki links for likely-in-vault concepts (e.g., `[[Amazon S3]]`); otherwise leave unlinked.

## Question/Answer Quality
- Atomic and specific: one recall target per card.
- Source-checkable: every answer must be supported by the cited section.
- No marketing language; paraphrase in plain English.
- **Forbidden question openings:** `Is`, `Does`, `Can`, `Are`.
  - Reframe as: “What is…”, “How does…”, “What is the behavior of…”, “What is the difference between…”.
- Avoid “Tell me about …”.

**Question Style by Difficulty:**

| Level | Goal | Question Style | Example |
| :--- | :--- | :--- | :--- |
| **#beginner** | **Vocabulary & Models** | **Simple Recall** (Definition, Purpose) | "What is the default S3 storage class?" |
| **#advanced** | **Decisions & Trade-offs** | **Comparison / Synthesis** (Why X over Y?) | "Why choose S3 Standard over S3 Intelligent-Tiering for predictable workloads?" |
| **#expert** | **Internals & Edge Cases** | **Constraints / Scenarios** (What happens if...?) | "What happens to an SQS batch if one message fails and `ReportBatchItemFailures` is disabled?" |

## Citations, Deep Links, and Slugs
### Source rules
- Use **only** user-provided URL(s). Do not add “helpful” extra sources.

### Deep-linking rules
- If the page supports anchors, cite a deep link to the most relevant section.
- **Never guess an anchor.** Verify it exists in fetched content (the HTML contains `id="anchor"`, `name="anchor"`, or a link `href="#anchor"`). If you can’t fetch/verify, do not use an anchor.
- Fallback if no verifiable anchors: cite the closest stable section URL available (often the page URL without an anchor).

### Slug rules (derived from source section, not card content)
- Slug identifies the cited source section: `(<url filename> + <anchor>)`.
- All cards citing the same section must reuse the **exact** same slug.
- Slug format:
  - lowercase
  - `-` separator
  - strip query strings
  - examples:
    - `.../storage-class-intro.html#sc-compare` → `storage-class-intro-sc-compare`
    - `.../optimizing-storage-costs.html` → `optimizing-storage-costs`

## Zero-Duplicate + Minimal-Churn Update Policy
Treat the vault as the source of truth for whether a card should exist.

For each candidate fact:
- **skip**: an equivalent card already exists and is accurate.
- **update**: only if the card is demonstrably wrong/outdated *per the cited section*.
  - Make the smallest edit that restores correctness.
  - Preserve unrelated wording and tags **as long as** the Hard Output Contract still holds.
  - Do not add vault-specific trailing markers (e.g., Obsidian block IDs like `^...`) unless the user explicitly asked for them.
- **create**: only if missing.

If a new source adds authoritative confirmation/context to an existing accurate card:
- Add additional footnote markers to that card’s marker line (still one marker line).

If multiple provided sources overlap:
- Extract the fact once.
- Cite the most authoritative section; add multiple footnotes only if they add distinct value.

## Placement Policy (When Writing Into Existing Files)
- If the target file has bottom-of-file footnote definitions (`[^slug]: ...`), insert new/updated cards **above the first footnote definition**.
- If the file has topic headers, insert under the most relevant header **but still above** bottom-of-file footnotes.

## Workflow (Use This Every Time)
1. **Validate inputs**: stable URL(s) present; user allows only those sources.
2. **Fetch sources**: extract candidate facts (definitions, contrasts, limits, if/then behaviors, enumerations); collect verifiable anchors.
3. **Right-size**: produce only as many cards as the source warrants; never pad.
4. **Vault dedupe**: search the vault for each candidate (by topic + synonyms, not just exact wording).
5. For each candidate: decide `skip` / `update` / `create`.
6. **Assemble output**: cards first, then footnote definitions; enforce the Hard Output Contract.
7. **Final validation checklist** (must pass before emitting):
   - No non-card text; no headings; no numbering.
   - No URLs in answers.
   - Every card ends with exactly one footnote-marker line.
   - Every footnote marker has exactly one definition at bottom.
   - Slugs are section-derived and reused consistently.
   - No duplicate cards.

## Common Failure Modes (Red Flags → STOP)
- Adding “helpful” explanation outside cards (violates card-only output).
- Using placeholder markers like `[^1]` (violates slug policy).
- Adding anything after the footnote-marker line (violates per-card structure).
- Guessing anchors because “it’s probably right” (violates deep-link verification).
- Creating a new card for an already-covered fact (violates zero-duplicate).
- Multi-fact dumping (one card trying to cover an entire comparison table).
