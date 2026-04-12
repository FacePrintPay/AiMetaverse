#!/usr/bin/env bash
set -euo pipefail

echo "[FORGE] Initializing Pathos Agent Memory System"

# Step 1: Install Dependencies
echo "[FORGE] Installing packages and Python libraries"
pkg update -y
pkg install -y python git
pip install --upgrade pip
pip install chromadb openai datasets transformers

# Step 2: Directory Structure
echo "[FORGE] Creating directory layout"
mkdir -p scripts feeds chroma_db agents

# Step 3: Agent Config Templates
echo "[FORGE] Creating agent configuration files"

cat > agents/mercury.cfg << 'EOCFG'
[agent]
name = "Mercury"
role = "Logic"
memory = "../chroma_db"
EOCFG

cat > agents/luna.cfg << 'EOCFG'
[agent]
name = "Luna"
role = "Emotion"
memory = "../chroma_db"
EOCFG

cat > agents/chronos.cfg << 'EOCFG'
[agent]
name = "Chronos"
role = "Context"
memory = "../chroma_db"
EOCFG

# Step 4: Dataset Decode Script
echo "[FORGE] Creating dataset decode script"

cat > scripts/download_and_decode.py << 'EOS'
import datasets
from transformers import AutoTokenizer

print("[DECODE] Loading DeepSeek dataset")
ds = datasets.load_dataset("justintang412/DeepSeek-R1-Distill-Llama-8B-lmsys-chat-1m-tokenized")
tok = AutoTokenizer.from_pretrained("meta-llama/Llama-2-7b-hf")

with open("feeds/reasoning_text.jsonl", "w", encoding="utf-8") as f:
    for row in ds["train"]:
        try:
            text = tok.decode(row["input_ids"], skip_special_tokens=True)
            f.write(text.replace("\n", " ") + "\n")
        except:
            continue

print("[DECODE] Output saved to feeds/reasoning_text.jsonl")
EOS

# Step 5: Chroma DB Build
echo "[FORGE] Creating Chroma DB builder"

cat > scripts/build_chroma_db.py << 'EOS'
import chromadb

print("[DB] Initializing Chroma vector database")
db = chromadb.PersistentClient(path="chroma_db")
collection = db.get_or_create_collection("agent_memory")

with open("feeds/reasoning_text.jsonl", "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        collection.add(documents=[line], ids=[f"mem_{i}"])

print("[DB] Chroma database ready")
EOS

# Step 6: Agent Brain Query Interface
echo "[FORGE] Creating agent_brain interface"

cat > agent_brain.sh << 'EOSH'
#!/usr/bin/env bash
QUERY="$*"
python3 - << 'EOF'
import chromadb, sys, os
import openai

query = sys.argv[1]
db = chromadb.PersistentClient(path="chroma_db")
collection = db.get_collection("agent_memory")

results = collection.query(query_texts=[query], n_results=5)
context = "\n".join(results["documents"][0])

openai.api_key = os.getenv("OPENAI_API_KEY")
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are an AI agent with external memory access."},
        {"role": "user", "content": f"Memory Context:\\n{context}\\n\\nQuery:\\n{query}"}
    ]
)
print(response.choices[0].message.content)
