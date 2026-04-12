from typing import Dict, Any

def generate_code(description: str, language: str = "python") -> Dict[str, Any]:
    templates = {
        "python": f'def generated():\n    """{description}"""\n    pass\n',
        "bash": f'#!/bin/bash\n# {description}\n',
        "javascript": f'// {description}\nfunction generated() {{\n}}\n'
    }
    return {
        "description": description,
        "language": language,
        "code": templates.get(language, f"# {description}"),
        "note": "Basic template. Integrate Claude API for AI generation."
    }
