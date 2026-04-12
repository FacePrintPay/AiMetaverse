#!/usr/bin/env python3
import os, json, requests
from bs4 import BeautifulSoup

print("[Mercury] Fetching publicapis.org...")
r = requests.get("https://api.publicapis.org/entries", timeout=30)
data = r.json()
entries = data.get("entries", [])
print("[Mercury] Got " + str(len(entries)) + " APIs")

out = "/data/data/com.termux/files/home/c25-repodepo/api-vault/publicapis.json"
open(out, "w").write(json.dumps(entries, indent=2))
print("[Cassiopeia] Saved: " + out)

print("[Jupiter] Fetching public-apis GitHub README...")
r2 = requests.get("https://raw.githubusercontent.com/public-apis/public-apis/master/README.md", timeout=30)
cats = {}
current = "General"
count = 0
for line in r2.text.split("\n"):
    line = line.strip()
    if line.startswith("### "):
        current = line[4:].strip()
        cats[current] = []
    elif line.startswith("|") and "---" not in line:
        parts = [p.strip() for p in line.split("|")]
        parts = [p for p in parts if p]
        if len(parts) >= 2 and parts[0].lower() not in ["api","name"]:
            name = parts[0]
            if "](" in name:
                try:
                    name = name.split("[")[1].split("]")[0]
                except: pass
            if current not in cats: cats[current] = []
            cats[current].append({"name":name,"desc":parts[1] if len(parts)>1 else ""})
            count += 1

out2 = "/data/data/com.termux/files/home/c25-repodepo/api-vault/github_public_apis.json"
open(out2, "w").write(json.dumps(cats, indent=2))
print("[Orion] GitHub APIs: " + str(count) + " across " + str(len(cats)) + " categories")

print("[Moon] Writing manifest...")
manifest = {
    "architect": "Cygel White",
    "system": "Constellation-25",
    "brand": "Kre8tive AI @ Kre8tive.Space",
    "total_publicapis": len(entries),
    "total_github_apis": count,
    "categories": list(cats.keys())
}
open("/data/data/com.termux/files/home/c25-repodepo/api-vault/_index.json","w").write(json.dumps(manifest,indent=2))
print("[C25] DONE - " + str(len(entries)+count) + " total APIs harvested")
