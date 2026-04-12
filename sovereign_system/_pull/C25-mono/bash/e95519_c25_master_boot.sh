#!/data/data/com.termux/files/usr/bin/bash
H=/data/data/com.termux/files/home
mkdir -p $H/agent_logs
echo C25 SOVEREIGN BOOT $(date) > $H/agent_logs/BOOT.log

# 1 Wake swarm
tmux kill-session -t c25 2>/dev/null
tmux new-session -d -s c25 "cd $H/constellation-25 && node server.js"
sleep 3
curl -s http://127.0.0.1:3000/ && echo SWARM OK

# 2 Find all scripts
find $H -name "*.sh" 2>/dev/null | grep -v node_modules | grep -v flutter | grep -v venv | grep -v .git | sort > ~/scripts_list.txt
echo SCRIPTS: $(wc -l < ~/scripts_list.txt)

# 3 Find all PaTHos files
find $H -iname "*pathos*" 2>/dev/null | grep -v node_modules | grep -v flutter | head -20 | tee -a $H/agent_logs/BOOT.log

# 4 Find NLP2CODE
find $H -iname "*nlp2code*" -o -iname "*nlp_to_code*" 2>/dev/null | grep -v node_modules | head -20 | tee -a $H/agent_logs/BOOT.log

# 5 Run all constellation scripts
grep -iE "constellation|c25|pathos|agent" ~/scripts_list.txt | while read s; do
  echo RUNNING: $s
  timeout 15 bash "$s" >> $H/agent_logs/BOOT.log 2>&1
done

# 6 Build NLP2CODE corpus
python3 << PYEND
import os,json
from pathlib import Path
H=os.path.expanduser("~")
os.makedirs(H+"/nlp2code_corpus",exist_ok=True)
corpus=[]
for ext in ["*.py","*.js","*.sh"]:
    for f in list(Path(H).rglob(ext))[:300]:
        try:
            if any(x in str(f) for x in ["node_modules","flutter","venv",".git"]):
                continue
            t=f.read_text(errors="replace")[:300]
            if len(t)>40:
                corpus.append({"file":str(f).replace(H,"~"),"lang":ext[2:],"code":t})
        except: pass
open(H+"/nlp2code_corpus/index.json","w").write(json.dumps({"total":len(corpus),"entries":corpus[:1000]},indent=2))
print("[NLP2CODE] Corpus: "+str(len(corpus))+" files")
PYEND

# 7 Status
echo "" >> $H/agent_logs/BOOT.log
echo BOOT COMPLETE $(date) >> $H/agent_logs/BOOT.log
curl -s http://127.0.0.1:3000/health
ollama list 2>/dev/null
echo KORE8TIVE AI @ KRE8TIVE.SPACE
