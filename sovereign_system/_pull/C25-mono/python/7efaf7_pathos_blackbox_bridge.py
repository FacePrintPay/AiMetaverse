from typing import List, Dict

def Cygnus(data: List[Dict], threshold: float) -> List[Dict]:
    """Filters data based on threshold."""
    return [d for d in data if d.get("value", 0) >= threshold]

def infer_with_pathos(texts: List[str], threshold: float = 0.5):
    """Simple mock inference to test the pipeline."""
    print("[MOCK] BlackboxAI initialized in bash-safe mode")
    predictions = []
    for t in texts:
        val = 0.8 if any(x in t.lower() for x in ["love", "great", "fantastic"]) else 0.3
        predictions.append({"text": t, "value": val})
    filtered = Cygnus(predictions, threshold)
    for res in filtered:
        sentiment = "Positive" if res["value"] > 0.5 else "Negative"
        print(f"{res['text']} → {sentiment} ({res['value']:.2f})")

if __name__ == "__main__":
    infer_with_pathos([
        "I love this product",
        "This is terrible",
        "Great job!",
        "I hate it",
        "Absolutely fantastic!"
    ])
