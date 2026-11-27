---
type: Decision Record
title: "ADR-0006: Index lifecycle operations are routine"
description: Agents build, update, rebuild, and drop the project's own zg index without asking, and ask only before changing what or how it indexes.
status: draft
x-zvec-aliases:
  - ADR-0006
  - index lifecycle
  - rebuild without approval
  - index permission
generated: { by: "claude-code/claude-opus-5-5", at: "2026-11-27T18:36:06Z" }
sources:
  - id: issue-11
    resource: https://github.com/okathira/agent-tools/issues/11
    title: "Issue #11: worktrees start without a zvec-grep index"
  - id: zg-sh
    resource: ../../../skills/zvec-llm-wiki/zvec-llm-wiki/scripts/zg.sh
    title: zvec-llm-wiki pinned zg launcher
---

# Context

[ADR-0003](ADR-0003-karpathy-alignment-plan.md) kept `--rebuild`, `--drop`, and `--reset-paths` confirmation-gated. Every new worktree starts without an index, so agents stopped to ask before building or rebuilding one.[^issue-11]

The index lives in the gitignored `.zvec-grep/`. It holds no tracked content and can be rebuilt from the working tree through the pinned launcher.[^zg-sh] FSL writes its verify cache in a user-level directory without asking for the same reason.

# Decision

Building, incrementally updating, rebuilding, and dropping the project's own index are routine. Ask first only before changing what or how zg indexes (`--reset-paths`, scan globs, or the embedding model), before using a remote embedding provider, and before indexing a root outside the project.

# Why (rationale)

- A lifecycle operation costs only compute time. A rebuild of about 1,700 files took about one minute on CPU.[^issue-11]
- The remaining gates change the results everyone gets from the index, send code to a third party at a cost, or can index far more than intended.

# Alternatives considered

- **Keep the ADR-0003 gate** — rejected: every worktree needs a build, so the question is noise.
- **Allow every index operation** — rejected: remote embedding sends code to a provider and costs money.

# Consequences

- Agents rebuild a stale or drifted index without asking. Rebuild time grows with the repository.
- On Windows, drop an index before deleting its directory; see [Gotchas](../concepts/gotchas.md).
- A user-level agent instruction that still requires authorization, such as the block `zg --install` writes, keeps applying for that user. Give a standing permission outside that generated block.
- Seeding a new worktree from an index snapshot is on hold; the requirements stay in issue #11.[^issue-11]

# References

- [ADR-0003](ADR-0003-karpathy-alignment-plan.md)
- [Conventions](../concepts/conventions.md)
- [Gotchas](../concepts/gotchas.md)

[^issue-11]: Issue #11: worktrees start without a zvec-grep index
[^zg-sh]: zvec-llm-wiki pinned zg launcher
