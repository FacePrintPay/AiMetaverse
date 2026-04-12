#!/bin/bash
# Query the injected FS snapshot from C25 shared memory

QUERY=$1

if [ -z "$QUERY" ]; then
  echo "Usage: $0 <search_pattern>"
  exit 1
fi

# Request the value from memory_store
RESPONSE=$(echo "{
  \"jsonrpc\":\"2.0\",
  \"id\":2,
  \"method\":\"tools/call\",
  \"params\":{
    \"name\":\"memory_load\",
    \"arguments\":{
      \"key\":\"fs_snapshot\",
      \"agent\":\"earth\"
    }
  }
}" | python3 ~/constellation25/mcp-stdlib.py)

# Extract the value and grep for the pattern
echo "$RESPONSE" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    # Navigating the typical MCP JSON-RPC response structure
    content = data.get('result', {}).get('content', [{}])[0].get('text', '')
    if not content:
        # Fallback if the stdlib returns the raw value directly
        content = data.get('result', '')
    print(content)
except Exception as e:
    print(f'Error parsing JSON: {e}', file=sys.stderr)
" | grep -i "$QUERY"

