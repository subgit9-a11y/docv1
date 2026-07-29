import os
import glob

models_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib\core\models"

count = 0
for filepath in glob.glob(os.path.join(models_dir, '**', '*.dart'), recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if 'AyurezeTheme.healingGreen50' in content:
            new_content = content.replace('AyurezeTheme.healingGreen50', 'status')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            count += 1
            print(f"Fixed {filepath}")
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")

print(f"Total model files fixed: {count}")
