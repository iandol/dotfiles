#!/usr/bin/env bash
# Firecrawl CLI wrapper: guarantees FIRECRAWL_API_KEY is loaded before every call.
# The CLI does NOT read ~/.hermes/.env on its own, and keyless mode is refused on
# networks that look like a VPN/proxy, so the key must be present.
#
# Usage:  fc.sh research search-papers "diffusion image synthesis" --limit 20
#         fc.sh --status
set -euo pipefail

if [ -z "${FIRECRAWL_API_KEY:-}" ]; then
  env_file="${HERMES_HOME:-$HOME/.hermes}/.env"
  if [ ! -f "$env_file" ]; then
    echo "fc.sh: no API key in env and no $env_file" >&2
    exit 1
  fi
  set -a
  # shellcheck disable=SC1090
  . "$env_file"
  set +a
fi

if ! command -v firecrawl >/dev/null 2>&1; then
  echo "fc.sh: firecrawl CLI not on PATH (install: npm i -g firecrawl-cli)" >&2
  exit 127
fi

exec firecrawl "$@"
