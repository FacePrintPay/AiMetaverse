import subprocess
from typing import Dict, Any

def git_status(repo_path: str = ".") -> Dict[str, Any]:
    try:
        result = subprocess.run(
            ["git", "status", "--short"],
            cwd=repo_path,
            capture_output=True,
            text=True,
            check=True
        )
        return {"status": "success", "changes": result.stdout}
    except Exception as e:
        return {"error": str(e)}

def git_push(repo_path: str = ".", message: str = "Auto-commit") -> Dict[str, Any]:
    try:
        subprocess.run(["git", "add", "."], cwd=repo_path, check=True)
        subprocess.run(["git", "commit", "-m", message], cwd=repo_path)
        subprocess.run(["git", "push"], cwd=repo_path, check=True)
        return {"status": "success", "message": "Pushed successfully"}
    except Exception as e:
        return {"error": str(e)}
