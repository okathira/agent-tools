---
type: Concept
title: Gotchas
description: Sharp edges observed while dogfooding zvec-llm-wiki in this catalog.
x-zvec-aliases:
  - sharp edges
  - pitfalls
  - dogfooding pitfalls
  - heading-only stubs
  - MCP zg PATH
  - stale skill install
generated: { by: "claude-code/claude-opus-5-5", at: "2026-11-27T18:36:06Z" }
verified:
  - { by: "human:owner", at: "2026-11-20T15:31:00Z" }
sources:
  - id: zg-bootstrap-sh
    resource: ../../../skills/zvec-llm-wiki/zvec-llm-wiki/scripts/zg-bootstrap.sh
    title: zvec-llm-wiki bootstrap script
  - id: llm-wiki-py
    resource: ../../../skills/zvec-llm-wiki/zvec-llm-wiki/scripts/llm_wiki.py
    title: zvec-llm-wiki index and lint script
  - id: okf-migrate-py
    resource: ../../../skills/zvec-llm-wiki-okf-migrate/zvec-llm-wiki-okf-migrate/scripts/okf_migrate.py
    title: zvec-llm-wiki OKF migration script
  - id: zg-sh
    resource: ../../../skills/zvec-llm-wiki/zvec-llm-wiki/scripts/zg.sh
    title: zvec-llm-wiki pinned zg launcher
  - id: issue-11
    resource: https://github.com/okathira/agent-tools/issues/11
    title: "Issue #11: worktrees start without a zvec-grep index"
---

# Do not commit `.zvec-grep/`

The bootstrap creates a local index under `.zvec-grep/`. It is not source of truth and must remain gitignored.

# Install and bootstrap are separate

- `install.sh` copies a skill package into an agent skill directory (default: `.agents/skills/` in the repo — commit it).
- `zg-bootstrap.sh` configures a target project wiki, hot memory, **project MCP**, and the index.

Running bootstrap from inside the skill package wires the wrong workspace.[^zg-bootstrap-sh]

Bootstrap does not copy `SKILL.md`. After catalog updates to the package, re-run `install.sh --force` and commit `.agents/skills/`, or the agent keeps a stale runtime copy.

# Do commit project skills and MCP

- `.agents/skills/<name>/` — runtime skill the agent loads (default install).
- `.cursor/mcp.json` — Cursor project MCP ([Cursor MCP](https://cursor.com/docs/mcp)).
- `.mcp.json` — Claude Code project MCP (repo root).

User-level `~/.agents/skills/` and `~/.cursor/mcp.json` are not shared with Cloud Agents or teammates.

# User-level `zg --install` vs project MCP

`zg --install --target cursor` writes `~/.cursor/mcp.json` with `command: zg` and does not install the npm package. Prefer committed project MCP with an `npx` launcher for the pinned zvec-grep package from bootstrap. Re-running that upsert keeps compatible fields such as `env` and refuses to merge an existing HTTP `zvec_grep` entry into the stdio command. Use `zg --install --target codex` (etc.) only when you need that agent's **user-level** config. Bootstrap's `--target` does the same install, and when `zg` is not already on PATH it installs `@zvec/zvec-grep` globally and checks that `zg` launches first. A one-shot `npx` install does not leave a `zg` binary for those user-level entries.

# Do not create heading-only stubs

Heading-only pages rank in semantic search but provide no evidence. The scaffold creates category directories plus useful `index.md` and `log.md`, not empty topic pages. `llm_wiki.py index` writes no index for an empty directory for the same reason.[^llm-wiki-py]

# Index files are generated

`llm_wiki.py index` rewrites every `index.md` below the root frontmatter from page `title` and `description`. Hand edits to entries are lost; fix the page frontmatter instead. Section headings and directory descriptions already in an index are kept.[^llm-wiki-py]

Generation keeps the list marker an existing index uses, so Prettier turning `*` into `-` does not make lint fail with ZE010. The root frontmatter is copied as written. A new index starts with `*`, as OKF shows.

Indexes copy each `description`, so keep it to one sentence. Lint warns ZW038 when it is longer. Both lint and the migration count `。`, `！`, and `？` as sentence ends even without a following space. The migration leaves a longer Japanese lead in the body and prints a note.[^okf-migrate-py]

# Markdown without type does not belong in the bundle

`validate.py` warns W120 for a Markdown file that is not a concept, and `--strict` fails on that warning. OKF keeps this for files such as a README. An immutable import is not a README: put it in `docs/raw/`, outside `docs/wiki/`, and cite it with a path relative to the page. Do not special-case the validator.

# Python and PyYAML are prerequisites

`llm_wiki.py`, the migration script, and `okf-generate`'s `validate.py` need Python 3.9+ with PyYAML. macOS system Python ships without PyYAML; run `pip3 install --user pyyaml`. In a sandboxed agent shell, that install needs network access to PyPI.

Windows often has `python` but no working `python3`. Run the documented `python3` commands with `python` there. The installer and bootstrap check both names before warning about PyYAML.

# Scripts write LF and slash-separated paths

`llm_wiki.py index` and `okf_migrate.py` write UTF-8 with LF on every OS, so a Windows run does not add CRLF diffs. The migration writes `sources[].resource` and the links in moved-page stubs with `/` separators.[^okf-migrate-py]

# Older npm warns about `--allow-scripts`

npm 11.16 added the `--allow-scripts` config. Older npm runs install scripts by default and prints `Unknown cli config "--allow-scripts"` for the flag. The bundled `zg.sh` passes the flag only to npm 11.16+.[^zg-sh] The committed MCP entries keep it for teammates on newer npm, so an older npm still prints the warning there. Bootstrap warns once when it finds such an npm.

# Drop an index before deleting its directory on Windows

On Windows, `git worktree remove --force` can fail with `Invalid argument` because the running zg server holds a large index's files open. Run `zg.sh --index <root> --drop` first; the directory then deletes.[^issue-11]

# Incremental updates can drift from a fresh index

An index updated many times can rank results differently from a fresh build of the same files. In one test on this catalog, a Japanese query shared 1 of its top 10 hits with a fresh build, while fresh builds matched each other exactly. The cause is not yet known. Measure retrieval quality on a fresh index, and rebuild when results look off.[^issue-11]

# Japanese retrieval needs aliases

Do not assume BM25 tokenization handles Japanese proper nouns. On a Japanese wiki, keep Kanji, Kana, and English names in frontmatter `x-zvec-aliases` on the owning page and use exact rg when a name is known.

This catalog wiki is English. Prefer English ubiquitous-language aliases; see [Conventions](conventions.md).

# Related

- [Skill setup runbook](../runbooks/skill-setup.md)
- [ADR-0004](../decisions/ADR-0004-project-skill-install.md)
- [Conventions](conventions.md)

[^zg-bootstrap-sh]: zvec-llm-wiki bootstrap script
[^llm-wiki-py]: zvec-llm-wiki index and lint script
[^okf-migrate-py]: zvec-llm-wiki OKF migration script
[^zg-sh]: zvec-llm-wiki pinned zg launcher
[^issue-11]: Issue #11: worktrees start without a zvec-grep index

Use the installed wiki skill's `scripts/zg.sh` from the target repository to keep index commands on the project MCP version. If a different `zg` is on PATH, the launcher uses the pinned npm package. User-level bootstrap requires the matching binary on PATH because user-level MCP launches `zg` directly.
