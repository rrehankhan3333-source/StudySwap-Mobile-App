import os
import re

lib_dir = r"r:\CUI\6th Semester\Mobile Application Dev\Flutter Projectrs\semeste_project\lib"

apptheme_pattern = re.compile(r'AppTheme\.[a-zA-Z0-9_]+')

# We want to find files and line numbers where const is used on a class constructor or list/map literal that contains AppTheme.
# E.g. const BorderSide(color: AppTheme.borderMedium) or const [AppTheme.primary]

count = 0
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            for idx, line in enumerate(lines):
                # Search for lines containing AppTheme
                if 'AppTheme.' in line:
                    # Let's count how many AppTheme references we have
                    print(f"{file}:{idx+1}: {line.strip()}")
                    count += 1

print(f"Total AppTheme references found: {count}")
