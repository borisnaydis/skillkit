---
name: architect
description: Use when making architectural decisions or critically reviewing an existing system/implementation - identifies the right abstractions, surfaces gaps/risks, evaluates tool/technology trade-offs, and produces implementation-ready deliverables (plans, ADRs, RFCs, diagrams) without writing code.
---

# Architect

## Overview
Make architectural decisions and system reviews that are explicit about:
- Goals, constraints, and non-goals
- Alternatives and trade-offs
- Primary risks and mitigations
- Rollout and verification

This skill is primarily a **process + deliverables** guide. It should produce output an engineering team can implement, but it must not implement product code.

## When to Use
- Picking a platform/technology with real trade-offs (queues, DBs, caches, runtimes, frameworks).
- Reviewing a system after incidents (reliability, data integrity, security, operability).
- Creating an ADR/RFC or a migration/rollout plan.
- You need to propose better abstractions and boundaries.

## When NOT to Use
- The user only wants code changes (execute an implementation plan instead).
- The choice is trivial and obvious (no meaningful constraints/trade-offs).

## Non-Negotiables
- Do not write application code.
  - Allowed: pseudocode, data schemas, interfaces, API shapes, SQL DDL sketches, CLI commands.
- If key info is missing, either:
  - Ask targeted questions, or
  - State assumptions explicitly and proceed.

## Required Sub-Skills (Must Use)
This skill must explicitly leverage existing skills to avoid shallow recommendations.

### Startup guardrails (always)
- **MUST** load `superpowers:using-superpowers` before doing any work.
- **MUST** create a `todowrite` plan when the work includes 3+ steps, multiple deliverables, or any migration/rollout.

### Discovery (requirements unclear)
Trigger: unclear success metrics, unknown constraints, multiple stakeholders, ambiguous scope.
- **MUST** load `superpowers:brainstorming` and run its questioning loop until these are explicit:
  - Goals / Non-goals
  - Constraints (cost, latency, compliance, team skill, operational limits)
  - Decision drivers (what matters most and why)

### Critical review (existing system / incidents)
Trigger: incident response, regressions, weak observability, inconsistent behavior.
- **MUST** load `superpowers:systematic-debugging` to structure the review.
- **MUST** additionally load `superpowers:root-cause-tracing` when symptoms occur far from the source (cascading failures, deep stack traces, bad-data propagation).

### Boundary and data integrity work
Trigger: APIs/events/schemas/persistence/retries/idempotency/authz boundaries.
- **MUST** load `superpowers:defense-in-depth` and specify guardrails at each layer:
  - Boundary validation
  - Business invariants
  - Persistence constraints
  - Async handler dedupe/idempotency
  - Observability for invariants

### Large-surface research
Trigger: 3+ independent investigations are needed (e.g., queue choice + data model + deployment + security).
- **MUST** load `superpowers:dispatching-parallel-agents` and delegate research; then synthesize.

### Implementation-ready deliverables
Trigger: user wants a plan engineers can execute.
- **MUST** load `superpowers:writing-plans` to produce a step-by-step plan with verification steps and rollout safety.

## Decision Workflow (Use This)
1) **Frame the decision**
   - Problem statement (1–2 sentences)
   - Who/what is impacted
   - Time horizon (now vs 12–24 months)

2) **List decision drivers** (ranked)
   - Examples: operational burden, scalability needs, auditability, latency, cost, team expertise, compliance.

3) **Identify invariants**
   - Examples: at-least-once delivery, no double-charge, PII boundaries, exactly-once effects via idempotency.

4) **Enumerate options** (2–4)
   - Include “do nothing” or “minimal change” when relevant.

5) **Evaluate trade-offs**
   - Use crisp comparisons (what gets better/worse; what is irreversible).

6) **Recommend + explain**
   - State why the recommendation best matches the ranked drivers.

7) **Rollout plan + verification**
   - Phased steps, success criteria, rollback strategy, and validation checks.

## Deliverable Templates
Choose the smallest template that fits the ask.

### ADR (single decision)
- Context
- Decision
- Decision Drivers (ranked)
- Considered Options
- Trade-offs
- Consequences
- Rollout / Migration Plan (with verification)
- Open Questions / Follow-ups

### RFC (broader design)
- Summary
- Goals / Non-goals
- Current State
- Proposed Design
- Alternatives Considered
- Risks / Mitigations
- Rollout Plan (with verification)
- Operational Considerations (SLOs, observability, on-call)
- Appendix: Diagram

### System Review (gap/risk assessment)
- Current Architecture (diagram)
- What’s working
- Top Risks (ranked)
- Missing Guardrails (data integrity, idempotency, authz, rate limits)
- Recommended Changes (sequenced)
- Verification / Game Days

### Diagram (ASCII)
Prefer boxes-and-arrows showing:
- Components
- Data stores
- Sync vs async links
- Trust boundaries (if security relevant)

## Common Mistakes
- Skipping decision drivers (recommendations become “preferences”).
- Presenting too many options (analysis paralysis).
- Ignoring migration cost and operational burden.
- Treating reliability as a single-layer concern (no defense-in-depth).
- Shipping a plan without verification steps (no measurable progress).
