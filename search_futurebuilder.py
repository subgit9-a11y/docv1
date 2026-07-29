import os
import glob

search_text = "FutureBuilder"

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                if search_text in line:
                    print(f"{filepath}:{i+1}: {line.strip()}")
    except Exception as e:
        pass
