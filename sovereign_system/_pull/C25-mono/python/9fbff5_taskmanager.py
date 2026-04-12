from datetime import datetime

class TaskManager:
    def __init__(self):
        self.tasks = []
        self.counter = 0
    
    def process_task(self, task_type, data):
        self.counter += 1
        task = {
            "id": self.counter,
            "type": task_type,
            "data": data,
            "status": "processed",
            "timestamp": datetime.now().isoformat()
        }
        self.tasks.append(task)
        print(f"✓ Task #{self.counter} [{task_type}]: {data.get('agent_response', 'N/A')}")
        return task
    
    def get_tasks(self):
        return self.tasks
    
    def get_stats(self):
        voice_tasks = sum(1 for t in self.tasks if t['type'] == 'voice_task')
        text_tasks = sum(1 for t in self.tasks if t['type'] == 'user_task')
        return {
            "total": len(self.tasks),
            "voice": voice_tasks,
            "text": text_tasks
        }
