from pathlib import Path
import re
from datetime import datetime

ROOT = Path(__file__).resolve().parents[1]
POSTS_DIR = ROOT / "posts"
INDEX_FILE = ROOT / "index.html"


def parse_frontmatter(content: str):
    """Parse simple YAML-like frontmatter at the top of a markdown file.
    Expected keys: title, date, tags (comma-separated).
    Returns dict and the remaining body content.
    """
    lines = content.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, content

    fm_lines = []
    i = 1
    while i < len(lines) and lines[i].strip() != "---":
        fm_lines.append(lines[i])
        i += 1
    # Skip closing ---
    i += 1
    body = "\n".join(lines[i:])

    fm = {}
    for line in fm_lines:
        m = re.match(r"^(\w+):\s*(.*)$", line.strip())
        if m:
            key, val = m.group(1).lower(), m.group(2).strip()
            fm[key] = val
    # Normalize tags into list
    if "tags" in fm and isinstance(fm["tags"], str):
        fm["tags"] = [t.strip() for t in fm["tags"].split(",") if t.strip()]
    return fm, body


def extract_excerpt(body: str) -> str:
    """Extract the first paragraph-like excerpt from markdown body."""
    # Remove leading headings and blank lines
    lines = [ln.strip() for ln in body.splitlines()]
    filtered = []
    for ln in lines:
        if not ln:
            if filtered:
                break
            else:
                continue
        # skip headings, lists, blockquotes, code fences
        if ln.startswith(("#", "- ", "* ", ">", "```")):
            if not filtered:
                continue
        filtered.append(ln)
    excerpt = " ".join(filtered) if filtered else ""
    # Trim to a reasonable length
    if len(excerpt) > 300:
        excerpt = excerpt[:297].rsplit(" ", 1)[0] + "..."
    return excerpt


def parse_date(date_str: str) -> datetime:
    # Expected format: "December 26, 2025"
    try:
        return datetime.strptime(date_str, "%B %d, %Y")
    except Exception:
        # Fallback: try ISO-like
        for fmt in ("%Y-%m-%d", "%d %B %Y"):
            try:
                return datetime.strptime(date_str, fmt)
            except Exception:
                continue
    # If all fails, use epoch
    return datetime.fromtimestamp(0)


def collect_posts():
    posts = []
    for md in sorted(POSTS_DIR.glob("*.md")):
        if md.name.lower() == "post-template.md":
            continue
        content = md.read_text(encoding="utf-8")
        fm, body = parse_frontmatter(content)
        title = fm.get("title", md.stem.replace("-", " ").title())
        date_str = fm.get("date", "1970-01-01")
        tags = fm.get("tags", [])
        date = parse_date(date_str)
        excerpt = extract_excerpt(body)
        posts.append(
            {
                "file": md.name,
                "title": title,
                "date_str": date_str,
                "date": date,
                "tags": tags,
                "excerpt": excerpt,
            }
        )
    # Sort descending by date
    posts.sort(key=lambda p: p["date"], reverse=True)
    return posts


def render_article(post: dict) -> str:
    tags_html = "\n".join(f"                <span class=\"tag\">{t}</span>" for t in post["tags"]) if post["tags"] else ""
    excerpt_html = post["excerpt"] or ""
    return (
        "        <article class=\"blog-post\">\n"
        f"            <h2><a href=\"posts/post.html?post={post['file']}\">{post['title']}</a></h2>\n"
        f"            <p class=\"post-meta\">{post['date_str']}</p>\n"
        "            <div class=\"post-tags\">\n"
        f"{tags_html}\n"
        "            </div>\n"
        f"            <p>{excerpt_html}</p>\n"
        f"            <a href=\"posts/post.html?post={post['file']}\" class=\"read-more\">Read more →</a>\n"
        "        </article>\n"
    )


def update_index(latest_posts):
    html = INDEX_FILE.read_text(encoding="utf-8")
    start = html.find("<main>")
    end = html.find("</main>")
    if start == -1 or end == -1:
        raise RuntimeError("Could not locate <main> section in index.html")

    articles = "".join(render_article(p) for p in latest_posts)
    new_main = "<main>\n" + articles + "    </main>"

    updated = html[:start] + new_main + html[end + len("</main>") :]
    if updated != html:
        INDEX_FILE.write_text(updated, encoding="utf-8")
        return True
    return False


def main():
    posts = collect_posts()
    latest_three = posts[:3]
    changed = update_index(latest_three)
    print(f"Updated index.html: {'yes' if changed else 'no changes'}")


if __name__ == "__main__":
    main()
