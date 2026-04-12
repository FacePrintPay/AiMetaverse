#!/usr/bin/env python3
import argparse, json, time, datetime, subprocess, textwrap, os, sys

AGENT_MATRIX = [
    {"name": "agent_valuation", "domain": "valuation / decks"},
    {"name": "agent_roi", "domain": "ROI / county economics"},
    {"name": "agent_compliance", "domain": "compliance / SOC2 / evidentiary"},
    {"name": "agent_outreach", "domain": "pitch / landing pages / outreach"},
    {"name": "agent_performance", "domain": "KPIs / metrics"},
    {"name": "agent_governance", "domain": "risk / policy / approvals"}
    # … add the rest of your 25 as needed
]

def call_local_llm(prompt: str) -> str:
    """
    Plug this into your llama.cpp / local runner.
    For now, this is just a placeholder shell call.
    """
    # Example: llama.cpp CLI
    # result = subprocess.run(
    #     ["~/llama.cpp/main", "-m", "~/models/your.gguf", "-p", prompt],
    #     capture_output=True, text=True
    # )
    # return result.stdout

    # Placeholder: echo prompt back so we at least write something
    return f"PLANNER_PLACEHOLDER_OUTPUT:\n{prompt}"

def build_planning_prompt(profile, goal: str) -> str:
    agents_str = "\n".join(
        f"- {a['name']}: {a['domain']}" for a in AGENT_MATRIX
    )
    return textwrap.dedent(f"""
    You are a sovereign pipeline architect running on-device.
    You must ONLY plan actions that operate inside the user's own infrastructure
    (Termux, local agents, Banani exports, Cloudflare R2, Total Recall, etc.).
    You must NOT suggest or depend on any illegal activity or unauthorized access.

    Profile:
    {json.dumps(profile, indent=2)}

    Available agents:
    {agents_str}

    GOAL:
    "{goal}"

    TASK:
    1. Decompose the goal into 3–10 ordered steps.
    2. For each step, assign the best agent name from the list.
    3. For each step, specify:
       - id: step-1, step-2, ...
       - title: short name
       - description: what the agent should do
       - agent: agent_* name
       - dependencies: list of step IDs that must be completed first
    4. Return ONLY valid JSON with shape:
       {{
         "steps": [{{...}}]
       }}
    """)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", required=True)
    ap.add_argument("--goal", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    with open(args.profile) as f:
        profile = json.load(f)

    prompt = build_planning_prompt(profile, args.goal)
    raw = call_local_llm(prompt)

    # Here in production you'd parse raw as JSON.
    # For now, if model isn't wired, stub 3 generic steps.
    try:
        data = json.loads(raw)
        steps = data.get("steps", [])
    except Exception:
        steps = [
            {
                "id": "step-1",
                "title": "Draft valuation narrative",
                "description": "Generate a $10M Series A valuation thesis.",
                "agent": "agent_valuation",
                "dependencies": []
            },
            {
                "id": "step-2",
                "title": "Build ROI model",
                "description": "Create 3-year county ROI model for VideoCourts pilot.",
                "agent": "agent_roi",
                "dependencies": ["step-1"]
            },
            {
                "id": "step-3",
                "title": "Draft outreach deck skeleton",
                "description": "Create outreach copy for counties and investors.",
                "agent": "agent_outreach",
                "dependencies": ["step-1", "step-2"]
            }
        ]

    plan = {
        "plan_id": os.path.basename(args.out).replace(".json", ""),
        "goal": args.goal,
        "created_at": datetime.datetime.utcnow().isoformat() + "Z",
        "status": "pending",
        "steps": [
            {
                "id": s["id"],
                "title": s["title"],
                "description": s["description"],
                "agent": s["agent"],
                "inputs": {
                    "source": "goal_and_context",
                    "params": {}
                },
                "dependencies": s.get("dependencies", []),
                "outputs": {
                    "task_id": None,
                    "output_file": None
                },
                "status": "pending",
                "notes": []
            }
            for s in steps
        ]
    }

    with open(args.out, "w") as f:
        json.dump(plan, f, indent=2)

if __name__ == "__main__":
    main()
