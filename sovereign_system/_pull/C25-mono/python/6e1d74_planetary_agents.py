import asyncio
import subprocess
import os
from datetime import datetime

async def scaffold_to_agents(task):
    """Scaffold tasks to planetary agents"""
    task_desc = task.get('description', 'unknown task')
    
    # Simulate agent processing
    await asyncio.sleep(0.3)
    
    # Check if it's a voice task
    is_voice = task.get('type') == 'voice_task'
    
    return {
        "output": f"Processed via {'voice' if is_voice else 'text'}: {task_desc}",
        "success": True,
        "agent_response": f"Task completed: {task_desc}",
        "timestamp": datetime.now().isoformat(),
        "is_voice": is_voice
    }
