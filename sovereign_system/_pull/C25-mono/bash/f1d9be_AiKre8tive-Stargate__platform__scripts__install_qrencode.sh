#!/bin/bash
set -euo pipefail
# REPO: AiKre8tive-Stargate | FILE: platform/scripts/install_qrencode.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash

echo "🔧 Installing qrencode in Termux..."

# 1. Prerequisites
pkg update -y && pkg upgrade -y
pkg install -y git cmake make clang libpng zlib

# 2. Clean any existing clone
rm -rf ~/libqrencode

# 3. Clone and prepare build
git clone https://github.com/fukuchi/libqrencode.git ~/libqrencode
cd ~/libqrencode
mkdir build && cd build

# 4. Fix for older CMake versions
cmake .. -DCMAKE_POLICY_DEFAULT_CMP0054=NEW || {
  echo "❌ CMake failed. Trying with compatibility flags..."
  cmake .. -DCMAKE_POLICY_VERSION=3.5
}

# 5. Compile and install
make && make install

# 6. Verify
if command -v qrencode >/dev/null 2>&1; then
  echo "✅ qrencode installed successfully!"
  qrencode -o ~/test_qr.png "https://aikre8tive.xyz"
  termux-open ~/test_qr.png
else
  echo "❌ Installation failed. Try manual build or use pkg-config debug."
fi
