import json
import os
import hashlib
from datetime import datetime

DATA_DIR = os.path.expanduser("~/planetary_agents/data")
os.makedirs(DATA_DIR, exist_ok=True)

# Extended API discovery with more metadata
api_list = [
    {"name": "WeatherAPI", "url": "https://api.weather.com/v1", "version": "1.0", 
     "auth": "api_key", "rate_limit": "1000/hour"},
    {"name": "GeoLocationAPI", "url": "https://api.geolocation.com/v2", "version": "2.1",
     "auth": "oauth2", "rate_limit": "5000/hour"},
    {"name": "CryptoDataAPI", "url": "https://api.crypto.com/v1", "version": "1.5",
     "auth": "api_key", "rate_limit": "2000/hour"},
    {"name": "AIModelAPI", "url": "https://api.aimodels.com/v3", "version": "3.0",
     "auth": "bearer", "rate_limit": "500/hour"},
]

def generate_checksum(data):
    """Generate SHA256 checksum for data integrity"""
    data_str = json.dumps(data, sort_keys=True)
    return hashlib.sha256(data_str.encode()).hexdigest()

def save_to_json(data, filename):
    filepath = os.path.join(DATA_DIR, filename)
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)
    return filepath

# Extract and store metadata with enhanced fields
metadata_collection = []
for api in api_list:
    metadata = {
        "id": generate_checksum({"name": api["name"], "url": api["url"]})[:12],
        "name": api["name"],
        "url": api["url"],
        "version": api["version"],
        "auth_type": api.get("auth", "none"),
        "rate_limit": api.get("rate_limit", "unlimited"),
        "extracted_at": datetime.now().isoformat(),
        "status": "active",
        "health": "unknown",
        "last_checked": None
    }
    metadata_collection.append(metadata)
    print(f"[✓] Extracted: {api['name']} (ID: {metadata['id']}) @ {api['url']}")

# Add checksum for integrity verification
output = {
    "metadata": metadata_collection,
    "count": len(metadata_collection),
    "checksum": generate_checksum(metadata_collection),
    "created_at": datetime.now().isoformat()
}

filepath = save_to_json(output, "api_metadata.json")
print(f"[✓] Metadata saved to: {filepath}")
print(f"[✓] Checksum: {output['checksum'][:16]}...")
