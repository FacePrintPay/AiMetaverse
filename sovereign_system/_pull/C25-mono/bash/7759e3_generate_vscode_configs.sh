#!/bin/bash

# Create .vscode directory if it doesn't exist
mkdir -p .vscode

# Write tasks.json
cat > .vscode/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "npm: watch",
      "type": "shell",
      "command": "npm run watch",
      "isBackground": true,
      "problemMatcher": ["$tsc-watch"],
