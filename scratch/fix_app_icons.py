import os
import glob

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"

count = 0
for filepath in glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if 'AppIcons.AyurezeTheme.canvas' in content:
            new_content = content.replace('AppIcons.AyurezeTheme.canvas', 'AppIcons.back')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            count += 1
            print(f"Fixed {filepath}")
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")

print(f"Total files fixed: {count}")
