#!/usr/bin/env python3
"""
TERMUX TRUTH EXTRACTOR
Bash history = immutable build record
Finds every script ever executed, every command run
"""
import os, subprocess, json, time, hashlib

HOME   = os.path.expanduser("~")
SDCARD = "/sdcard"
OUT    = "/sdcard/TERMUX_TRUTH"
os.makedirs(OUT, exist_ok=True)

print("=" * 60)
print("TERMUX TRUTH EXTRACTOR")
print("Every bash ever run. Full history.")
print("=" * 60)

# ── 1. ALL HISTORY FILES ──────────────────────────────────────
history_files = [
    os.path.join(HOME, ".bash_history"),
    os.path.join(HOME, ".zsh_history"),
    os.path.join(HOME, ".sh_history"),
    os.path.join(HOME, ".local/share/fish/fish_history"),
    "/sdcard/.bash_history",
    "/sdcard/SOVEREIGN_LOGS_20260123_000634/.bash_history",
]

# Also find any history files anywhere
r = subprocess.run(
    "find " + HOME + " /sdcard -name '*_history' -o -name '.bash_history' -o -name '.zsh_history' 2>/dev/null",
    shell=True, capture_output=True, text=True
)
extras = [x.strip() for x in r.stdout.split('\n') if x.strip()]
all_history = list(set(history_files + extras))

print("\n[1/5] Reading all history files...")
all_commands = []
for hf in all_history:
    if not os.path.exists(hf): continue
    try:
        with open(hf, 'r', errors='ignore') as f:
            lines = f.readlines()
        # zsh history has timestamps like ": 1234567890:0;command"
        clean = []
        for line in lines:
            line = line.strip()
            if not line: continue
            if line.startswith(': ') and ';' in line:
                # zsh format
                parts = line.split(';', 1)
                if len(parts) == 2:
                    line = parts[1].strip()
            if line:
                clean.append(line)
        print("  " + hf + " — " + str(len(clean)) + " commands")
        for cmd in clean:
            all_commands.append({
                "source": hf,
                "cmd": cmd
            })
    except Exception as e:
        print("  ERROR: " + hf + " — " + str(e))

print("  TOTAL COMMANDS: " + str(len(all_commands)))

# ── 2. EXTRACT SCRIPT RUNS ────────────────────────────────────
print("\n[2/5] Extracting script executions...")
script_runs = []
keywords = [
    "python3", "python", "bash", "sh ", "node ", "npm ",
    "chmod", "curl", "wget", "git ", "tar ", "cp ", "mv ",
    "pkg ", "apt ", "pip ", "npm run", "node server",
    "pathos", "pathos", "c25", "constellation",
    "sovereign", "agent", "recall", "yesquid",
    "videocourts", "faceprintpay", "./", "source "
]

for entry in all_commands:
    cmd = entry["cmd"].lower()
    for kw in keywords:
        if kw in cmd:
            script_runs.append(entry)
            break

print("  Script-related commands: " + str(len(script_runs)))

# ── 3. FIND ALL .SH FILES THAT EXIST NOW ─────────────────────
print("\n[3/5] Finding all .sh files currently on device...")
r = subprocess.run(
    "find " + HOME + " /sdcard -name '*.sh' 2>/dev/null | sort",
    shell=True, capture_output=True, text=True
)
sh_files = [x.strip() for x in r.stdout.split('\n') if x.strip()]
print("  Found: " + str(len(sh_files)) + " shell scripts")

# Read each one
sh_contents = []
for sf in sh_files:
    try:
        sz = os.path.getsize(sf)
        with open(sf, 'r', errors='ignore') as f:
            content = f.read()
        # Get the description comment
        desc = ""
        for line in content.split('\n')[:10]:
            line = line.strip()
            if line.startswith('#') and len(line) > 2 and not line.startswith('#!/'):
                desc = line[1:].strip()
                break
        sh_contents.append({
            "path": sf,
            "name": os.path.basename(sf),
            "size": sz,
            "desc": desc,
            "lines": content.count('\n'),
            "content_preview": content[:500]
        })
    except: pass

# ── 4. FIND ALL PYTHON SCRIPTS ────────────────────────────────
print("\n[4/5] Finding all Python scripts...")
r = subprocess.run(
    "find " + HOME + " /sdcard -name '*.py' 2>/dev/null | sort",
    shell=True, capture_output=True, text=True
)
py_files = [x.strip() for x in r.stdout.split('\n') if x.strip()]
print("  Found: " + str(len(py_files)) + " python scripts")

py_contents = []
for pf in py_files:
    try:
        sz = os.path.getsize(pf)
        with open(pf, 'r', errors='ignore') as f:
            content = f.read()
        desc = ""
        for line in content.split('\n')[:10]:
            line = line.strip()
            if line.startswith('#') and len(line) > 2 and '!' not in line:
                desc = line[1:].strip()
                break
        py_contents.append({
            "path": pf,
            "name": os.path.basename(pf),
            "size": sz,
            "desc": desc,
            "lines": content.count('\n'),
            "content_preview": content[:500]
        })
    except: pass

# ── 5. CROSS-REFERENCE: WHAT WAS ACTUALLY RUN ────────────────
print("\n[5/5] Cross-referencing: what scripts were actually executed...")
executed = {}
for entry in all_commands:
    cmd = entry["cmd"]
    for sf in sh_files + py_files:
        name = os.path.basename(sf)
        if name in cmd or sf in cmd:
            executed[sf] = executed.get(sf, 0) + 1

print("  Scripts confirmed executed: " + str(len(executed)))

# ── WRITE OUTPUTS ─────────────────────────────────────────────
# Full command history
with open(OUT + "/FULL_HISTORY.txt", "w") as f:
    f.write("TERMUX FULL COMMAND HISTORY\n")
    f.write("Generated: " + time.strftime("%Y-%m-%d %H:%M:%S") + "\n")
    f.write("=" * 60 + "\n\n")
    for e in all_commands:
        f.write(e["cmd"] + "\n")

# Script runs only
with open(OUT + "/SCRIPT_RUNS.txt", "w") as f:
    f.write("TERMUX SCRIPT EXECUTIONS\n")
    f.write("=" * 60 + "\n\n")
    for e in script_runs:
        f.write(e["cmd"] + "\n")

# All .sh files with content
with open(OUT + "/ALL_BASH_SCRIPTS.txt", "w") as f:
    f.write("ALL BASH SCRIPTS ON DEVICE\n")
    f.write("=" * 60 + "\n\n")
    for s in sorted(sh_contents, key=lambda x: -x["size"]):
        f.write("\n" + "─" * 50 + "\n")
        f.write("FILE: " + s["path"] + "\n")
        f.write("SIZE: " + str(s["size"]) + " bytes | LINES: " + str(s["lines"]) + "\n")
        f.write("DESC: " + s["desc"] + "\n")
        f.write("PREVIEW:\n" + s["content_preview"] + "\n")

# All python scripts
with open(OUT + "/ALL_PYTHON_SCRIPTS.txt", "w") as f:
    f.write("ALL PYTHON SCRIPTS ON DEVICE\n")
    f.write("=" * 60 + "\n\n")
    for s in sorted(py_contents, key=lambda x: -x["size"]):
        f.write("\n" + "─" * 50 + "\n")
        f.write("FILE: " + s["path"] + "\n")
        f.write("SIZE: " + str(s["size"]) + " bytes | LINES: " + str(s["lines"]) + "\n")
        f.write("DESC: " + s["desc"] + "\n")
        f.write("PREVIEW:\n" + s["content_preview"] + "\n")

# Executed scripts
with open(OUT + "/CONFIRMED_EXECUTED.txt", "w") as f:
    f.write("SCRIPTS CONFIRMED EXECUTED IN TERMUX\n")
    f.write("=" * 60 + "\n\n")
    for sf, count in sorted(executed.items(), key=lambda x: -x[1]):
        f.write(str(count).rjust(4) + "x  " + sf + "\n")

# Master JSON
master = {
    "generated": time.strftime("%Y-%m-%d %H:%M:%S"),
    "total_commands": len(all_commands),
    "script_related_commands": len(script_runs),
    "sh_files": len(sh_files),
    "py_files": len(py_files),
    "confirmed_executed": len(executed),
    "sh_files_list": [s["path"] for s in sh_contents],
    "py_files_list": [s["path"] for s in py_contents],
    "executed_scripts": executed,
    "top_commands": [e["cmd"] for e in script_runs[:200]]
}
with open(OUT + "/TRUTH_MANIFEST.json", "w") as f:
    json.dump(master, f, indent=2)

# ── PRINT SUMMARY ─────────────────────────────────────────────
print("\n" + "=" * 60)
print("TERMUX TRUTH EXTRACTED")
print("=" * 60)
print("TOTAL COMMANDS     : " + str(len(all_commands)))
print("SCRIPT COMMANDS    : " + str(len(script_runs)))
print("BASH SCRIPTS FOUND : " + str(len(sh_files)))
print("PYTHON SCRIPTS     : " + str(len(py_files)))
print("CONFIRMED EXECUTED : " + str(len(executed)))
print("")
print("TOP BASH SCRIPTS (by size):")
for s in sorted(sh_contents, key=lambda x: -x["size"])[:20]:
    print("  " + str(s["size"]).rjust(8) + "b  " + s["path"])
print("")
print("TOP PYTHON SCRIPTS (by size):")
for s in sorted(py_contents, key=lambda x: -x["size"])[:20]:
    print("  " + str(s["size"]).rjust(8) + "b  " + s["path"])
print("")
print("CONFIRMED EXECUTED:")
for sf, count in sorted(executed.items(), key=lambda x: -x[1])[:20]:
    print("  " + str(count).rjust(3) + "x  " + sf)
print("")
print("OUTPUT DIR: " + OUT)
print("  FULL_HISTORY.txt")
print("  SCRIPT_RUNS.txt")
print("  ALL_BASH_SCRIPTS.txt")
print("  ALL_PYTHON_SCRIPTS.txt")
print("  CONFIRMED_EXECUTED.txt")
print("  TRUTH_MANIFEST.json")
print("=" * 60)
