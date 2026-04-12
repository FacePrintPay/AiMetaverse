# core/router.py
import importlib
import pkgutil
from datetime import datetime
import os

# Build registry of planetary agents
REGISTRY = {}

# Auto-discover all modules inside ~/PaTHos/planets
PLANETS_PATH = os.path.join(os.path.expanduser("~"), "PaTHos", "planets")
for _, modname, _ in pkgutil.iter_modules([PLANETS_PATH], "planets."):
    try:
        REGISTRY[modname.split(".")[-1]] = modname
    except Exception as e:
        print(f"[Router] Error loading {modname}: {e}")

def dispatch(func_name: str, payload: dict):
    """Route a request to the appropriate planetary agent."""
    if func_name not in REGISTRY:
        raise ValueError(f"Unknown function: {func_name}")
    mod = importlib.import_module(REGISTRY[func_name])
    if not hasattr(mod, "run"):
        raise AttributeError(f"Agent {func_name} missing run() function")
    return mod.run(payload)
