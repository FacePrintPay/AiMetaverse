#!/bin/bash

# Constellation25 Build Script
# Builds custom packages for Agentik ecosystem

set -euo pipefail

BUILD_DIR="$HOME/build-area"
REPO_DIR="$HOME/build-repo"
PACKAGE_NAME="agentik-ecosystem"
VERSION="1.0.0"

# Create build environment
mkdir -p "$BUILD_DIR"
mkdir -p "$BUILD_DIR/src"
mkdir -p "$BUILD_DIR/debian"

# Create source directory structure
mkdir -p "$BUILD_DIR/src/telegram-bot"
mkdir -p "$BUILD_DIR/src/chaturbate-integration"
mkdir -p "$BUILD_DIR/src/qr-generator"
mkdir -p "$BUILD_DIR/src/security-monitor"

# Copy source code (assuming you have it in your repos)
if [ -d "$HOME/github-repos/Constillation25" ]; then
    cp -r "$HOME/github-repos/Constillation25/." "$BUILD_DIR/src/"
fi

# Create Debian package structure
cat > "$BUILD_DIR/debian/control" << CONTROL_EOF
Package: agentik-ecosystem
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Depends: python3, nodejs, git, curl, tmux, jq
Maintainer: TotalRecall <totalrecall@constellation25.com>
Description: Complete Agentik ecosystem for Chaturbate integration
 This package contains the complete Agentik Agents system including:
 - Telegram bot integration
 - Chaturbate stream monitoring
 - QR code generation system
 - Security monitoring features
 - Multi-platform integration
 - Web presence generation
CONTROL_EOF

cat > "$BUILD_DIR/debian/rules" << RULES_EOF
#!/usr/bin/make -f
%:
	dh $@
RULES_EOF

chmod +x "$BUILD_DIR/debian/rules"

# Create post-installation script
cat > "$BUILD_DIR/debian/postinst" << POSTINST_EOF
#!/bin/bash
echo "Setting up Agentik ecosystem..."
# Create necessary directories
mkdir -p /data/data/com.termux/files/home/agentik_deployment
mkdir -p /data/data/com.termux/files/home/agentik_deployment/logs
mkdir -p /data/data/com.termux/files/home/agentik_deployment/configs

# Set up tmux sessions
tmux kill-session -t agentik_agents 2>/dev/null || true
tmux new-session -d -s agentik_agents

echo "Agentik ecosystem installed successfully!"
echo "To start services: cd ~/agentik_deployment && ./scripts/start_services.sh"
POSTINST_EOF

chmod +x "$BUILD_DIR/debian/postinst"

# Build the package
cd "$BUILD_DIR"
dpkg-deb --build src "$PACKAGE_NAME"_"$VERSION"_all.deb

# Move to repository pool
mv "$PACKAGE_NAME"_"$VERSION"_all.deb "$REPO_DIR/pool/main/"

# Update repository index
cd "$REPO_DIR"
dpkg-scanpackages pool/ /dev/null | gzip -9c > dists/stable/main/binary-aarch64/Packages.gz

echo "Build completed successfully!"
echo "Package: $PACKAGE_NAME version $VERSION"
echo "Location: $REPO_DIR/pool/main/"
