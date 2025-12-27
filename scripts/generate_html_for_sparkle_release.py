#!/usr/bin/env python3
"""
Converts Release_Notes.md bullet points to HTML for Sparkle release notes.
"""

import markdown

def main():
    with open('title', 'r') as f:
        title = f.read().strip()

    with open('latest_changes', 'r') as f:
        changes = f.read().strip()

    # Create markdown content
    md_content = f"# {title}\n\n{changes}"

    # Convert to HTML
    html = markdown.markdown(md_content)

    # Wrap in basic HTML structure
    full_html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{title}</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            padding: 20px;
            max-width: 600px;
            margin: 0 auto;
            color: #333;
        }}
        h1 {{
            font-size: 1.5em;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }}
        ul {{
            padding-left: 20px;
        }}
        li {{
            margin: 8px 0;
        }}
    </style>
</head>
<body>
{html}
</body>
</html>
"""

    with open('latest_changes.html', 'w') as f:
        f.write(full_html)

    print(f"Generated HTML for: {title}")

if __name__ == '__main__':
    main()
