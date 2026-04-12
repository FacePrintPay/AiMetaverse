import requests
import time
import os

# === REPLACE THIS WITH YOUR REAL PAWNS.APP SESSION COOKIE ===
PAWNS_SESSION = "your_pawns_session_cookie_here"

headers = {
    "User-Agent": "Mozilla/5.0 (Linux; Android 10; Mobile)",
    "Cookie": f"session={PAWNS_SESSION}",
    "Accept": "application/json"
}

def get_available_tasks():
    try:
        r = requests.get("https://pawns.app/api/v1/tasks/available", headers=headers, timeout=10)
        if r.status_code == 200:
            return r.json().get("tasks", [])
        else:
            print(f"⚠ API Error: {r.status_code}")
            return []
    except Exception as e:
        print(f"❌ Fetch failed: {e}")
        return []

def claim_task(task_id):
    try:
        url = f"https://pawns.app/api/v1/tasks/{task_id}/claim"
        r = requests.post(url, headers=headers, timeout=10)
        return r.status_code == 200
    except Exception as e:
        print(f"❌ Claim failed: {e}")
        return False

def log_earnings(amount):
    log_path = "/data/data/com.termux/files/home/agentik/earnings.log"
    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    with open(log_path, "a") as f:
        f.write(f"{time.time()},{amount}\n")

if __name__ == "__main__":
    print("🤖 Pawns.app Agent Activated")
    while True:
        tasks = get_available_tasks()
        if tasks:
            print(f"📥 Found {len(tasks)} tasks")
            for task in tasks[:3]:
                if claim_task(task['id']):
                    print(f"✅ Claimed: {task['title']} → ${task['reward']}")
                    log_earnings(float(task['reward']))
                    time.sleep(5)
                else:
                    print(f"❌ Failed to claim {task['id']}")
        else:
            print("🔍 No tasks available — sleeping 60s")
        time.sleep(60)
