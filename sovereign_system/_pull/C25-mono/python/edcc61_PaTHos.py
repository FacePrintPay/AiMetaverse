from typing import List, Dict
def Cygnus(data: List[Dict], threshold: float, key: str = "value") -> List[Dict]:
    return [d for d in data if d.get(key, 0) >= threshold]

sample_data = [
    {"value": 1.2, "label": "A"},
    {"value": 2.5, "label": "B"},
    {"value": 0.8, "label": "C"},
    {"value": 3.1, "label": "D"}
]
filtered = Cygnus(sample_data, 2.0)
print("=== PaTHos Framework Started ===")
print(f"Filtered data: {filtered}")
print("=== PaTHos Framework Completed Successfully ===")
