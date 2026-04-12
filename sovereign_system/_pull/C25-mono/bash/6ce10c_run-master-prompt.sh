#!/data/data/com.termux/files/usr/bin/bash
PROMPT_FILE="$HOME/master-prompt.md"
IDEA="$1"

if [ -z "$IDEA" ]; then
  echo "Usage: ./run-master-prompt.sh \"SaaS habit tracker that adapts to user energy levels\""
  exit 1
fi

cat "$PROMPT_FILE"
echo -e "\n\n=== YOUR APP IDEA ===\n$IDEA\n\nNow generate the COMPLETE app. Start with planning questions if unclear."
