import os
import re

SCREENS_DIR = r"r:\CUI\6th Semester\Mobile Application Dev\Flutter Projectrs\semeste_project\lib\screens"

def cleanup_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace surfaceTintColor block with AppTheme.bgCard insertion back to simple surfaceTintColor: Colors.transparent,
    original = content
    content = re.sub(
        r'surfaceTintColor:\s+Colors\.transparent\s*,\s*\n\s*backgroundColor:\s+AppTheme\.bgCard\s*,',
        'surfaceTintColor: Colors.transparent,',
        content
    )
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Cleaned duplicates in {os.path.basename(filepath)}")

def run():
    for file in os.listdir(SCREENS_DIR):
        if file.endswith('.dart'):
            cleanup_file(os.path.join(SCREENS_DIR, file))

if __name__ == "__main__":
    run()
