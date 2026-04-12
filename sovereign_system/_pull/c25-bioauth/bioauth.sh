#!/data/data/com.termux/files/usr/bin/bash
echo "🔒 Sovereign BioAuth: Scan fingerprint/face"
termux-fingerprint -t "CyGeL White #MrGGTP Deploy" -d "Unlock keys & tokens"
if [ $? -eq 0 ]; then
  echo "✅ Bio verified"
  # Optional decrypt if secrets.enc exists
  if [ -f ~/vault/secrets.enc ]; then
    read -s -p "Enter passphrase (Enter to skip): " pass
    echo
    if [ -n "$pass" ]; then
      openssl enc -aes-256-cbc -d -in ~/vault/secrets.enc -out ~/vault/secrets.tmp -pass pass:"$pass" && \
      source ~/vault/secrets.tmp && \
      shred -u ~/vault/secrets.tmp
    fi
  fi
  exit 0
else
  echo "❌ Bio failed — aborted"
  exit 1
fi
