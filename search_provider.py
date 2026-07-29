import os
import glob

search_texts = ["Provider.of", ".watch<", ".read<"]

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                if any(t in line for t in search_texts):
                    print(f"{filepath}:{i+1}: {line.strip()}")
    except Exception as e:
        pass
