#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="perseus"
VAULT="$C25/vault"
mkdir -p "$VAULT"
chmod 700 "$VAULT"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  # Verify permissions on sensitive dirs
  VAULT_PERM=$(stat -c "%a" "$VAULT" 2>/dev/null || echo unknown)
  LOG_PERM=$(stat -c "%a" "$LOGS" 2>/dev/null || echo unknown)
  # Check for unexpected files in C25 root
  UNKNOWN=$(find "$C25" -maxdepth 1 -type f -name "*.sh" 2>/dev/null | wc -l)
  echo "[$TS] [$NAME] SECURITY vault_perm:$VAULT_PERM log_perm:$LOG_PERM scripts:$UNKNOWN" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/perseus.log"
  sleep 180
done
