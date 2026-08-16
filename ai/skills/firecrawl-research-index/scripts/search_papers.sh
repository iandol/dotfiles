#!/usr/bin/env bash
# Query the Firecrawl Research Index (life sciences papers) with the configured key.
# Usage:
#   search_papers.sh "natural language query" [k] [extra --data-urlencode args...]
# Examples:
#   search_papers.sh "CRISPR base editing off-target effects in primary human T cells" 20
#   search_papers.sh "attention mechanism visual cortex" 5 "authors=Hubei"
set -euo pipefail

KEY_FILE="${KEY_FILE:-/home/cog5/.hermes/.env}"
QUERY="${1:?usage: search_papers.sh \"query\" [k] [filters...]}"
K="${2:-10}"
shift 2 2>/dev/null || true

set -a
# shellcheck disable=SC1090
source "$KEY_FILE" 2>/dev/null || true
set +a

if [ -z "${FIRECRAWL_API_KEY:-}" ]; then
  echo "WARNING: FIRECRAWL_API_KEY not found (tried $KEY_FILE). Keyless tier still works, at lower rate limits." >&2
fi

ARGS=(-G --data-urlencode "query=$QUERY" --data-urlencode "k=$K")
for f in "$@"; do
  ARGS+=(--data-urlencode "$f")
done

curl -s --max-time 30 "https://api.firecrawl.dev/v2/search/research/papers" \
  "${ARGS[@]}" \
  -H "Authorization: Bearer ${FIRECRAWL_API_KEY:-}" | python3 -m json.tool
