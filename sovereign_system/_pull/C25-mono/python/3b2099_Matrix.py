import asyncio

class MatrixAgent:
    def __init__(self):
        self.name = "Matrix"
        self.status = "online"
        self.mission_directive = "Execute mission protocol for Matrix"
        self.tasks = [
            "diagnostics",
            "report_status",
            "sync_with_matrix",
            "maintain_link",
            "mission_protocol",
            "run_self_check",
            "execute_payload",
            "initiate_handshake",
            "transmit_telemetry",
            "log_activity"
        ]

        if self.name == "Earth":
            self.tasks += ["environmental_monitoring", "human_activity_sync", "geodata_analysis"]
        elif self.name == "Mars":
            self.tasks += ["mission_base_setup", "habitat_check", "resource_scan"]
        elif self.name == "Luna":
            self.tasks += ["lunar_surface_monitor", "supply_depot_check"]
        elif self.name == "Matrix":
            self.tasks += ["orchestrate_agents", "validate_comms", "command_broadcast"]
        elif self.name == "Recon":
            self.tasks += ["patrol_routes", "threat_assessment", "data_exfiltration"]

    async def execute_task(self, task):
        print(f"🔧 {self.name} executing task: {task}")
        await asyncio.sleep(0.5)
        print(f"✅ {self.name} completed task: {task}")

    async def run(self):
        print(f"🛰️ {self.name} Agent online with directive: {self.mission_directive}")
        for task in self.tasks:
            await self.execute_task(task)
        print(f"🚀 {self.name} Agent mission cycle complete")

if __name__ == "__main__":
    agent = MatrixAgent()
    asyncio.run(agent.run())
