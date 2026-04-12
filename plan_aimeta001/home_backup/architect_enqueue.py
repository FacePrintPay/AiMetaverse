#!/usr/bin/env python3
import argparse, json, os, time, datetime, uuid

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--plan", required=True)
    ap.add_argument("--tasks-dir", required=True)
    args = ap.parse_args()

    with open(args.plan) as f:
        plan = json.load(f)

    os.makedirs(args.tasks_dir, exist_ok=True)
    now = datetime.datetime.utcnow().isoformat() + "Z"

    for step in plan["steps"]:
        if step["dependencies"]:
            # Let a later scheduler re-enqueue dependent steps.
            continue

        task_id = str(int(time.time() * 1e9))
        task_json = {
            "task_id": task_id,
            "plan_id": plan["plan_id"],
            "step_id": step["id"],
            "agent": step["agent"],
            "message": step["description"],
            "timestamp": now,
            "status": "pending",
            "meta": {
                "goal": plan["goal"],
                "origin": "sovereign_architect"
            }
        }

        out_path = os.path.join(args.tasks_dir, f"task_{task_id}.json")
        with open(out_path, "w") as f:
            json.dump(task_json, f, indent=2)

        print(f"📨 Enqueued {out_path} → {step['agent']}")

if __name__ == "__main__":
    main()
