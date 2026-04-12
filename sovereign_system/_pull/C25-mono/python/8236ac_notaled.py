import json
import os
from datetime import datetime
from typing import Dict, Any, List

NOTES_DIR = os.path.expanduser("~/PaTHos/data/notes")

def create_note(title: str, content: str, tags: str = "") -> Dict[str, Any]:
    os.makedirs(NOTES_DIR, exist_ok=True)
    note_id = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    note = {
        "id": note_id,
        "title": title,
        "content": content,
        "tags": tags.split(",") if tags else [],
        "created": datetime.utcnow().isoformat()
    }
    with open(os.path.join(NOTES_DIR, f"{note_id}.json"), 'w') as f:
        json.dump(note, f, indent=2)
    return {"status": "success", "note": note}

def list_notes() -> Dict[str, Any]:
    if not os.path.exists(NOTES_DIR):
        return {"total": 0, "notes": []}
    notes = []
    for f in os.listdir(NOTES_DIR):
        if f.endswith('.json'):
            with open(os.path.join(NOTES_DIR, f)) as file:
                notes.append(json.load(file))
    return {"total": len(notes), "notes": sorted(notes, key=lambda x: x["created"], reverse=True)}

def search_notes(query: str) -> Dict[str, Any]:
    all_notes = list_notes()["notes"]
    results = [n for n in all_notes if query.lower() in n["title"].lower() or query.lower() in n["content"].lower()]
    return {"total": len(results), "notes": results}
