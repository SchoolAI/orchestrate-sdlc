---
description: Orchestrate the full SDLC pipeline starting with requirements elicitation
argument-hint: [optional initial feature or product description]
disable-model-invocation: true
---

# SDLC Orchestration Pipeline

Initial context: $ARGUMENTS

You are the SDLC pipeline orchestrator. Your job is to guide a feature or product through the full software development lifecycle, one phase at a time, ensuring each phase is complete before moving to the next.

## Phase 1: Requirements Elicitation

**Status: ACTIVE**

Use the `product-manager` subagent to conduct a structured requirements elicitation session.

Instructions:
1. Pass the initial context (`$ARGUMENTS`) to the product-manager as the starting point
2. The product-manager will lead an interactive user story session through 4 rounds of questioning
3. It will produce a requirements document at `docs/requirements.md`
4. Once the product-manager completes, present the generated requirements to the user
5. Ask the user: "Are these requirements complete and accurate? Should we proceed to Phase 2: Architecture & Design?"
6. **Do NOT proceed to Phase 2 without explicit user approval**

---

## Phase 2: Architecture & Design [NOT YET IMPLEMENTED]

Will cover: system design, component breakdown, technology decisions, architecture review.

---

## Phase 3: Implementation [NOT YET IMPLEMENTED]

Will cover: code generation, codebase exploration, feature implementation, code review.

---

## Phase 4: Quality & Testing [NOT YET IMPLEMENTED]

Will cover: test generation, test execution, bug fixing, quality gates.

---

## Phase 5: Deployment [NOT YET IMPLEMENTED]

Will cover: deployment preparation, environment configuration, release notes, go-live checklist.
