#!/usr/bin/env python3
import asyncio
import json
import os
from aiohttp import web
import socketio

from taskmanager import TaskManager
from planetary_agents import scaffold_to_agents

# Initialize Socket.IO server
sio = socketio.AsyncServer(
    async_mode='aiohttp',
    cors_allowed_origins='*',
    logger=False,
    engineio_logger=False
)
app = web.Application()
sio.attach(app)

# Initialize TaskManager
tm = TaskManager()

# Static files directory
STATIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "static")

async def index(request):
    """Serve the main HTML page"""
    html_path = os.path.join(STATIC_DIR, "index.html")
    with open(html_path, 'r') as f:
        return web.Response(text=f.read(), content_type='text/html')

@sio.event
async def connect(sid, environ):
    print(f"🔌 Client connected: {sid}")
    await sio.emit('status', {
        'message': 'Connected to AvaTasker!',
        'stats': tm.get_stats()
    }, room=sid)

@sio.event
async def disconnect(sid):
    print(f"🔌 Client disconnected: {sid}")

@sio.event
async def task(sid, data):
    """Handle incoming task from client"""
    task_desc = data.get('description', 'N/A')
    task_type = data.get('type', 'user_task')
    
    print(f"📥 [{task_type}] from {sid}: {task_desc}")
    
    try:
        # Scaffold to planetary agents
        result = await scaffold_to_agents(data)
        
        # Process via TaskManager
        task_record = tm.process_task(task_type, result)
        
        # Send response back to client
        response = {
            'status': 'complete',
            'result': result,
            'avatar_msg': result['agent_response'],
            'task_id': task_record['id'],
            'stats': tm.get_stats()
        }
        
        await sio.emit('task_complete', response, room=sid)
        
    except Exception as e:
        print(f"❌ Error processing task: {e}")
        await sio.emit('task_error', {'error': str(e)}, room=sid)

# Routes
app.router.add_get('/', index)
app.router.add_static('/static', STATIC_DIR)

@app.get('/health')
async def health(request):
    return web.json_response({
        'status': 'healthy',
        'stats': tm.get_stats()
    })

if __name__ == '__main__':
    print("=" * 70)
    print("🎤 AvaTasker MVP - Voice-Enabled Edition")
    print("=" * 70)
    print("🌐 Server: http://localhost:8000")
    print("🔌 Socket.IO: Active")
    print("🎙️  Voice Recognition: Browser-based (Chrome/Edge recommended)")
    print("=" * 70)
    print()
    web.run_app(app, host='0.0.0.0', port=8000, print=None)
