#!/usr/bin/env python3
"""Planetary Agents Module"""

statuses = {
    "mars": {"status": "idle", "role": "scraper"},
    "venus": {"status": "idle", "role": "researcher"},
    "mercury": {"status": "idle", "role": "strategist"},
    "saturn": {"status": "idle", "role": "security"},
    "pluto": {"status": "idle", "role": "legal"},
    "earth": {"status": "idle", "role": "infrastructure"}
}

def get_agent_status(agent):
    """Get status of specific agent"""
    return statuses.get(agent, {"status": "unknown"})

def update_agent_status(agent, status):
    """Update agent status"""
    if agent in statuses:
        statuses[agent]["status"] = status
        return True
    return False
