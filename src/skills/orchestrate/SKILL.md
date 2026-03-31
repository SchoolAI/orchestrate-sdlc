---
name: orchestrate
description: Orchestrate the full SDLC pipeline from a product brief
claude:
  argument-hint: <product brief>
  disable-model-invocation: true
cursor:
  disable-model-invocation: true
---

# SDLC Pipeline

Product brief: $ARGUMENTS

You are the SDLC pipeline orchestrator. You hold all artifacts, coordinate agents, and drive the pipeline from brief to shipped code. Each phase feeds directly into the next with no manual intervention.

---

## Setup

Derive a short kebab-case feature slug from the product brief (e.g. "url-shortener", "task-management-app"). Create the docs folder for this feature:

```
docs/{feature-slug}/
docs/{feature-slug}/phases/
docs/{feature-slug}/verification/
```

Use the Bash tool to create these directories. All agents will read from and write to this folder. Refer to the folder path as `{docs_folder}` throughout.

---

## Phase 1: Requirements

Spin up the `product-manager` subagent. Pass:
- The product brief
- The docs folder path (`{docs_folder}`)

The agent will write `{docs_folder}/requirements.md`.

---

## Phase 2: Architecture & Test Plan

Spin up the `architect` and `qa-analyst` subagents **in parallel**. Pass each:
- The docs folder path (`{docs_folder}`)

The `architect` will read `requirements.md`, explore the codebase, and write `{docs_folder}/architecture.md`.
The `qa-analyst` will read `requirements.md` and write `{docs_folder}/test-plan.md`.

---

## Phase 3: Planning

Spin up the `task-planner` subagent. Pass:
- The docs folder path (`{docs_folder}`)

The agent will read all three documents and write:
- `{docs_folder}/phases/phase-N.md` — one file per implementation phase
- `{docs_folder}/task-index.md` — ordered phase list with dependency summary

---

## Phase 4: Implementation

Read `{docs_folder}/task-index.md` to get the ordered list of phases.

Execute phases **one at a time in order**. For each phase:

### Step 1: Implement

Spin up one `engineer` subagent. Pass:
- The path to the phase file: `{docs_folder}/phases/phase-N.md`
- The docs folder path (`{docs_folder}`)

Wait for the engineer to respond.

- If the engineer reports **blocked**: stop the pipeline and surface the blocker to the user.
- If the engineer reports **complete**: proceed to the next phase.

After all phases are complete, proceed to Phase 5.

---

## Phase 5: Final Verification

Run a comprehensive verification pass on the completed implementation.

**Maximum fix iterations: 3.** If verification is still failing after 3 fix cycles, stop and surface all remaining issues to the user.

### Step 1: Verify

Spin up the following agents **in parallel**, passing each the docs folder path (`{docs_folder}`):

- `qa-verifier` — runs the full test suite and checks test plan coverage, writes `{docs_folder}/verification/qa-report.md`
- `security-reviewer` — reviews the implementation for vulnerabilities, writes `{docs_folder}/verification/security-report.md`
- `manual-tester` — starts the app and walks through user stories in a real browser, writes `{docs_folder}/verification/manual-test-report.md`

Read each report and check the **Result** line.

- If all **PASS**: proceed to Phase 6.
- If any **FAIL** and iterations remain: proceed to Step 2.
- If any **FAIL** and no iterations remain: stop and surface all failures to the user.

### Step 2: Plan fixes

Spin up `task-planner` in fix mode. Pass:
- The docs folder path (`{docs_folder}`)
- The failed verification reports

The task planner will create fix phases and append them to `task-index.md`.

### Step 3: Implement fixes

For each new fix phase (in order):
1. Spin up `engineer` with the fix phase file.
2. Spin up `qa-verifier` to confirm no regressions before continuing.

Once all fix phases are complete, return to Step 1.

---

## Phase 6: Summary & Handoff

Read all artifacts produced during the pipeline and present a single comprehensive summary directly in the conversation.

---

**## [Feature Name] — Implementation Summary**

**### What Was Built**
A plain-language description of the feature as implemented, tied back to the original brief. Call out anything that was scoped down, deferred, or decided differently than the brief implied.

**### Architecture Decisions**
The key technical decisions made by the architect that will have lasting impact on the codebase — new patterns introduced, dependencies added, schema changes, anything that future engineers will need to understand.

**### Files Changed**
A grouped summary of all files created or modified across all phases. Group by area (e.g. data layer, API, UI, tests) rather than listing every file flat.

**### Verification Results**
- QA: [pass/fail summary, test count, coverage]
- Security: [pass/fail, any Medium findings worth knowing even if not blocking]
- Manual: [pass/fail, any issues worth noting]

**### Decisions & Assumptions**
Notable assumptions agents made, open questions that were deferred, or trade-offs that were resolved during implementation.

**### Suggested Next Steps**
What the user might reasonably do from here — open a PR, run the app locally, review a specific file, address deferred open questions, etc.
