#!/bin/zsh

# Check if an argument was provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 '[\"creator\", \"contains\", \"Johnny\"]'"
    exit 1
fi

# The search terms passed as the first argument
# Example: '["creator", "contains", "Johnny"]'
SEARCH_TERMS=$1

# Better BibTeX JSON-RPC endpoint
RPC_URL="http://localhost:23119/better-bibtex/json-rpc"

# Use jq to ensure the input is treated as an array of arrays
# This handles both ["a","b","c"] and [["a","b","c"]] correctly for the API
PAYLOAD=$(jq -n --argjson terms "$SEARCH_TERMS" '{
    jsonrpc: "2.0",
    method: "item.search",
    params: [ (if ($terms[0] | type) == "string" then [$terms] else $terms end) ],
    id: 1
}')

# Check if jq actually produced valid JSON
if [[ -z "$PAYLOAD" ]]; then
    echo "Error: The search term provided is not valid JSON."
    echo "Hint: Use double quotes for strings: '[\"creator\", \"contains\", \"name\"]'"
    exit 1
fi

# 2. Perform the request and pipe directly through a cleaner into jq
# 'tr -d "\000-\037"' removes control characters that break the JSON spec
curl -s -X POST "$RPC_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    | tr -d '\000-\010\013\014\016-\037' \
    | jq .
