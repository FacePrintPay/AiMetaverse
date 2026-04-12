#!/data/data/com.termux/files/usr/bin/bash
BASE="$HOME/github-repos/Constillation25"
source "$BASE/_agents/claude_api.sh"
MANIFEST="$BASE/_build/manifest.json"
GRAPH="$BASE/_build/dependency_graph.json"
LOG="$BASE/_logs/pathfinder.log"
mkdir -p "$BASE/_build"

echo "[PATHFINDER] $(date)" | tee "$LOG"

python3 << PYEOF > "$MANIFEST"
import os, json, re

base = os.path.expanduser("~/github-repos/Constillation25")
skip = {'_agents','_build','_sync','_patches','_logs','_config','_reports'}
repos = [d for d in os.listdir(base)
         if os.path.isdir(os.path.join(base,d))
         and not d.startswith('.') and d not in skip]

manifest = {"repos": {}, "total_files": 0, "timestamp": ""}
import datetime
manifest["timestamp"] = datetime.datetime.now(datetime.UTC).isoformat()

for repo in repos:
    rpath = os.path.join(base, repo)
    files = []; imports = []
    stack = []
    if os.path.exists(os.path.join(rpath,'package.json')): stack.append('node')
    if os.path.exists(os.path.join(rpath,'requirements.txt')): stack.append('python')
    if os.path.exists(os.path.join(rpath,'build.gradle')): stack.append('android')
    if os.path.exists(os.path.join(rpath,'go.mod')): stack.append('go')
    if not stack: stack.append('unknown')

    for root,dirs,fs in os.walk(rpath):
        dirs[:] = [d for d in dirs if d not in ['.git','node_modules','__pycache__','.gradle','build']]
        for f in fs:
            rel = os.path.relpath(os.path.join(root,f), rpath)
            files.append(rel)
            fp = os.path.join(root,f)
            if f.endswith(('.py','.js','.ts','.java')):
                try:
                    c = open(fp).read()
                    for r2 in repos:
                        if r2 != repo and r2.lower() in c.lower():
                            imports.append(r2)
                except: pass

    manifest['repos'][repo] = {
        "path": rpath, "stack": stack,
        "file_count": len(files),
        "files": files[:60],
        "cross_repo_refs": list(set(imports))
    }
    manifest['total_files'] += len(files)

print(json.dumps(manifest, indent=2))
PYEOF

python3 << PYEOF > "$GRAPH"
import json, os
m = json.load(open(os.path.expanduser("~/github-repos/Constillation25/_build/manifest.json")))
graph = {"nodes":[], "edges":[], "execution_order":[]}
for repo,info in m["repos"].items():
    graph["nodes"].append({"id":repo,"stack":info["stack"],"files":info["file_count"]})
    for dep in info.get("cross_repo_refs",[]):
        graph["edges"].append({"from":repo,"to":dep,"type":"ref"})

deps = {r:set(i["cross_repo_refs"]) for r,i in m["repos"].items()}
order=[]; visited=set()
def visit(n):
    if n in visited: return
    visited.add(n)
    for d in deps.get(n,[]):
        if d in deps: visit(d)
    order.append(n)
for r in m["repos"]: visit(r)
graph["execution_order"] = order
print(json.dumps(graph,indent=2))
PYEOF

REPOS=$(python3 -c "import json; m=json.load(open('$MANIFEST')); print(len(m['repos']))")
FILES=$(python3 -c "import json; m=json.load(open('$MANIFEST')); print(m['total_files'])")
echo "[PATHFINDER] Mapped $REPOS repos / $FILES files" | tee -a "$LOG"
echo "✓ PATHFINDER complete"
