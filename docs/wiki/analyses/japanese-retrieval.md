---
type: Analysis
title: Japanese retrieval with zvec-grep
description: zvec-grep 0.3.1 fixes full-text tokenization to the Chinese jieba segmenter, so Japanese keyword search misses terms and matches single kana.
x-zvec-aliases:
  - Japanese retrieval
  - jieba tokenizer
  - FTS tokenizer
  - 日本語検索
  - トークナイザー
  - 分かち書き
generated: { by: "claude-code/claude-opus-5-5", at: "2026-11-27T19:33:53Z" }
sources:
  - id: fts-config
    resource: https://github.com/zvec-ai/zvec-grep/blob/40b6005bd9adc784cf24c41afd2e753c883e44d4/rust/crates/zg-engine/src/domain/index.rs#L288-L291
    title: zvec-grep v0.3.1 fixed FTS configuration
  - id: fts-schema
    resource: https://github.com/zvec-ai/zvec-grep/blob/40b6005bd9adc784cf24c41afd2e753c883e44d4/rust/crates/zg-engine/src/storage/fragments/mod.rs#L357
    title: zvec-grep v0.3.1 FTS index parameters
  - id: zvec-tokenizers
    resource: https://github.com/alibaba/zvec/blob/2b1e274d65303e3c870c8180a557948fa9a51cf3/src/db/index/column/fts_column/tokenizer/tokenizer_factory.cc
    title: zvec tokenizer factory
  - id: issue-387
    resource: https://github.com/zvec-ai/zvec-grep/issues/387
    title: "zvec-grep issue #387: configurable FTS analysis"
  - id: pr-438
    resource: https://github.com/zvec-ai/zvec-grep/pull/438
    title: "zvec-grep PR #438: FTS analysis configuration"
  - id: issue-11
    resource: https://github.com/okathira/agent-tools/issues/11
    title: "Issue #11: worktrees start without a zvec-grep index"
---

# What

zvec-grep 0.3.1 builds its full-text (FTS) index with a constant `jieba` tokenizer and `lowercase` filter. No CLI option, environment variable, configuration file, or build feature changes them, and `main` was the same on 2026-11-27.[^fts-config][^fts-schema] The filter only folds case after splitting; the tokenizer alone decides how text splits.

zvec, the engine under zvec-grep, ships `jieba`, `standard`, `ngram` (bigrams by default), and `whitespace` tokenizers. It has no Japanese morphological analyzer such as Lindera or Sudachi.[^zvec-tokenizers]

# Measured behavior

An 8-document test index on 2026-11-28 showed these FTS results:

- `設定`, `東京`, and `構築` returned no hit, although documents contain them.
- Kana appear to split into single characters matched with OR. A query with kana hits any document that shares one kana.
- `京都` matched a document containing only `東京都`.
- Spaces become tokens, so a multi-word query in any language matches every document with a space. A single ASCII word such as `fox` matched correctly.
- Compounds in the Chinese dictionary, such as `形態素解析` and `関西国際空港`, matched correctly.

Vector search and the default hybrid search ranked the right document first for the same queries, but the test set was small.

The embedding model list is fixed in the CLI (`zg.sh --help models`), so a Japanese model such as ruri cannot be added. The default `local/potion-multilingual-128m` is a small static multilingual model.

Separately, an index updated incrementally many times ranked a Japanese query very differently from a fresh build; see [Gotchas](../concepts/gotchas.md).[^issue-11]

# Upstream status

Issue #387 asks for a configurable FTS analysis chain.[^issue-387] PR #438 adds `--fts-tokenizer` and related options and makes `standard` the default for new indexes. It was open and unreleased on 2026-11-28.[^pr-438] The `ngram` tokenizer would likely stop the missed Japanese terms; this is untested.

# Workarounds

- Find exact Japanese words and phrases with `zg.sh --rg -F`.
- Find concepts with hybrid or `--vector` search.
- Keep `--fts` to single ASCII identifiers.
- List Kanji, Kana, and English names in `x-zvec-aliases` on the owning page.

# Related

- [ADR-0007](../decisions/ADR-0007-deprecate-japanese.md)
- [Gotchas](../concepts/gotchas.md)

[^fts-config]: zvec-grep v0.3.1 fixed FTS configuration
[^fts-schema]: zvec-grep v0.3.1 FTS index parameters
[^zvec-tokenizers]: zvec tokenizer factory
[^issue-387]: zvec-grep issue #387: configurable FTS analysis
[^pr-438]: zvec-grep PR #438: FTS analysis configuration
[^issue-11]: Issue #11: worktrees start without a zvec-grep index
