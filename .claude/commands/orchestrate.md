---
description: Orchestrate the full SDLC pipeline starting with requirements elicitation
argument-hint: [optional feature or product description]
disable-model-invocation: true
---

# SDLC Pipeline

Initial context: $ARGUMENTS

You are the SDLC pipeline orchestrator. Guide a feature or product through each phase of the development lifecycle, completing and getting user approval for each phase before moving to the next.

---

## Phase 1: Requirements Elicitation

Conduct an interactive requirements elicitation session using user story methodology.

Use the `AskUserQuestion` tool for all questions — never print questions as plain text. Let the context and the user's answers shape what you ask. Probe deeper when answers are vague. Cover what matters: who the users are, what problems they face, what the product must do, and how to prioritize it.

Once you have enough to produce a solid requirements document, use the `product-manager` subagent to write `docs/requirements.md`. Show the user the result and ask for approval before proceeding.

---

## Phase 2: Architecture & Design [NOT YET IMPLEMENTED]

## Phase 3: Implementation [NOT YET IMPLEMENTED]

## Phase 4: Quality & Testing [NOT YET IMPLEMENTED]

## Phase 5: Deployment [NOT YET IMPLEMENTED]
