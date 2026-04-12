#!/bin/bash
# Snapshot filesystem and inject into C25 shared memory

SNAPSHOT=$(find ~ ~/storage \
  -not -path "*/proc/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/cache/*" \
  -not -path "*/.npm/*" \
  -not -path "*/tmp/*" \
  -not -path "*/.cache/*" \
  -not -path "*/gradle/*" \
  -not -path "*/.android/*" \
  2>/dev/null | sort)

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "{
  \"jsonrpc\":\"2.0\",
  \"id\":1,
  \"method\":\"tools/call\",
  \"params\":{
    \"name\":\"memory_store\",
    \"arguments\":{
      \"key\":\"fs_snapshot\",
      \"agent\":\"earth\",
      \"value\":$(echo "$SNAPSHOT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'),
      \"meta\":\"$TIMESTAMP\"
    }
  }
}" | python3 ~/constellation25/mcp-stdlib.py

echo "[$TIMESTAMP] FS context injected into shared memory"
