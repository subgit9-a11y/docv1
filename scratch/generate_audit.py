import os
import re
import yaml

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"
pubspec_path = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\pubspec.yaml"
main_path = os.path.join(lib_dir, "main.dart")

def get_pubspec_deps():
    try:
        with open(pubspec_path, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)
            deps = data.get('dependencies', {})
            return list(deps.keys())
    except:
        return []

def get_routes():
    routes = []
    try:
        with open(main_path, 'r', encoding='utf-8') as f:
            content = f.read()
            # Look for routes: { ... }
            match = re.search(r'routes:\s*{(.*?)}', content, re.DOTALL)
            if match:
                route_block = match.group(1)
                # match 'route_name':
                routes = re.findall(r"['\"](.*?)['\"]\s*:", route_block)
    except:
        pass
    return routes

def scan_directory(dir_path):
    structure = {}
    for root, dirs, files in os.walk(dir_path):
        rel_path = os.path.relpath(root, dir_path)
        if rel_path == '.':
            structure['files'] = files
        else:
            parts = rel_path.split(os.sep)
            curr = structure
            for p in parts:
                if p not in curr:
                    curr[p] = {}
                curr = curr[p]
            curr['files'] = files
    return structure

deps = get_pubspec_deps()
routes = get_routes()
structure = scan_directory(lib_dir)

report = f"""# AyurEze Doctor App - Phase 1 Audit Report

## 1. Packages & Dependencies
{', '.join(deps)}

## 2. Routes (from main.dart)
{', '.join(routes)}

## 3. Directory Structure
```json
{structure}
```
"""
with open(r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\scratch\audit_report.md", 'w', encoding='utf-8') as f:
    f.write(report)
print("Audit generated at scratch/audit_report.md")
