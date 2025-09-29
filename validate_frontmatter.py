import os
import re
import yaml
import stat

CONTENT_DIR = "content"

FRONTMATTER_REGEX = re.compile(r"^---\s*\n(.*?)\n---", re.DOTALL)

IGNORE_DIRS = {".git", ".github", ".vscode", ".idea", ".obsidian", "node_modules"}

def is_ignored_file(name: str) -> bool:
    # Skip macOS AppleDouble sidecars, dotfiles, and common junk
    lname = name.lower()
    return (
        name.startswith("._") or
        name.startswith(".") or
        lname in {"thumbs.db", ".ds_store"}
    )

def safe_filename_to_title(filename: str) -> str:
    name = os.path.splitext(os.path.basename(filename))[0]
    title = name.replace("-", " ").replace("_", " ").strip()
    return title if title else "Untitled"

def read_file(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    except UnicodeDecodeError:
        with open(path, "r", encoding="latin-1") as f:
            return f.read()

def write_file(path, text):
    try:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
    except PermissionError:
        # Try to make file writable and retry
        try:
            os.chmod(path, os.stat(path).st_mode | stat.S_IWUSR)
            with open(path, "w", encoding="utf-8") as f:
                f.write(text)
        except Exception:
            raise

def validate_and_fix_frontmatter(path):
    text = read_file(path)
    match = FRONTMATTER_REGEX.match(text)

    if not match:
        title = safe_filename_to_title(path)
        new_text = f'---\ntitle: "{title}"\n---\n\n{text}'
        write_file(path, new_text)
        return f"Added frontmatter with title to: {path}"

    raw_yaml = match.group(1)
    try:
        parsed = yaml.safe_load(raw_yaml)
        if not isinstance(parsed, dict):
            return f"Invalid YAML dict in: {path}"

        changed = False
        if "title" not in parsed or not parsed.get("title"):
            parsed["title"] = safe_filename_to_title(path)
            changed = True

        if changed:
            new_yaml = yaml.dump(parsed, sort_keys=False, allow_unicode=True).strip()
            new_text = f"---\\n{new_yaml}\\n---\\n" + text[match.end():]
            write_file(path, new_text)
            return f"Fixed frontmatter in: {path}"
    except Exception as e:
        return f"YAML error in {path}: {e}"

    return None

def main():
    fixes = []
    for root, dirs, files in os.walk(CONTENT_DIR):
        # Skip hidden/ignored directories
        dirs[:] = [d for d in dirs if not (d.startswith(".") or d in IGNORE_DIRS)]
        for file in files:
            if is_ignored_file(file):
                continue
            if not file.lower().endswith(".md"):
                continue

            path = os.path.join(root, file)
            result = validate_and_fix_frontmatter(path)
            if result:
                fixes.append(result)

    if fixes:
        print("Applied fixes:")
        for f in fixes:
            print(" -", f)
    else:
        print("All notes already valid.")

if __name__ == "__main__":
    main()