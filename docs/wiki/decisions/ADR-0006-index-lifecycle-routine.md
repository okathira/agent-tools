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
  - id: zg-help
    resource: https://www.npmjs.com/package/@zvec/zvec-grep/v/0.3.1
    title: "zvec-grep 0.3.1 (`zg --index --help`: model selection and saved scan rules)"
  - id: zg-sh
    resource: ../../../skills/zvec-llm-wiki/zvec-llm-wiki/scripts/zg.sh
    title: zvec-llm-wiki pinned zg launcher
---

# Context

[ADR-0003](ADR-0003-karpathy-alignment-plan.md) kept `--rebuild`, `--drop`, and `--reset-paths` confirmation-gated. Every new worktree starts without an index, so agents stopped to ask before building or rebuilding one.[^issue-11]

The index lives in the gitignored `.zvec-grep/`. It holds no tracked content, and its index data can be rebuilt from the working tree through the pinned launcher.[^zg-sh] It is a derived build cache, like any other gitignored build output.

# Decision

Building, incrementally updating, rebuilding, and dropping the project's own index are routine. Ask first only before:

- changing what or how zg indexes: scan rules (`--reset-paths`, globs, `--hidden`, `--no-ignore`, and similar), `--graph`, or the embedding model;
- using remote embedding (`--allow-remote`, `--api-key`, `--endpoint`, `zg --config`, `zg --auth`);
- indexing a root outside the project;
- dropping an index whose `.zvec-grep/` holds `credentials.key` or `authorization.json`, which the working tree cannot rebuild.[^issue-11]

When creating an index (a new worktree, after `--drop`, or when zg reports `rebuild required`), pass the project's model, by default `--embedding local/potion-multilingual-128m`, and its scan rules. Without them, zg picks a model from its own defaults and drops saved scan rules, which is a gated change.[^zg-help]

# Why (rationale)

- A lifecycle operation costs compute time and disk. A rebuild of about 1,700 files took about one minute on CPU, and the index was about 17 times the size of the source.[^issue-11]
- The remaining gates change the results everyone gets from the index, send code to a third party at a cost, or can index far more than intended.

# Alternatives considered

- **Keep the ADR-0003 gate** — rejected: every worktree needs a build, so the question is noise.
- **Allow every index operation** — rejected: remote embedding sends code to a provider and costs money.

# Consequences

- Agents rebuild a stale or drifted index without asking. Rebuild time grows with the repository.
- On Windows, drop an index before deleting its directory; see [Gotchas](../concepts/gotchas.md).
- zg's own agent instructions still say to ask before creating, rebuilding, or dropping an index: the block `zg --install` writes to user-level agent files, and the zvec_grep MCP server's instructions. This decision is the project owner's standing authorization for those operations on the project's own index. A user-level instruction keeps applying for that user until they give a standing permission outside the generated block.
- Seeding a new worktree from an index snapshot is on hold; the requirements stay in issue #11.[^issue-11]

# References

- [ADR-0003](ADR-0003-karpathy-alignment-plan.md)
- [Conventions](../concepts/conventions.md)
- [Gotchas](../concepts/gotchas.md)

[^issue-11]: Issue #11: worktrees start without a zvec-grep index
[^zg-help]: zvec-grep 0.3.1 (`zg --index --help`: model selection and saved scan rules)
[^zg-sh]: zvec-llm-wiki pinned zg launcher
