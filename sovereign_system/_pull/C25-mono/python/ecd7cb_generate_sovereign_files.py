from datetime import datetime
from pathlib import Path

timestamp = datetime.utcnow().isoformat() + "Z"

tos_content = f"""# 📜 ARC.AI Terms of Service
Effective: {timestamp}
- Users agree to abide by creative sovereignty clauses.
- Unauthorized cloning, scraping, or replication is forbidden.
- Payments required for commercial or advanced usage.
- All AI output is protected by sovereign IP under ARC.AI Protocol 1.

This agreement is binding and digitally monitored via WhisperSync and VoiceLockAI.
"""

key_content = f"""# 🔐 Sovereign Fallback Key
Timestamp: {timestamp}
- Issued to: MrGGTP (Cygel White)
- Use Case: Backend Override, Court Filing, IP Validation
- Backup Method: Offline Vault + Hashprint
- Deployment Node: ARC.AI Stargate
"""

# Write directly to repo path
repo_path = Path.home() / "downloads" / "ARC.AI-Stargate"
(repo_path / "ARC.AI_TermsOfService.txt").write_text(tos_content)
(repo_path / "Sovereign_Fallback_Key.txt").write_text(key_content)
