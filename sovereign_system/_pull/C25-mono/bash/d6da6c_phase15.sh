find ~/repos -name "README.md" -exec sh -c 'ollama run llama3 "Review: $(cat {})"' \;
