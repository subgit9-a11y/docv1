import os
import glob
import re

replacements = {
    'package:doctro/screens/': 'package:doctro/features/',
    'package:doctro/VideoCall/': 'package:doctro/features/VideoCall/',
    'package:doctro/chat/': 'package:doctro/features/chat/',
    'package:doctro/pdf_creation/': 'package:doctro/features/pdf_creation/',
    r"import '\.\./\.\./chat/": r"import '../../chat/", # This was relative, maybe it broke
}

count = 0
for filepath in glob.glob('lib/**/*.dart', recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = content
        for old, new in replacements.items():
            if old.startswith('r"'):
                 new_content = re.sub(old[2:-1], new[2:-1], new_content)
            else:
                 new_content = new_content.replace(old, new)
            
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            count += 1
            print(f"Updated {filepath}")
    except Exception as e:
        print(f"Error reading {filepath}: {e}")

print(f"Total files updated: {count}")
