---
name: firecrawl-research-index
description: Find the papers that answer a research query in Firecrawl's research paper index — a corpus of paper abstracts whose largest share is biomedical and life-science literature (PubMed, bioRxiv, medRxiv), alongside arXiv preprints in CS, physics, and math — using semantic search, semantic and structural expansion, and in-body verification. Use this skill for literature-finding and paper-retrieval tasks of any kind, including clinical, biomedical, drug, gene, disease, and other life-science questions, whether the answer is a single paper or a full multi-paper set. The index is reached through the `firecrawl research` CLI subcommands (run them via `scripts/fc.sh`) or the equivalent REST endpoints; the `firecrawl_research_*` MCP tool names are the upstream spelling and exist only if a Firecrawl MCP server is configured. Calling `firecrawl_search` with its `categories` option set to `["research"]` is a different feature — it filters ordinary web search to research-affiliated websites (the list includes PubMed, bioRxiv, medRxiv, arXiv, and publisher sites) and returns page results from them, without querying the paper records in this index.
---

# Firecrawl Research Index

Find the research papers that answer a research query. Some questions have a single answer; many have several — and when in doubt, lean toward returning the fuller relevant set (most relevant first) rather than narrowing to one. A reader is better served seeing the neighboring methods and papers than having them silently dropped.

## How to invoke it on this machine

The `firecrawl` CLI is installed (`npm i -g firecrawl-cli`; binary at `~/.pixi/envs/nodejs/bin/firecrawl`) and authenticates with the `FIRECRAWL_API_KEY` in `~/.hermes/.env`.

**Call it through `scripts/fc.sh`, not bare `firecrawl`.** The CLI does not read `~/.hermes/.env`, and keyless mode is *refused* on this machine because the network egresses through a VPN/proxy ("your IP address looks like a VPN or proxy"). Without the key loaded, every call fails. `fc.sh` sources the key only when `FIRECRAWL_API_KEY` is unset, so it is safe inside a shell that already exported it.

```bash
FC="$HOME/.hermes/skills/firecrawl-research-index/scripts/fc.sh"
"$FC" --status                                                      # auth + credits
"$FC" research search-papers "query" --limit 20
"$FC" research inspect-paper arxiv:1706.03762
"$FC" research read-paper pmid:40953549 --question "sample size?" --limit 4
"$FC" research related-papers arxiv:1706.03762 --intent "efficient transformers" --mode citers --limit 20
```

Verbose markdown is the default output; add `--json` for compact JSON or `-o <path>` to write a file. There is **no `firecrawl_*` MCP server configured in this profile**, so the MCP names below are documentation of the upstream tool surface — use the CLI (or add the server: `hermes mcp add firecrawl --url https://mcp.firecrawl.dev/v2/mcp` with a bearer header, or the OAuth endpoint `https://mcp.firecrawl.dev/v2/mcp-oauth`).

REST equivalents, if the CLI is ever unavailable (all take `Authorization: Bearer $FIRECRAWL_API_KEY`):

| Task | Endpoint |
|---|---|
| Search papers | `GET /v2/search/research/papers?query=…&k=…&authors=…&categories=…&from=YYYY-MM-DD&to=YYYY-MM-DD` |
| Inspect metadata / read passages | `GET /v2/search/research/papers/{id}` — add `?query=…&k=…` to get full-text passages |
| Find related papers | `GET /v2/search/research/papers/{id}/similar?intent=…&mode=similar\|citers\|references&k=…` |

## What is in the index

Paper abstracts, with full text reachable per paper — roughly 43 million records. The largest share of the corpus is **biomedical and life-science** literature — **PubMed** journal articles plus **bioRxiv** and **medRxiv** preprints — so clinical, drug, gene, disease, epidemiology, and public-health questions are in scope. **arXiv** preprints cover computer science, physics, and mathematics. Coverage outside those sources is thinner: a paper that exists only behind a publisher paywall or in a niche venue may not be indexed, and the general web tools below are the fallback when it isn't.

Papers are addressable by source id: `pmid:`, `pmcid:`, `doi:` and `arxiv:` all work, as does the canonical `paperId`. Feed whatever `primaryId` a result carries straight back into the inspect/read/related calls.

There is **no fixed recipe**. Read the query, decide what kind it is, and choose the approach below. Some queries need a single search; others need heavy structural/semantic expansion. Don't run machinery a query doesn't call for.

## The tools, and what each is uniquely good at

- CLI: **`fc.sh research search-papers <query> [--limit <n>] [--authors a,b] [--categories cs.LG] [--from YYYY-MM-DD] [--to YYYY-MM-DD] [--json]`**
  MCP: **`firecrawl_research_search_papers(query, k?)`**
  Semantic (HyDE) search over **abstracts**. The natural first move for almost any query.
  Default is 40 results. If results look thin or all-alike, re-run with a different framing (sibling domain, rival method, dataset/benchmark name) rather than giving up.
  Never pass `-k` to size the result set — in this CLI `-k` is `--api-key`.
  `--categories` takes arXiv taxonomy labels (`cs.LG,cs.IR`); PubMed/bioRxiv/medRxiv records carry none, so omit it for biomedical queries.

- CLI: **`fc.sh research related-papers <seedIds...> --intent <intent> [--mode <similar|citers|references>] [--limit <n>] [--rerank]`**
  MCP: **`firecrawl_research_related_papers(seed_ids, intent, mode?, k?)`**
  Semantic and structural expansion, ranked to your `intent`.
  This reaches papers semantic search *cannot*, and it's how you turn one good hit into the rest of a set.
  `mode=similar` → co-citation / bibliographic-coupling neighborhood; `citers` → who uses/builds on the seeds; `references` → what they build on / compare against.
  A `similar` call already runs a deep multi-round expansion internally.

- CLI: **`fc.sh research inspect-paper <id>`**
  MCP: **`firecrawl_research_inspect_paper(id)`**
  Canonical metadata for **one** paper: title, abstract, authors, categories, source ids, and dates.
  Use it after `search_papers` or `related_papers` when you need the complete citation/metadata for a candidate, or when you have an id from elsewhere and need to confirm what paper it resolves to.
  This does **not** read the paper body; use `read_paper` for specific full-text questions.

- CLI: **`fc.sh research read-paper <id> --question <question> [--limit <n>]`**
  MCP: **`firecrawl_research_read_paper(id, question)`**
  In-body passages of **one** paper, to verify a load-bearing constraint (a method actually used, a score actually reported, an affiliation, what a paper compares to).
  Use it to settle a specific doubt, not on everything. If the full text is unavailable the response says so — fall back to the abstract rather than assuming absence.

- CLI: **`fc.sh search <query> --categories research`**
  MCP: **`firecrawl_search(query, categories: ["research"])`**
  **Not this index.** This is a *website* filter: it restricts a normal web search to a short list of research-affiliated domains — the list does include `pubmed.ncbi.nlm.nih.gov`, `biorxiv.org`, `medrxiv.org`, and `arxiv.org` alongside publisher sites — and returns page results in a `research` group beside `web`, each with `url`, `title`, `description` (the matched passage), `position`, and `category: "research"` — web results carry no `category`, so that is the field to key on when merging.
  So it reaches those sites' **web pages**; what it does not do is query their **paper records** in this index — no semantic search over abstracts, no citation-graph or related-paper expansion, no canonical paper metadata, and no in-body passages. The results are ordinary web results.
  Use it when you are **already** running a web search and want those sites weighed in the same call. For anything that is actually a paper-finding task, use `research search-papers` and its siblings above.

- CLI: **`fc.sh search <query>` / `fc.sh scrape <url>`**
  MCP: **`firecrawl_search(query)` / `firecrawl_scrape(url)`**
  General **web** search and page fetch, for facts that don't live in paper abstracts: benchmark **leaderboards**, rankings, "who scores best / is largest / is most used."
  Find the ranking on the web, then map the top entries back to papers with `search_papers`.
  Reach for these only when the corpus can't answer the question on its own.

- CLI: **`fc.sh research search-github "<query>"`**
  Sibling command in the same group: searches GitHub issue/PR history and repository READMEs, for questions about a library's behavior rather than the literature.

## Match the approach to the query

- **Single *named* paper** ("the Qwen3 report") → one `search_papers`, done. This is the only case that truly wants exactly one paper.
- **Paper by description / by method or technique** ("the paper that introduced X", "training-free N-gram detection of AI text") → find the best match, then assume there's a *family*: expand with `related_papers` and **include the closely-related methods/papers too**. Even when one paper is the exact literal match, surface and keep its neighbors — don't narrow to the single best hit and reason the rest out. Only treat it as one-answer if the query names a specific paper.
- **Enumeration / method-family** ("papers that do X", "alternatives to Adam", "benchmarks for Y") → the answer is a *set*, and this is where `related_papers` earns its keep: expand several strong anchors with `mode=similar`, re-seed from new strong hits. One search is never enough here.
- **Exhibiting** ("papers that *use* / exhibit property P") → the relevant papers apply P but their abstracts may not describe it. Go from P's defining paper outward via `citers`/`references`, and use `read_paper` to confirm a candidate actually uses P.
- **Superlative / leaderboard** ("best on benchmark X", "largest", "most popular") → the ranking lives on **leaderboards / the web**, not in any single abstract. Use `firecrawl_search` / `firecrawl_scrape` to find the benchmark's leaderboard or rankings, read off the top models/papers, then `search_papers` each to get its paper. As a fallback, search the benchmark and `read_paper` candidates for reported numbers. The hardest kind — cast wide.
- **Org / author filtered** ("from \<org\>", "by \<author\>") → topical match isn't enough; verify the affiliation/authorship (metadata or `read_paper`) before keeping a paper. `--authors` filters on substrings of the author list, so it narrows candidates but does not prove affiliation.
- **Compare-against** ("what does paper X benchmark against / build on") → the answer is *inside* paper X: `read_paper(X, ...)` or `related_papers([X], ..., mode="references")`.

## Principles

- **Two different features share the word "research."** The paper index is `firecrawl research`. The `categories: ["research"]` option on plain search is a website filter — it does point web search at PubMed, bioRxiv, medRxiv, arXiv, and publisher sites, but what comes back is their web pages, not paper records. If a task is about finding papers, the research commands are the ones that read the corpus; reaching for `categories: ["research"]` will quietly answer a different question. **Announced change, effective 2026-11-16:** from that date `/search` with `categories: ["research"]` queries *this* index and returns paper records in `data.research`. Check the current date before relying on either behavior, and prefer the dedicated `research` commands regardless.
- **Query shape and subject field are separate.** A clinical-trial question and a machine-learning question take the same shapes above; what differs is only which source the hits come from. Don't send a biomedical or life-science query to the open web on the assumption the corpus is arXiv-only — PubMed, bioRxiv, and medRxiv are the largest part of what `search_papers` reads.
- **When in doubt, include.** For any topic / method / comparison question, return the relevant *family*, not just the single best match — err toward keeping a plausibly-relevant paper rather than dropping it. The neighboring methods are part of a good answer; don't reason close work out just because one paper is the most exact match.
- **Follow the literature, and keep what you find.** The seminal source, the competing methods, the close neighbors are usually a hop away — use `related_papers`, and *include* them, not just the first hit. Stopping at one good result is the most common way to leave the reader with half an answer.
- **Verify to exclude, not to gatekeep.** Use `read_paper` to rule a paper *out* when a hard constraint clearly fails (wrong org/author, doesn't actually report the score). When a paper is plausibly relevant, lean toward keeping it rather than demanding proof.
- **Only drop the clearly off-topic.** Don't pad with papers you're confident are unrelated — but that's a high bar; most plausibly-relevant work should make the cut.

## Files

- `scripts/fc.sh` — Firecrawl CLI wrapper. Loads `FIRECRAWL_API_KEY` from `$HERMES_HOME/.env` (default `~/.hermes/.env`) when unset, then execs `firecrawl`. Use it for every call.
- `scripts/search_papers.sh` — direct REST wrapper for the paper index, bypassing the CLI (useful if the CLI is missing or an npm upgrade breaks it). Sources the same `.env`, then calls `GET /v2/search/research/papers`. Usage: `search_papers.sh "natural language query" [k] [authors=...]`. Keyless mode is blocked on VPN/proxy networks, so the key is required here too.

## See also

- Upstream skill: `firecrawl/skills` → `skills/core/firecrawl-research-index` (this copy adds the local CLI wrapper and the flag/roster corrections above).
