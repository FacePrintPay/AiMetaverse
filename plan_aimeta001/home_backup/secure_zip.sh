#!/data/data/com.termux/files/usr/bin/bash
# ------------------------------------------------------------------
# Script: secure_zip.sh
# Purpose: Encrypt, generate checksum, and verify a ZIP file
# Usage: ./secure_zip.sh <path-to-zip>
# ------------------------------------------------------------------

ZIP_PATH="$1"

if [ -z "$ZIP_PATH" ]; then
    echo "Usage: $0 <path-to-zip>"
    exit 1
fi

if [ ! -f "$ZIP_PATH" ]; then
    echo "Error: File not found -> $ZIP_PATH"
    exit 1
fi

# 1️⃣ Install gnupg if not present
if ! command -v gpg >/dev/null 2>&1; then
    echo "Installing gnupg..."
    pkg install gnupg -y
fi

# 2️⃣ Ask for encryption passphrase
echo -n "Enter passphrase for encryption: "
read -s PASSPHRASE
echo ""

# 3️⃣ Encrypt the ZIP
GPG_PATH="${ZIP_PATH}.gpg"
echo "Encrypting $ZIP_PATH -> $GPG_PATH ..."
echo "$PASSPHRASE" | gpg --batch --yes --passphrase-fd 0 -c "$ZIP_PATH"

# 4️⃣ Generate SHA256 checksum
CHECKSUM_PATH="${ZIP_PATH%.*}-checksum.sha256"
sha256sum "$ZIP_PATH" > "$CHECKSUM_PATH"
echo "Checksum created -> $CHECKSUM_PATH"

# 5️⃣ Verify contents of ZIP
echo ""
echo "Preview first 20 files in ZIP:"
unzip -l "$ZIP_PATH" | head -20

echo ""
echo "✅ All done!"
echo "Encrypted file: $GPG_PATH"
echo "Original checksum: $CHECKSUM_PATH"
