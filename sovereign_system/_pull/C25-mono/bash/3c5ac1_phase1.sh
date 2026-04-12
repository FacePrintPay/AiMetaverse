gh repo list Constillation25 --limit 100 --json name | jq -r '.[].name' | \
  xargs -I {} git clone https://github.com/Constillation25/{} ~/repos/{} 2>/dev/null
