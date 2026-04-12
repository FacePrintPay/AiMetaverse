#!/usr/bin/env python3
"""
PR.Ai Interactive Publisher
Usage: python3 pr_publish.py [options]
"""

import argparse
import sys
from pathlib import Path
from datetime import datetime
import time
import json
import logging

logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger("PR.Ai")

# Import from standalone version
from pr_agent_standalone import publish_post, Analytics

def interactive_publish():
    """Interactive mode for creating posts"""
    print("\n📝 PR.Ai Interactive Publisher")
    print("=" * 50)
    
    title = input("\n📌 Title: ").strip()
    if not title:
        print("❌ Title required!")
        return
    
    print("\n📄 Content (press Ctrl+D when done, Ctrl+C to cancel):")
    lines = []
    try:
        while True:
            line = input()
            lines.append(line)
    except EOFError:
        pass
    except KeyboardInterrupt:
        print("\n❌ Cancelled")
        return
    
    content = "\n".join(lines).strip()
    if not content:
        print("❌ Content required!")
        return
    
    tags_input = input("\n🏷️  Tags (comma-separated): ").strip()
    tags = [t.strip() for t in tags_input.split(",") if t.strip()]
    
    template = input("\n🎨 Template (standard/announcement, default=standard): ").strip() or "standard"
    
    source = input("\n📍 Source (optional): ").strip() or "CLI"
    summary = input("📋 Summary (optional): ").strip()
    
    metadata = {"source": source}
    if summary:
        metadata["summary"] = summary
    
    print("\n⏳ Publishing...")
    try:
        filepath = publish_post(title, content, tags, template, metadata)
        print(f"\n✅ Published successfully!")
        print(f"📁 File: {filepath}")
    except Exception as e:
        print(f"\n❌ Error: {e}")

def quick_publish(title, content, tags):
    """Quick publish with minimal options"""
    try:
        filepath = publish_post(title, content, tags)
        print(f"✅ Published: {filepath}")
    except Exception as e:
        print(f"❌ Error: {e}")

def show_analytics():
    """Display analytics summary"""
    base_dir = Path.home() / "logs" / "PR.Ai"
    analytics = Analytics(base_dir / "analytics")
    summary = analytics.get_summary()
    
    print("\n📊 PR.Ai Analytics")
    print("=" * 50)
    print(f"📈 Total Posts: {summary['total_posts']}")
    print(f"❌ Failures: {summary['failures']}")
    print(f"✅ Success Rate: {summary['success_rate']:.1%}")
    print(f"\n🌐 By Platform:")
    for platform, count in summary['by_platform'].items():
        print(f"   • {platform}: {count}")
    
    if summary['top_tags']:
        print(f"\n🏷️  Top Tags:")
        for tag, count in summary['top_tags']:
            print(f"   • {tag}: {count}")
    print()

def list_posts():
    """List all published posts"""
    pub_dir = Path.home() / "logs" / "PR.Ai" / "published"
    if not pub_dir.exists():
        print("📂 No posts yet")
        return
    
    posts = sorted(pub_dir.glob("publish_*.md"))
    
    print(f"\n📚 Published Posts ({len(posts)})")
    print("=" * 50)
    
    for post in posts[-10:]:  # Show last 10
        with open(post, 'r') as f:
            first_line = f.readline().strip()
            title = first_line.replace('# ', '')
        
        timestamp = int(post.stem.split('_')[1])
        date = datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M')
        
        print(f"{date} | {title}")
        print(f"   📁 {post.name}")
    
    if len(posts) > 10:
        print(f"\n... and {len(posts) - 10} more")
    print()

def main():
    parser = argparse.ArgumentParser(
        description="PR.Ai - Publish content to multiple platforms",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 pr_publish.py                          # Interactive mode
  python3 pr_publish.py --quick "Title" "Content" "tag1,tag2"
  python3 pr_publish.py --analytics             # View stats
  python3 pr_publish.py --list                  # List posts
        """
    )
    
    parser.add_argument('-q', '--quick', nargs=3, metavar=('TITLE', 'CONTENT', 'TAGS'),
                       help='Quick publish: title content tags')
    parser.add_argument('-a', '--analytics', action='store_true',
                       help='Show analytics')
    parser.add_argument('-l', '--list', action='store_true',
                       help='List published posts')
    
    args = parser.parse_args()
    
    if args.analytics:
        show_analytics()
    elif args.list:
        list_posts()
    elif args.quick:
        title, content, tags_str = args.quick
        tags = [t.strip() for t in tags_str.split(',')]
        quick_publish(title, content, tags)
    else:
        interactive_publish()

if __name__ == "__main__":
    main()
