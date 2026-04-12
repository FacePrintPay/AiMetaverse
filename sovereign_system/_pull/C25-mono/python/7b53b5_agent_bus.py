from pathlib import Path
import json

class AgentBus:
    def __init__(self):
        self.msg_dir = Path.home() / "logs" / "agents"
        self.msg_dir.mkdir(parents=True, exist_ok=True)
        self.agents = [
            "Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune",
            "Pluto","Luna","Sun","Ceres","Haumea","Makemake","Eris",
            "Io","Europa","Ganymede","Callisto","Titan","Enceladus","Triton","Charon","Phobos","Deimos"
        ]

    def list_agents(self):
        return self.agents

    def post_message(self, sender, task_type, message, target=None):
        target = target or "broadcast"
        entry = {"from": sender, "type": task_type, "message": message}
        with open(self.msg_dir / f"{target}.log", "a") as f:
            f.write(json.dumps(entry) + "\n")
        print(f"[BUS] {sender} → {target}: {message}")
