---
type: Decision Record
title: "ADR-0007: Deprecate Japanese use until zvec-grep supports it"
description: Japanese-language wikis and the -ja skill packages are deprecated until upstream zvec-grep supports Japanese full-text search, and a separate llm-wiki on a Japanese-optimized engine is planned.
status: draft
x-zvec-aliases:
  - ADR-0007
  - Japanese deprecation
  - deprecate -ja
  - 日本語非推奨
generated: { by: "claude-code/claude-opus-5-5", at: "2026-11-27T19:33:53Z" }
sources:
  - id: issue-387
    resource: https://github.com/zvec-ai/zvec-grep/issues/387
    title: "zvec-grep issue #387: configurable FTS analysis"
  - id: pr-438
    resource: https://github.com/zvec-ai/zvec-grep/pull/438
    title: "zvec-grep PR #438: FTS analysis configuration"
---

# Context

zvec-grep 0.3.1 tokenizes full text with the Chinese jieba segmenter and offers no way to change it. Japanese keyword search misses basic terms and matches single kana; see [Japanese retrieval with zvec-grep](../analyses/japanese-retrieval.md). Upstream work to make the tokenizer configurable is open but unreleased.[^issue-387][^pr-438]

# Decision

1. Writing a wiki in Japanese with zvec-llm-wiki is deprecated until upstream zvec-grep releases Japanese-capable full-text tokenization.
2. `zvec-llm-wiki-ja` and `zvec-llm-wiki-okf-migrate-ja` are deprecated on the same terms. They stay published and receive the fixes made to the English packages, but no new Japanese-specific features.
3. A separate llm-wiki skill on an engine optimized for Japanese and English is planned, with a skill that migrates wikis from zvec-llm-wiki. This amends the "Japanese (engine locked)" section of [ADR-0003](ADR-0003-karpathy-alignment-plan.md), which said not to switch engines to fix CJK. zvec-llm-wiki itself keeps zg.
4. When zvec-grep releases configurable tokenization, measure Japanese retrieval on a fresh index, then lift or keep this deprecation.

# Why (rationale)

- The defect is inside zg and cannot be configured, so this catalog cannot fix it.
- Workarounds such as rg and aliases help only when the user knows to use them. Marking the packages deprecated stops new users from getting poor retrieval without warning.

# Alternatives considered

- **Keep Japanese support with documented workarounds** — rejected: keyword search misses basic terms, and new users would not see the workarounds first.
- **Remove the -ja packages** — rejected: existing installs still depend on them, and they also serve readers who prefer Japanese instructions.
- **Build zg from PR #438** — rejected: it needs a Rust build, a new launcher pin, and unreleased behavior.
- **Tell Japanese projects to write the wiki in English** — rejected as a default: sources, domain terms, readers, and questions stay Japanese.

# Consequences

- The catalog, plugin descriptions, skill descriptions, and READMEs mark the -ja packages deprecated. The Japanese bootstrap prints a warning.
- Fixes still go to every locale in the same change, as [ADR-0001](ADR-0001-locale-independence.md) requires.
- Watch zvec-grep issue #387 and PR #438.

# References

- [Japanese retrieval with zvec-grep](../analyses/japanese-retrieval.md)
- [ADR-0001](ADR-0001-locale-independence.md)
- [ADR-0003](ADR-0003-karpathy-alignment-plan.md)
- [Gotchas](../concepts/gotchas.md)

[^issue-387]: zvec-grep issue #387: configurable FTS analysis
[^pr-438]: zvec-grep PR #438: FTS analysis configuration
