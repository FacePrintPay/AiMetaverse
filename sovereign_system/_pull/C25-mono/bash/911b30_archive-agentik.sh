#!/data/data/com.termux/files/usr/bin/bash
set -e
ARCHIVE_DIR="$HOME/archives/agentik"
mkdir -p "$ARCHIVE_DIR"
echo "[*] Cloning FacePrintPay/agentik..."
cd "$ARCHIVE_DIR"
if [ ! -d "agentik" ]; then
    git clone https://github.com/FacePrintPay/agentik.git
else
    cd agentik && git pull
fi
cd "$ARCHIVE_DIR/agentik"
echo "[*] Generating SHA256 manifest..."
find . -type f -not -path "*/.git/*" -exec sha256sum {} \; > "$ARCHIVE_DIR/manifest.sha256"
echo "[*] Signing manifest..."
gpg --clearsign "$ARCHIVE_DIR/manifest.sha256"
echo "✅ Agentik archived with cryptographic proof."
echo "→ Repo: $ARCHIVE_DIR/agentik"
echo "→ Manifest: $ARCHIVE_DIR/manifest.sha256"
