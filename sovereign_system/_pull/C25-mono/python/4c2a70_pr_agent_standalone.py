"""
PR.Ai — Standalone Test Version
Simplified version that works without AgentBus for testing
"""

from pathlib import Path
from datetime import datetime
import time
import json
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("PR.Ai")


class TemplateEngine:
    """Markdown template system"""
    
    def __init__(self, template_dir: Path):
        self.template_dir = template_dir
        self.template_dir.mkdir(parents=True, exist_ok=True)
        self._create_default_templates()
    
    def _create_default_templates(self):
        templates = {
            "standard.md": """# {title}

**Published:** {timestamp}
**Platform:** {platform}
**Source:** {source}

---

{content}

---

**Tags:** {tags}
**Post ID:** {post_id}
""",
            "announcement.md": """# 🚀 {title}

> {summary}

**Date:** {timestamp}
**Platform:** {platform}

## Details

{content}

## Related Topics
{tags}

---
*Post ID: {post_id}*
"""
        }
        
        for name, content in templates.items():
            template_path = self.template_dir / name
            if not template_path.exists():
                with open(template_path, 'w') as f:
                    f.write(content)
    
    def render(self, template_name: str, **kwargs) -> str:
        template_path = self.template_dir / f"{template_name}.md"
        
        if not template_path.exists():
            template_path = self.template_dir / "standard.md"
        
        try:
            with open(template_path, 'r') as f:
                template = f.read()
            return template.format(**kwargs)
        except Exception as e:
            logger.error(f"Template rendering failed: {e}")
            return f"# {kwargs.get('title', 'Untitled')}\n\n{kwargs.get('content', '')}"


class Analytics:
    """Track publishing metrics"""
    
    def __init__(self, storage_path: Path):
        self.storage_path = storage_path
        self.storage_path.mkdir(parents=True, exist_ok=True)
        self.stats_file = self.storage_path / "analytics.json"
        self.stats = self._load_stats()
    
    def _load_stats(self):
        if self.stats_file.exists():
            try:
                with open(self.stats_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Failed to load analytics: {e}")
        
        return {
            "total_posts": 0,
            "by_platform": {},
            "by_tag": {},
            "failures": 0,
            "last_updated": None
        }
    
    def _save_stats(self):
        try:
            self.stats["last_updated"] = datetime.now().isoformat()
            with open(self.stats_file, 'w') as f:
                json.dump(self.stats, f, indent=2)
        except Exception as e:
            logger.error(f"Failed to save analytics: {e}")
    
    def record_success(self, platform: str, tags: list):
        self.stats["total_posts"] += 1
        self.stats["by_platform"][platform] = self.stats["by_platform"].get(platform, 0) + 1
        
        for tag in tags:
            self.stats["by_tag"][tag] = self.stats["by_tag"].get(tag, 0) + 1
        
        self._save_stats()
    
    def get_summary(self):
        total = self.stats["total_posts"] + self.stats["failures"]
        return {
            "total_posts": self.stats["total_posts"],
            "failures": self.stats["failures"],
            "success_rate": (self.stats["total_posts"] / total) if total > 0 else 0,
            "by_platform": self.stats["by_platform"],
            "top_tags": sorted(
                self.stats["by_tag"].items(),
                key=lambda x: x[1],
                reverse=True
            )[:10]
        }


def publish_post(title, content, tags, template="standard", metadata=None):
    """Publish a single post (standalone function)"""
    
    base_dir = Path.home() / "logs" / "PR.Ai"
    output_dir = base_dir / "published"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    template_engine = TemplateEngine(base_dir / "templates")
    analytics = Analytics(base_dir / "analytics")
    
    timestamp = int(time.time())
    filepath = output_dir / f"publish_{timestamp}.md"
    
    rendered_content = template_engine.render(
        template,
        title=title,
        content=content,
        tags=", ".join(tags),
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        platform="local",
        source=metadata.get("source", "Manual") if metadata else "Manual",
        post_id=f"local_{timestamp}",
        summary=metadata.get("summary", "") if metadata else ""
    )
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(rendered_content)
    
    analytics.record_success("local", tags)
    
    logger.info(f"✅ Published: {filepath}")
    return str(filepath)


def test_publish():
    """Run a test publication"""
    print("\n🚀 PR.Ai Test Publication")
    print("=" * 50)
    
    # Test 1: Standard post
    path1 = publish_post(
        title="Test Publication #1",
        content="This is a test post from the PR.Ai agent.\n\nIt demonstrates the publishing system working correctly.",
        tags=["test", "demo", "pr-agent"]
    )
    print(f"📝 Test 1 created: {path1}")
    
    # Test 2: Announcement style
    path2 = publish_post(
        title="New Feature Release",
        content="We're excited to announce the release of PR.Ai v2.0 with multi-platform support!",
        tags=["announcement", "release", "features"],
        template="announcement",
        metadata={
            "source": "PR.Ai System",
            "summary": "Major update with new capabilities"
        }
    )
    print(f"📝 Test 2 created: {path2}")
    
    # Show analytics
    base_dir = Path.home() / "logs" / "PR.Ai"
    analytics = Analytics(base_dir / "analytics")
    summary = analytics.get_summary()
    
    print("\n📊 Analytics Summary:")
    print(f"   Total posts: {summary['total_posts']}")
    print(f"   Success rate: {summary['success_rate']:.1%}")
    print(f"   By platform: {summary['by_platform']}")
    print(f"   Top tags: {dict(summary['top_tags'])}")
    
    print(f"\n✨ All files saved to: {base_dir}")
    print("\n" + "=" * 50)


if __name__ == "__main__":
    test_publish()
