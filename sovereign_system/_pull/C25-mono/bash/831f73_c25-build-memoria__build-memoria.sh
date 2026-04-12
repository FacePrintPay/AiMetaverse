# REPO: c25-build-memoria | FILE: build-memoria.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash
set -e
clear
echo "=================================="
echo "  Building MEMORIA™ Repository"
echo "=================================="
echo ""
# Create directory structure
mkdir -p memoria-agent/scripts
mkdir -p memoria-agent/docs
cd memoria-agent
# Create README
cat > README.md << 'ENDREADME'
# MEMORIA™
**World's First Persistent Memory IDE with NLP2CODE Parser**
Created by: CyGeL White & Kre8tive Konceptz LLC  
Powered by: Claude (Anthropic)
## Quick Start
bash install.sh
source ~/.bashrc
memoria stats
ENDREADME
# Create install script
cat > install.sh << 'ENDINSTALL'
#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "Installing MEMORIA..."
mkdir -p $HOME/.memoria
pkg update -y
pkg install -y sqlite python nodejs-lts
sqlite3 $HOME/.memoria/commands.db "CREATE TABLE IF NOT EXISTS commands (id INTEGER PRIMARY KEY, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, command TEXT, exit_code INTEGER);"
echo '#!/data/data/com.termux/files/usr/bin/bash' > $HOME/.memoria/memoria.sh
echo 'DB=$HOME/.memoria/commands.db' >> $HOME/.memoria/memoria.sh
echo 'case "$1" in' >> $HOME/.memoria/memoria.sh
echo '  stats) sqlite3 $DB "SELECT COUNT(*) FROM commands" ;;' >> $HOME/.memoria/memoria.sh
echo '  query) sqlite3 $DB "SELECT command FROM commands WHERE command LIKE '\''%$2%'\'' LIMIT 10" ;;' >> $HOME/.memoria/memoria.sh
echo '  *) echo "Usage: memoria {stats|query}" ;;' >> $HOME/.memoria/memoria.sh
echo 'esac' >> $HOME/.memoria/memoria.sh
chmod +x $HOME/.memoria/memoria.sh
ln -sf $HOME/.memoria/memoria.sh $PREFIX/bin/memoria
if ! grep -q "memoria" $HOME/.bashrc 2>/dev/null; then
  echo 'alias mstats="memoria stats"' >> $HOME/.bashrc
fi
echo ""
echo "✓ MEMORIA installed!"
echo "Run: source ~/.bashrc"
ENDINSTALL
chmod +x install.sh
# Create LICENSE
cat > LICENSE << 'ENDLICENSE'
MIT License
Copyright (c) 2026 CyGeL White and Kre8tive Konceptz LLC
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction.
ENDLICENSE
# Create banner
cat > scripts/banner.sh << 'ENDBANNER'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║         MEMORIA™ - NLP2CODE Parser                 ║"
echo "║                                                    ║"
echo "║  Created by: CyGeL White & Kre8tive Konceptz      ║"
echo "║  Powered by: Claude (Anthropic)                    ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
ENDBANNER
chmod +x scripts/banner.sh
# Initialize git
git init
git add .
git commit -m "Initial commit: MEMORIA v1.0 by CyGeL White"
# Show completion
clear
bash scripts/banner.sh
echo "✓ Repository built successfully!"
echo ""
echo "Location: $(pwd)"
echo ""
echo "Next steps:"
echo "  git remote add origin <your-github-url>"
echo "  git push -u origin main"
echo ""
