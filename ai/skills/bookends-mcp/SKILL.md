---
name: bookends-mcp
description: Use Bookends reference-manager MCP server (SSE, 20 tools) to search, import, format, and annotate references from the user's Bookends library.
version: 1.0.0
author: iandol
license: MIT
metadata:
  hermes:
    tags: [MCP, references, bibliography, Bookends, research]
prerequisites:
  commands: [npx, curl]
---

# Bookends MCP Server

Use the [Bookends](https://www.sonnysoftware.com/bookends-for-mac) MCP server (built into Bookends v15.4.2+) to interact with the user's reference library. The server runs on their Mac and is reachable via Tailscale at `http://100.112.1.1:8787/mcp`.

## Quick Start

```bash
# List tools (discovery)
npx mcporter list --http-url http://100.112.1.1:8787/mcp --name bookends-mcp --allow-http

# Search latest references with DOI
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_search --allow-http \
  fields:='["title","authors","doi","year","journal"]' limit:=5 trash:="exclude" --output json

# SQL query (sort by date added, no DOI column in SQL)
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_readonly_sql --allow-http \
  sql="SELECT uniqueid, title, authors, thedate, journal FROM thereferences ORDER BY dateadded DESC LIMIT 5" \
  max_rows=5 --output json

# Get properties for known IDs (includes DOI)
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_get_properties --allow-http \
  ids:='["id1","id2"]' fields:='["title","authors","doi"]' --output json

# Format a reference as citation
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_get_formatted_reference --allow-http \
  id="229532" outputType="BibTeX" --output json
```

## Available Tools (20 total)

| Tool | Purpose |
|------|---------|
| `bookends_search` | Search references by query, group, SQL WHERE, or trash state. Returns DOI, PMID, etc. |
| `bookends_readonly_sql` | Run Valentina SELECT queries. No `doi` column — use `bookends_search` or `bookends_get_properties` for that. |
| `bookends_get_properties` | Fetch specific fields (title, authors, doi, pmid, keywords, etc.) for known IDs. |
| `bookends_get_formatted_reference` | Format as plain text, RTF, Markdown, HTML, BibTeX, or Styled. |
| `bookends_get_pdf_content` | Extract text or annotations from attached PDFs. |
| `bookends_annotate_pdf` | Add/remove highlights, underlines, notes on PDFs. |
| `bookends_get_citations` | Fetch cited-by / cited-in from OpenAlex. |
| `bookends_quick_add` | Import references by DOI, PMID, arXiv, ISBN, or JSTOR URL. |
| `bookends_add_pdf` | Attach or download PDFs to existing references. |
| `bookends_import_pdf_folder` | Batch-import a folder of PDFs as new references. |
| `bookends_groups` | Get, create, rename, delete groups; add refs to groups. |
| `bookends_set_field` | Update one or more fields on references. |
| `bookends_remove_references` | Trash, restore, or permanently delete references. |
| `bookends_create_publication` | Create one or many new references. |
| `bookends_list_options` | List reference types or output format styles. |
| `bookends_get_attachment_paths` | Get paths for attached files by kind (pdf, docx, etc.). |
| `bookends_libraries` | List, switch, or create open libraries. |
| `bookends_user_guide_search` | Search the Bookends User Guide for how-to questions. |
| `bookends_applescript_reference` | Last-resort AppleScript dictionary lookup. |
| `bookends_applescript_run` | Run raw AppleScript (fallback only). |

## Field Name Notes

| Field | `bookends_search` / `bookends_get_properties` | `bookends_readonly_sql` |
|-------|------|------|
| DOI | `doi` ✓ | Not available as column name |
| PMID | `pmid` ✓ | Not available |
| PMCID | `pmcid` ✓ | Not available (maps to `user16`) |
| Date added | N/A | `dateadded` ✓ |
| Date modified | N/A | `datemodified` ✓ |
| Publication date | `year` | `thedate` (string, e.g. "2026-5-27" or "jul 2026") |
| Title | `title` ✓ | `title` ✓ |
| Authors | `authors` ✓ | `authors` ✓ |
| Journal | N/A | `journal` ✓ |
| Unique ID | `id` (returned) | `uniqueid` ✓ |

**Rule**: Prefer `bookends_search` for field-aware queries (supports DOI/PMID aliases). Use `bookends_readonly_sql` for sorting (`ORDER BY dateadded DESC`), aggregation, or when you need `dateadded`/`thedate`.

## SSE Connection Handling

The Bookends MCP server uses HTTP SSE (Server-Sent Events). The connection is **intermittent** — the server may close the stream between calls.

- **Retry pattern**: First call to a freshly-rediscovered server often fails with `connect ECONNREFUSED` or `other side closed`. Retry immediately — the SSE handshake usually succeeds on the second attempt.
- **Always use `--allow-http`** since the server is on a Tailscale IP with plain HTTP.
- **Always use `--output json`** for machine-parsable results.

## Common Workflows

### Get the 5 most recently added references with DOIs
```bash
# Step 1: Get IDs sorted by date
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_readonly_sql --allow-http \
  sql="SELECT uniqueid FROM thereferences ORDER BY dateadded DESC LIMIT 5" \
  max_rows=5 --output json
# Step 2: Fetch DOIs for those IDs
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_search --allow-http \
  sqlWhere:="uniqueid IN (id1, id2, ...)" fields:='["title","authors","doi"]' limit:=5 --output json
```

### Import a reference by DOI
```bash
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_quick_add --allow-http \
  ids:='["10.1038/s41562-026-02446-z"]' --output json
```

### Count references in a group
```bash
npx mcporter call --http-url http://100.112.1.1:8787/mcp bookends_search --allow-http \
  group="MyGroup" count_only:=true --output json
```

## Config

Configured in Hermes under `mcp_servers` in `~/.hermes/config.yaml`:
```yaml
mcp_servers:
  bookends-mcp:
    url: "http://100.112.1.1:8787/mcp"
    timeout: 10
```

The IP is a Tailscale address — the server runs on the user's Mac.
