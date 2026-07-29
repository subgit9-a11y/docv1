import os
import glob

replacements = {
    'package:doctro/constant/': 'package:doctro/core/constants/',
    'package:doctro/helpers/': 'package:doctro/core/utils/',
    'package:doctro/localization/': 'package:doctro/core/localization/',
    'package:doctro/theme/': 'package:doctro/core/theme/',
    'package:doctro/retrofit/': 'package:doctro/core/network/',
    'package:doctro/widgets/': 'package:doctro/core/widgets/',
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
