#!/usr/bin/env python3
import os, json, hashlib, tarfile, time, shutil, subprocess

HOME   = os.path.expanduser("~")
SDCARD = "/sdcard"
OUT    = "/sdcard/C25_MASTER_BUILD"
VAULT  = os.path.join(OUT, "vault")
REPORT = os.path.join(OUT, "MASTER_MANIFEST.json")
INDEX  = os.path.join(OUT, "BUILD_INDEX.txt")

os.makedirs(OUT, exist_ok=True)
os.makedirs(VAULT, exist_ok=True)

print("=" * 60)
print("C25 MASTER COMPILER — FINDING ALL BUILDS")
print("=" * 60)

SCAN_ROOTS = [
    HOME,
    "/sdcard",
    "/sdcard/Obsidian",
    "/sdcard/Obsidian-Vaults",
    "/sdcard/Obsidian_Vault_Termux",
    "/sdcard/C25-MASTER-BACKUP",
    "/sdcard/C25-backup",
    "/sdcard/C25-full-backup",
    "/sdcard/c25_backup",
    "/sdcard/constellation25-build",
    "/sdcard/CONSTELLATION25_DEMO",
    "/sdcard/SOVEREIGN_DISK",
    "/sdcard/AI_MetaVerse",
    "/sdcard/AiMetaverse",
    "/sdcard/AiMetaverse_Vault",
    "/sdcard/aikre8tive",
    "/sdcard/VideoCourts",
    "/sdcard/data_hub",
    "/sdcard/SOVEREIGN_PORTFOLIO_1M",
    "/sdcard/X-plore_sandbox",
    "/sdcard/TermuxWizard_backup",
    "/sdcard/DriveSyncFiles",
    "/sdcard/Documents",
    "/sdcard/Download",
    "/sdcard/TOTAL_RECALL_CYGNUS_20260117_215021",
    "/sdcard/ForensicArchive",
    "/sdcard/EvidenceBundles",
    "/sdcard/LEGAL_EVIDENCE_LOCKED",
    "/sdcard/MASTER_EVIDENCE_20260319_FULL_CASE",
    "/sdcard/MASTER_EVIDENCE_20260216_074341",
    "/sdcard/Z-File-Evidence",
    "/sdcard/Suspect_AI_Output",
    "/sdcard/WideOpen Vault",
    "/sdcard/c25-legal-vault-backup",
    "/sdcard/SOVEREIGN_LOGS_20260123_000634",
    "/sdcard/C25_INVENTORY",
    "/sdcard/DriveSyncFiles",
    "/sdcard/deploys_20251223_020013",
    "/sdcard/sovereign_20251223_022254",
    "/sdcard/sovereign_20251223_030308",
]

CODE_EXTS = {
    ".sh":"bash", ".py":"python", ".js":"javascript",
    ".ts":"typescript", ".html":"html", ".css":"css",
    ".json":"json", ".md":"markdown", ".txt":"text",
    ".sql":"sql", ".env":"env", ".yaml":"yaml",
    ".yml":"yaml", ".toml":"toml", ".ini":"config",
}

SKIP_DIRS = {
    'node_modules','.git','__pycache__','.cache',
    'proc','sys','dev','tmp','.npm','npm-cache',
    'lost+found','.thumbnails','.trash'
}

PROJECTS = {
    "c25":"Constellation25", "constellation":"Constellation25",
    "pathos":"Pathos", "sovereign":"SovereignGTP",
    "sovereigngtp":"SovereignGTP", "videocourts":"VideoCourts",
    "totalrecall":"TotalRecall", "total_recall":"TotalRecall",
    "yesquid":"YesQuid", "faceprintpay":"FacePrintPay",
    "aikre8tive":"AiKre8tive", "aimetaverse":"AiMetaverse",
    "nlp2code":"NLP2CODE", "obsidian":"Obsidian",
    "legyc":"LEGYC", "whispersync":"WhisperSync",
    "versacam":"VersaCam", "portaled":"PortaledAI",
    "versed":"Versed", "agentik":"Agentik",
    "legal":"Legal", "evidence":"Evidence",
    "backup":"Backups", "xplore":"Xplorer",
    "ranger":"Ranger", "recall":"TotalRecall",
    "wideopen":"WideOpen", "repower":"RePower",
}

def get_project(fp):
    lower = fp.lower()
    for kw, proj in PROJECTS.items():
        if kw in lower:
            return proj
    return "Uncategorized"

def sha256(fp):
    try:
        h = hashlib.sha256()
        with open(fp, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                h.update(chunk)
        return h.hexdigest()[:16]
    except:
        return "00000000"

all_files = []
seen = set()

# SCAN TARBALLS
print("\n[1/4] Scanning tarballs and zip archives...")
r = subprocess.run(
    "find /sdcard " + HOME + " -name '*.tar.gz' -o -name '*.tar.bz2' -o -name '*.zip' 2>/dev/null",
    shell=True, capture_output=True, text=True
)
tarballs = [x.strip() for x in r.stdout.split('\n') if x.strip()]
print("  Found " + str(len(tarballs)) + " archives")
for tp in tarballs:
    if not os.path.exists(tp): continue
    print("  Reading: " + os.path.basename(tp))
    try:
        with tarfile.open(tp, 'r:*') as tf:
            for m in tf.getmembers():
                ext = os.path.splitext(m.name)[1].lower()
                if ext in CODE_EXTS:
                    all_files.append({
                        "path": tp + "::" + m.name,
                        "name": os.path.basename(m.name),
                        "size": m.size,
                        "type": CODE_EXTS[ext],
                        "project": get_project(m.name),
                        "location": "tarball"
                    })
    except Exception as e:
        print("    skip: " + str(e))

# SCAN FILESYSTEM
print("\n[2/4] Scanning all filesystem locations...")
scanned = set()
for root in SCAN_ROOTS:
    if not os.path.exists(root): continue
    if root in scanned: continue
    scanned.add(root)
    print("  " + root)
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext not in CODE_EXTS: continue
            fp = os.path.join(dirpath, fname)
            try:
                sz = os.path.getsize(fp)
                if sz == 0: continue
                h = sha256(fp)
                if h in seen: continue
                seen.add(h)
                all_files.append({
                    "path": fp,
                    "name": fname,
                    "size": sz,
                    "type": CODE_EXTS[ext],
                    "project": get_project(fp),
                    "location": "filesystem",
                    "hash": h
                })
            except: pass

print("  Unique files: " + str(len(all_files)))

# SCAN OBSIDIAN SPECIFICALLY
print("\n[3/4] Deep scanning Obsidian vaults...")
for root in ["/sdcard/Obsidian", "/sdcard/Obsidian-Vaults", "/sdcard/Obsidian_Vault_Termux"]:
    if not os.path.exists(root): continue
    for dirpath, dirnames, filenames in os.walk(root):
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext not in CODE_EXTS: continue
            fp = os.path.join(dirpath, fname)
            try:
                h = sha256(fp)
                if h in seen: continue
                seen.add(h)
                all_files.append({
                    "path": fp,
                    "name": fname,
                    "size": os.path.getsize(fp),
                    "type": CODE_EXTS[ext],
                    "project": get_project(fp),
                    "location": "obsidian",
                    "hash": h
                })
            except: pass

# ORGANIZE
print("\n[4/4] Organizing by project and copying to vault...")
by_project = {}
by_type = {}
for f in all_files:
    proj = f.get("project", "Uncategorized")
    typ  = f.get("type", "unknown")
    by_project.setdefault(proj, []).append(f)
    by_type.setdefault(typ, []).append(f)

# Copy to vault
copied = 0
for f in all_files:
    if f.get("location") == "tarball": continue
    fp = f.get("path","")
    if not os.path.exists(fp): continue
    proj_dir = os.path.join(VAULT, f.get("project","Unknown"))
    os.makedirs(proj_dir, exist_ok=True)
    dest = os.path.join(proj_dir, f.get("hash","x") + "_" + f.get("name","file"))
    try:
        shutil.copy2(fp, dest)
        copied += 1
    except: pass

# Write manifest
manifest = {
    "generated": time.strftime("%Y-%m-%d %H:%M:%S"),
    "total_files": len(all_files),
    "unique_projects": len(by_project),
    "files_in_vault": copied,
    "by_type": {k: len(v) for k,v in by_type.items()},
    "by_project": {k: len(v) for k,v in by_project.items()},
    "projects": {}
}
for proj, files in sorted(by_project.items()):
    manifest["projects"][proj] = [
        {"path": f.get("path"), "name": f.get("name"), "size": f.get("size"), "type": f.get("type")}
        for f in sorted(files, key=lambda x: x.get("size",0), reverse=True)
    ]

with open(REPORT, "w") as f:
    json.dump(manifest, f, indent=2)

# Write index
lines = []
lines.append("C25 MASTER BUILD INDEX")
lines.append("Generated: " + time.strftime("%Y-%m-%d %H:%M:%S"))
lines.append("=" * 60)
lines.append("TOTAL FILES : " + str(len(all_files)))
lines.append("PROJECTS    : " + str(len(by_project)))
lines.append("IN VAULT    : " + str(copied))
lines.append("")
lines.append("BY TYPE:")
for k,v in sorted(by_type.items(), key=lambda x: -len(x[1])):
    lines.append("  " + k.ljust(15) + str(len(v)).rjust(6) + " files")
lines.append("")
lines.append("BY PROJECT:")
for proj, files in sorted(by_project.items(), key=lambda x: -len(x[1])):
    lines.append("")
    lines.append("  [" + proj + "] " + str(len(files)) + " files")
    for fi in sorted(files, key=lambda x: x.get("size",0), reverse=True)[:15]:
        lines.append("    " + fi.get("name","?").ljust(40) + " " + str(fi.get("size",0)).rjust(8) + "b")
        lines.append("      " + fi.get("path",""))
    if len(files) > 15:
        lines.append("    ... and " + str(len(files)-15) + " more")

with open(INDEX, "w") as f:
    f.write("\n".join(lines))

print("\n" + "=" * 60)
print("COMPLETE")
print("=" * 60)
print("TOTAL FILES : " + str(len(all_files)))
print("PROJECTS    : " + str(len(by_project)))
print("IN VAULT    : " + str(copied))
print("")
print("BY TYPE:")
for k,v in sorted(by_type.items(), key=lambda x: -len(x[1])):
    print("  " + k.ljust(15) + str(len(v)).rjust(6) + " files")
print("")
print("BY PROJECT:")
for proj, files in sorted(by_project.items(), key=lambda x: -len(x[1])):
    print("  " + proj.ljust(25) + str(len(files)).rjust(5) + " files")
print("")
print("MANIFEST : " + REPORT)
print("INDEX    : " + INDEX)
print("VAULT    : " + VAULT)
