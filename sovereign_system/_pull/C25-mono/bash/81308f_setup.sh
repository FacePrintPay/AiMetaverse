#!/data/data/com.termux/files/usr/bin/bash

# ============================================
# TERMUX ULTIMATE SETUP - ONE COMMAND INSTALL
# Everything your planetary agents need
# ============================================

set -e  # Exit on any error

clear
echo "╔════════════════════════════════════════════════╗"
echo "║   🌍 PLANETARY AGENTS - ULTIMATE SETUP 🌍     ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "This will install EVERYTHING you need..."
echo ""

# Confirmation
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# ============================================
# PHASE 1: CORE SYSTEM
# ============================================
echo ""
echo "═══════════════════════════════════════"
echo "PHASE 1: Core System Setup"
echo "═══════════════════════════════════════"

echo "📦 Updating Termux packages..."
pkg update -y && pkg upgrade -y

echo "📦 Installing core packages..."
pkg install -y \
  termux-api \
  git \
  curl \
  wget \
  nano \
  vim \
  neofetch \
  htop \
  openssh \
  rsync \
  python \
  python-pip \
  nodejs \
  ruby \
  golang \
  clang \
  make \
  cmake \
  jq \
  proot \
  proot-distro \
  figlet \
  toilet \
  tmux \
  screen \
  unzip \
  zip \
  tar \
  netcat \
  nmap \
  dnsutils \
  openssl \
  openssl-tool

# Optional: Install extra utilities if available
echo "✅ Core packages installed."

# ============================================
# PHASE 2: DEVELOPMENT & SECURITY TOOLS
# ============================================
echo ""
echo "═══════════════════════════════════════"
echo "PHASE 2: Dev & Recon Tools"
echo "═══════════════════════════════════════"

# Python tools
pip install --upgrade pip
pip install httpx requests rich colorama paramiko mitmproxy

# Node tools (optional)
# npm install -g http-server live-server

# Install Oh My Zsh (optional but popular)
if ! command -v zsh &> /dev/null; then
    pkg install -y zsh
fi

echo "🔧 Setup complete! Reboot Termux for best results."
echo ""
echo "✨ Tip: Run 'neofetch' or 'figlet Welcome' to test!"
echo "🚀 You are now equipped, Planetary Agent."
