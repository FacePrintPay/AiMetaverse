import os, json, re, hashlib, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]  # monorepo root
SCAN = ROOT / "tools" / "_sources"
OUTD = ROOT / "reports"
OUTD.mkdir(parents=True, exist_ok=True)

TARGET_EXT = {".md", ".html", ".htm", ".json", ".yaml", ".yml", ".toml", ".ini"}
BUILD_FILES = {
  "package.json","pnpm-lock.yaml","yarn.lock","package-lock.json",
  "go.mod","go.sum","Cargo.toml","Cargo.lock",
  "pyproject.toml","requirements.txt","Pipfile","Pipfile.lock",
  "Dockerfile","docker-compose.yml","Makefile","CMakeLists.txt",
  "build.gradle","settings.gradle","gradlew","gradlew.bat",
  "AndroidManifest.xml"
}

def sha256_file(p: Path, max_mb=25):
  try:
    if p.is_file() and p.stat().st_size <= max_mb*1024*1024:
      h=hashlib.sha256()
      with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024*1024), b""):
          h.update(chunk)
      return h.hexdigest()
  except Exception:
    pass
  return None

rows=[]
t0=time.time()

if not SCAN.exists():
  print(f"SCAN path missing: {SCAN}")
  raise SystemExit(1)

for p in SCAN.rglob("*"):
  if not p.is_file():
    continue
  rel = p.relative_to(ROOT).as_posix()
  name = p.name
  ext = p.suffix.lower()
  hit = False
  kind = None

  if name in BUILD_FILES:
    hit=True; kind="buildfile"
  elif ext in TARGET_EXT:
    hit=True; kind=f"ext:{ext}"
  elif name.lower().startswith("readme"):
    hit=True; kind="readme"
  elif name.lower() in ("index.html","app.html"):
    hit=True; kind="entrypoint"

  if hit:
    st=p.stat()
    rows.append({
      "path": rel,
      "name": name,
      "kind": kind,
      "size": st.st_size,
      "mtime": int(st.st_mtime),
      "sha256": sha256_file(p),
    })

# basic stats
stats={}
for r in rows:
  stats[r["kind"]] = stats.get(r["kind"],0)+1

# write outputs
(OUTD/"inventory.json").write_text(json.dumps({
  "root": str(ROOT),
  "scan": str(SCAN),
  "count": len(rows),
  "stats": stats,
  "files": rows
}, indent=2), encoding="utf-8")

# human summary
lines=[]
lines.append(f"Inventory count: {len(rows)}")
lines.append("Top kinds:")
for k,v in sorted(stats.items(), key=lambda kv: kv[1], reverse=True)[:30]:
  lines.append(f"  {k}: {v}")
lines.append("")
lines.append("Top 200 largest hits:")
for r in sorted(rows, key=lambda r: r["size"], reverse=True)[:200]:
  lines.append(f"{r['size']:>10}  {r['kind']:<12}  {r['path']}")
(OUTD/"inventory.txt").write_text("\n".join(lines), encoding="utf-8")

print(f"✅ Wrote {OUTD/'inventory.json'} and {OUTD/'inventory.txt'}")
print(f"⏱ Took {time.time()-t0:.2f}s")
