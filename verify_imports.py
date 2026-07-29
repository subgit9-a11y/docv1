import os
import re

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"

broken_imports = []

def resolve_import(current_file, import_path):
    # If package import of our app
    if import_path.startswith("package:doctro/"):
        rel_path = import_path.replace("package:doctro/", "").replace("/", os.sep)
        target_path = os.path.join(lib_dir, rel_path)
        return target_path, os.path.exists(target_path)
    
    # If dart: or other package: imports, ignore
    if import_path.startswith("package:") or import_path.startswith("dart:"):
        return None, True
        
    # Relative import
    dir_name = os.path.dirname(current_file)
    rel_path = import_path.replace("/", os.sep)
    target_path = os.path.abspath(os.path.join(dir_name, rel_path))
    return target_path, os.path.exists(target_path)

# Find all dart files
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            file_path = os.path.join(root, file)
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                # Match imports
                imports = re.findall(r"import\s+['\"]([^'\"]+)['\"];", content)
                for imp in imports:
                    target, exists = resolve_import(file_path, imp)
                    if not exists:
                        broken_imports.append((file_path, imp, target))
            except Exception as e:
                print(f"Error checking {file_path}: {e}")

print("--- BROKEN IMPORTS REPORT ---")
if not broken_imports:
    print("No broken internal imports found!")
else:
    for file_path, imp, target in broken_imports:
        rel_file = os.path.relpath(file_path, lib_dir)
        print(f"File: lib/{rel_file.replace(os.sep, '/')}")
        print(f"  Import: '{imp}'")
        print(f"  Resolved to non-existent path: {target}")
        print()
