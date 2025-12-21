#!/usr/bin/env python3
"""
Extracts the latest version info from Release_Notes.md

Expected format:
# 1.1.0 - New Feature Title
* First change
* Second change

# 1.0.0 - Initial Release
* Initial features
"""

def main():
    with open('Release_Notes.md', 'r') as f:
        lines = f.readlines()

    if not lines:
        print("Release_Notes.md is empty")
        exit(1)

    # Parse first header: # 1.1.0 - Title
    first_header = lines[0].strip()
    if not first_header.startswith('# '):
        print("First line must be a header starting with '# '")
        exit(1)

    # Split "# 1.1.0 - Title" into version and title
    header_content = first_header[2:]  # Remove "# "
    if ' - ' in header_content:
        new_version, title = header_content.split(' - ', 1)
    else:
        new_version = header_content
        title = f"Version {new_version}"

    # Extract bullet points until next header
    latest_changes = ""
    old_version = ""

    for line in lines[1:]:
        line = line.strip()
        if line.startswith('* ') or line.startswith('- '):
            latest_changes += line + "\n"
        elif line.startswith('# '):
            # Found next version header
            header_content = line[2:]
            if ' - ' in header_content:
                old_version = header_content.split(' - ', 1)[0]
            else:
                old_version = header_content
            break

    # Write outputs to files
    with open('new_version', 'w') as f:
        f.write(new_version.strip())

    with open('old_version', 'w') as f:
        f.write(old_version.strip())

    with open('title', 'w') as f:
        f.write(title.strip())

    with open('latest_changes', 'w') as f:
        f.write(latest_changes.strip())

    print(f"New version: {new_version}")
    print(f"Old version: {old_version}")
    print(f"Title: {title}")
    print(f"Changes:\n{latest_changes}")

if __name__ == '__main__':
    main()
