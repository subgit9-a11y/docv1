import os
import glob
import re

replacements = {
    'package:doctro/model/': 'package:doctro/core/models/',
}

count = 0
for filepath in glob.glob('lib/**/*.dart', recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = content
        for old, new in replacements.items():
            new_content = new_content.replace(old, new)
            
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            count += 1
            print(f"Updated {filepath}")
    except Exception as e:
        print(f"Error reading {filepath}: {e}")

print(f"Total files updated: {count}")
