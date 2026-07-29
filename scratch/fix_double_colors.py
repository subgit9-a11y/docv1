import os
import glob

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"

count = 0
for filepath in glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        changed = False
        if 'Colors.Colors.' in content:
            content = content.replace('Colors.Colors.', 'Colors.')
            changed = True
            
        if changed:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            count += 1
            print(f"Fixed {filepath}")
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")

print(f"Total files fixed: {count}")
