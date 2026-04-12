# REPO: c25-agent-deploy | FILE: ai_metaverse/assistants/__init__.py | CONSTELLATION25

"""
AI Metaverse Assistants package containing specialized AI assistants for various tasks
"""

from .earth import EarthAssistant
from .moon import MoonAssistant
from .sun import SunAssistant

__all__ = ['EarthAssistant', 'MoonAssistant', 'SunAssistant']