#!/bin/bash
# Ollama query wrapper with C25 filesystem context injected
# Usage: ./ollama-c25.sh "your prompt here" [agent_name] [model]

PROMPT="$1"
AGENT="${2:-earth}"
MODEL="${3:-llama3}"

# Pull filesystem snapshot from shared memory
FS_CONTEXT=$(echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"memory_retrieve","arguments":{"key":"fs_snapshot"}}}' \
  | python3 ~/constellation25/mcp-stdlib.py \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print(json.loads(d["result"]["content"][0]["text"]).get("value",""))')

# Pull task queue context
TASKS=$(echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"task_list","arguments":{"status":"pending"}}}' \
  | python3 ~/constellation25/mcp-stdlib.py \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); tasks=json.loads(d["result"]["content"][0]["text"]); print(json.dumps(tasks, indent=2))')

# Build system prompt with full context
SYSTEM_PROMPT="You are the $AGENT agent in the Constellation25 (C25) sovereign AI swarm.
Operator: u0_a510 | FacePrintPay / Kre8tive Konceptz
Architecture: Offline-first, Termux aarch64, Android

=== FILESYSTEM CONTEXT (live snapshot) ===
$FS_CONTEXT

=== PENDING TASK QUEUE ===
$TASKS

=== YOUR ROLE ===
$(grep -i "$AGENT" ~/constellation25/agents/${AGENT}.sh 2>/dev/null | head -5)

Rules:
- Always reference actual file paths from the filesystem context above
- Never hallucinate paths — if unsure, say 'not found in snapshot'
- Coordinate with other agents via the task queue
- Log all actions to ~/constellation25/logs/${AGENT}.log"

# Query Ollama
ollama run "$MODEL" --system "$SYSTEM_PROMPT" "$PROMPT"
