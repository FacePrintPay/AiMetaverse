"""Mock AgentBus for testing PR.Ai agent"""

class Message:
    def __init__(self, task, payload):
        self.task = task
        self.payload = payload

class AgentBus:
    def __init__(self):
        self.messages = []
    
    def listen(self, channel):
        # Returns None - replace with actual message queue in production
        return None
    
    def respond(self, channel, message, response):
        print(f"[AgentBus] Response on {channel}: {response}")
