import os

lib_dir = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib"

def replace_in_file(path, old, new):
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

replace_in_file(
    os.path.join(lib_dir, r"features\profile\profile.dart"),
    '["Commission", "Subscription"]',
    '["Commission"]'
)

replace_in_file(
    os.path.join(lib_dir, r"features\auth\professional_registration_screen.dart"),
    '["Commission", "Subscription"]',
    '["Commission"]'
)

print("Updated profile.dart and professional_registration_screen.dart")
