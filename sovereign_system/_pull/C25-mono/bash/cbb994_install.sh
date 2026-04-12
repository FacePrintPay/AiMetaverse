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
