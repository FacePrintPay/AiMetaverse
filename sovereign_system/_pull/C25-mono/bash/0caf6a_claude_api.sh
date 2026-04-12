#!/data/data/com.termux/files/usr/bin/bash
# Free local AI via Ollama llama3.2:1b

claude() {
  local PROMPT="$1"
  curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"llama3.2:1b\",\"prompt\":$(echo "$PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))"),\"stream\":false}" \
  | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin); print(d['response'])
except Exception as e:
    print('ERR:'+str(e))
"
}
export -f claude
