#!/bin/bash

# Full Termux Bash Setup for Syncing $HOME Files to Obsidian with Integrity Checks and Script Porting
# Based on davidkopp/termux-scripts (https://github.com/davidkopp/termux-scripts)
# Adapted for syncing all $HOME files, finding them, 585k integrity run, and porting scripts to Obsidian Canvas/Notes.

set -e  # Exit on error

# Variables (Customize these)
HOME_DIR="$HOME"  # Your Termux $HOME
REPO_DIR="$HOME/storage/shared/ObsidianVault"  # Local Obsidian vault path (adjust to your vault)
REMOTE_REPO="git@github.com:yourusername/your-obsidian-repo.git"  # Your Git remote for Obsidian
BRANCH="main"
INTEGRITY_FILE="$HOME/integrity_check.sha256"  # File for 585k integrity run (assumed to be a checksum file; create if needed)
OBSIDIAN_NOTES_DIR="$REPO_DIR/Notes"  # Directory in Obsidian for logged scripts
OBSIDIAN_CANVAS_DIR="$REPO_DIR/Canvas"  # Directory for Canvas files
GIT_USER_EMAILS=("CyGeL.co@gmail.com" "iconosys4@gmail.com" "hempchoices@gmail.com")  # Your Obsidian usernames
SCRIPT_LOG_FILE="$OBSIDIAN_NOTES_DIR/bash_script_log.md"  # Log file for porting scripts

# Function to find and list all files in $HOME
find_all_home_files() {
    echo "Finding all files in $HOME_DIR..."
    find "$HOME_DIR" -type f | tee "$HOME_DIR/all_home_files.txt"
    echo "File list saved to $HOME_DIR/all_home_files.txt"
}

# Function for integrity check (585k run: assumes a SHA256 checksum file; run yesterday's check)
integrity_check() {
    echo "Running integrity check (585k run)..."
    if [ -f "$INTEGRITY_FILE" ]; then
        sha256sum -c "$INTEGRITY_FILE" || echo "Integrity check failed! Some files may be corrupted."
    else
        echo "Creating new integrity file..."
        find "$HOME_DIR" -type f -exec sha256sum {} \; > "$INTEGRITY_FILE"
        echo "Integrity file created at $INTEGRITY_FILE (size: $(du -h "$INTEGRITY_FILE" | cut -f1))"
    fi
}

# Clone and adapt davidkopp/termux-scripts
setup_scripts() {
    cd "$HOME"
    if [ ! -d "termux-scripts" ]; then
        git clone https://github.com/davidkopp/termux-scripts.git
    fi
    cd termux-scripts
    chmod +x *.sh
    # Adapt for multi-repo setup (your $HOME as a repo)
    ./setup-multi-repo.sh "$REPO_DIR" "$BRANCH" "obsidian"
}

# Setup Git for Obsidian syncing with multiple emails
setup_git() {
    git config --global user.name "Your Name"  # Set your name
    for email in "${GIT_USER_EMAILS[@]}"; do
        git config --global user.email "$email"  # Cycle through emails if needed (or set per repo)
    done
    cd "$REPO_DIR"
    if [ ! -d ".git" ]; then
        git init
        git remote add origin "$REMOTE_REPO"
        git checkout -b "$BRANCH"
    fi
}

# Sync $HOME files to Obsidian repo
sync_home_to_obsidian() {
    echo "Syncing $HOME files to Obsidian..."
    rsync -av --exclude=".git" --exclude="termux-scripts" "$HOME_DIR/" "$REPO_DIR/HomeBackup/"
    cd "$REPO_DIR"
    git add .
    git commit -m "Auto-sync $HOME files with integrity check $(date)"
    git push origin "$BRANCH"
}

# Port Bash scripts to Obsidian Note/Canvas each time a command runs
port_script_to_obsidian() {
    # This will be called via a bash hook (see below)
    SCRIPT_CONTENT="$1"
    TIMESTAMP=$(date)
    echo "# Bash Script Run - $TIMESTAMP" >> "$SCRIPT_LOG_FILE"
    echo "\`\`\`bash" >> "$SCRIPT_LOG_FILE"
    echo "$SCRIPT_CONTENT" >> "$SCRIPT_LOG_FILE"
    echo "\`\`\`" >> "$SCRIPT_LOG_FILE"
    echo "" >> "$SCRIPT_LOG_FILE"
    # For Canvas: Create a simple JSON-based Canvas file (Obsidian Canvas uses JSON)
    CANVAS_FILE="$OBSIDIAN_CANVAS_DIR/bash_run_$TIMESTAMP.canvas"
    cat > "$CANVAS_FILE" <<EOF
{
  "nodes": [
    {
      "id": "script-node",
      "type": "text",
      "text": "# Bash Script\n\`\`\`bash\n$SCRIPT_CONTENT\n\`\`\`",
      "x": 100,
      "y": 100
    }
  ],
  "edges": []
}
EOF
    cd "$REPO_DIR"
    git add "$SCRIPT_LOG_FILE" "$CANVAS_FILE"
    git commit -m "Ported bash script to Note/Canvas - $TIMESTAMP"
    git push origin "$BRANCH"
}

# Enable wake lock and embedded session
enable_wake_lock() {
    termux-wake-lock  # Keep device awake during sync
    # For embedded/keep alive: Use Termux:Boot to run this script on boot
}

# Main setup
echo "Starting full Termux-Obsidian sync setup..."
find_all_home_files
integrity_check
setup_scripts
setup_git
sync_home_to_obsidian
enable_wake_lock

# Add bash hook for porting scripts (append to ~/.bashrc)
HOOK_SCRIPT="
# Hook to port scripts to Obsidian
trap 'port_script_to_obsidian \"\$BASH_COMMAND\"' DEBUG
"
echo "$HOOK_SCRIPT" >> ~/.bashrc
source ~/.bashrc

echo "Setup complete! Your $HOME is now synced to Obsidian with integrity checks and script porting."
echo "Use Tasker for automation (see below)."
