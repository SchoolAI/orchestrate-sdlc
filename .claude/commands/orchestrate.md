---
description: Orchestrate the full SDLC pipeline from a product brief
argument-hint: <product brief>
disable-model-invocation: true
---

# SDLC Pipeline

Product brief: $ARGUMENTS

You are the SDLC pipeline orchestrator. You hold all artifacts, coordinate agents, and drive the pipeline from brief to executable task list. Each phase feeds directly into the next with no manual intervention.

---

## Setup

Derive a short kebab-case feature slug from the product brief (e.g. "url-shortener", "task-management-app"). Create the docs folder for this feature:

```
docs/{feature-slug}/
docs/{feature-slug}/tasks/
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

## Phase 3: Task Planning

Spin up the `task-planner` subagent. Pass:
- The docs folder path (`{docs_folder}`)

The agent will read all three documents, decompose the work into executable tasks, and write:
- `{docs_folder}/tasks/task-NNN.md` — one file per task
- `{docs_folder}/task-index.md` — execution phases and dependency graph

---

## Phase 4: Implementation

Read `{docs_folder}/task-index.md` to get the execution phases and task list.

Execute phases in order. **Do not start a phase until all tasks in the previous phase are complete and merged.**

For each phase:
1. Spin up one `engineer` subagent per task in the phase, **all in parallel**, each with `isolation: "worktree"` so agents work in isolated git branches and cannot conflict with each other
2. Pass each agent the path to its task file: `{docs_folder}/tasks/task-NNN.md`
3. Wait for all agents in the phase to respond
4. Check each response:
   - If any agent reports **blocked**: stop the pipeline, surface the blocker to the user
   - If all agents report **complete**: proceed to merge
5. **Merge phase**: for each worktree branch returned by a completed agent, merge it into the current branch using the Bash tool (`git merge {branch}`). Merge branches one at a time. If a merge conflict occurs: surface it to the user and stop — do not attempt to auto-resolve.
6. After all branches for the phase are cleanly merged, proceed to the next phase

After all phases are complete, report a summary to the user: tasks completed, files changed, any notes from engineer agents.

## Phase 5: Verification [NOT YET IMPLEMENTED]

## Phase 6: Review & Submit [NOT YET IMPLEMENTED]
