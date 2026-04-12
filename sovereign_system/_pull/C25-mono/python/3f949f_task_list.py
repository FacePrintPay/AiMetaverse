import json
import os
from datetime import datetime
from typing import List, Dict, Any, Optional

TASKS_FILE = os.path.expanduser("~/PaTHos/data/tasks.json")

def load_tasks() -> List[Dict[str, Any]]:
    if os.path.exists(TASKS_FILE):
        with open(TASKS_FILE, 'r') as f:
            return json.load(f)
    return []

def save_tasks(tasks: List[Dict[str, Any]]) -> None:
    os.makedirs(os.path.dirname(TASKS_FILE), exist_ok=True)
    with open(TASKS_FILE, 'w') as f:
        json.dump(tasks, f, indent=2)

def add_task(title: str, agent: str = "general", priority: str = "medium") -> Dict[str, Any]:
    tasks = load_tasks()
    task = {
        "id": len(tasks) + 1,
        "title": title,
        "agent": agent,
        "priority": priority,
        "status": "pending",
        "created": datetime.utcnow().isoformat()
    }
    tasks.append(task)
    save_tasks(tasks)
    return {"status": "success", "task": task}

def list_tasks(agent: Optional[str] = None) -> Dict[str, Any]:
    tasks = load_tasks()
    if agent:
        tasks = [t for t in tasks if t["agent"] == agent]
    return {"total": len(tasks), "tasks": tasks}

def complete_task(task_id: int) -> Dict[str, Any]:
    tasks = load_tasks()
    for task in tasks:
        if task["id"] == task_id:
            task["status"] = "completed"
            task["completed"] = datetime.utcnow().isoformat()
            save_tasks(tasks)
            return {"status": "success", "task": task}
    return {"error": "Task not found"}
