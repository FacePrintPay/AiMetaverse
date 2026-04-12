#!/data/data/com.termux/files/usr/bin/bash

# --- Termux "Bells and Whistles" Setup Script ---

echo "Starting comprehensive Termux setup..."

# 1. Update and upgrade existing packages
echo "Updating and upgrading packages..."
pkg update -y && pkg upgrade -y

# 2. Grant storage access
echo "Requesting storage access permission..."
termux-setup-storage
# A pop-up will appear; please accept the permission request.

# 3. Install essential development and utility packages
echo "Installing essential packages: git, python, nodejs, curl, wget, nano, htop, openssh..."
pkg install git python nodejs curl wget nano htop openssh -y

# 4. Install zsh and Oh My Zsh for a better shell experience
echo "Installing Zsh and Oh My Zsh for customization..."
pkg install zsh -y
sh -c "$(curl -fsSL raw.githubusercontent.com)" "" --unattended
# Set zsh as default shell (this might require restarting Termux)
chsh -s zsh

# 5. Install Neofetch to display system info with some flair
echo "Installing Neofetch for system information display..."
pkg install neofetch -y

# 6. Customize the prompt (optional: Oh My Zsh handles this well, but you can add more)
echo "Customization complete. Consider using the Termux:Styling app from F-Droid for themes and fonts."

# 7. Clean up cache
echo "Cleaning up package cache..."
pkg clean -y

echo "Setup is complete. Please restart Termux for all changes (especially the new shell) to take effect."
neofetch
