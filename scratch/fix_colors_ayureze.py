import os
import glob
import re

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"

count = 0
for filepath in glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        changed = False
        # Replace Colors.AyurezeTheme.color[800] or .shade800 with AyurezeTheme.color
        # First check if Colors.AyurezeTheme is in the file
        if 'Colors.AyurezeTheme' in content:
            # Replace Colors.AyurezeTheme.something[xxx] or Colors.AyurezeTheme.something.shadeyyy
            new_content = re.sub(r'Colors\.AyurezeTheme\.(\w+)(?:\[\d+\]|\.shade\d+)', r'AyurezeTheme.\1', content)
            # Replace remaining Colors.AyurezeTheme.something
            new_content = new_content.replace('Colors.AyurezeTheme.', 'AyurezeTheme.')
            if new_content != content:
                content = new_content
                changed = True
                
        if changed:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            count += 1
            print(f"Fixed {filepath}")
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")

print(f"Total files fixed: {count}")
