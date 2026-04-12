#!/usr/bin/env python3
"""
C25 RESTORE FROM SD CARD VAULT
Run: python3 ~/restore_c25.py
"""
import os
import subprocess
import sys

VAULT = "/sdcard/c25-vault-20260318.tar.gz"
HOME  = os.path.expanduser("~")

def run(cmd, check=True):
    print(f">>> {cmd}")
    r = subprocess.run(cmd, shell=True, text=True, capture_output=True)
    if r.stdout: print(r.stdout)
    if r.stderr: print(r.stderr)
    if check and r.returncode != 0:
        print(f"ERROR (exit {r.returncode}) - continuing anyway")
    return r.returncode

print("=" * 50)
print("C25 VAULT RESTORE")
print("=" * 50)

# 1. Verify vault exists
if not os.path.exists(VAULT):
    print(f"VAULT NOT FOUND: {VAULT}")
    sys.exit(1)
print(f"Vault found: {VAULT}")

# 2. Extract into home
print("\n[1/4] Extracting vault to home...")
run(f"tar -xzf {VAULT} -C {HOME} --strip-components=4 "
    f"--wildcards 'data/data/com.termux/files/home/*' 2>/dev/null || "
    f"tar -xzf {VAULT} -C {HOME}", check=False)

# 3. Check what we got
print("\n[2/4] Checking constellation-25...")
run(f"ls {HOME}/constellation-25/ 2>/dev/null | head -20")

print("\n[3/4] Checking pathos/sovereign_gtp...")
run(f"ls {HOME}/pathos/ 2>/dev/null || ls {HOME}/sovereign_gtp/ 2>/dev/null | head -20")

# 4. Fix .bashrc aliases
print("\n[4/4] Restoring key aliases to .bashrc...")
bashrc = os.path.join(HOME, ".bashrc")
aliases = """
# ── C25 RESTORED ALIASES ──────────────────────
alias pathos='cd ~/pathos && node server.js'
alias agents='cat ~/agent_logs/agent_$1*.log 2>/dev/null || ls ~/agent_logs/'
alias sync-agents='cp -r ~/constellation-25 /sdcard/C25-MASTER-BACKUP/ && echo SYNCED'
mkdir -p ~/agent_logs
# ──────────────────────────────────────────────
"""

with open(bashrc, "a") as f:
    f.write(aliases)
print("Aliases written to .bashrc")

print("\n" + "=" * 50)
print("RESTORE COMPLETE")
print("=" * 50)
print("\nNext steps:")
print("  source ~/.bashrc")
print("  ls ~/constellation-25/")
print("  ls ~/pathos/ OR ls ~/sovereign_gtp/")
print("  pathos   (to start server)")
print("=" * 50)
