import os

apis_path = r"c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib\core\network\apis.dart"
with open(apis_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if 'static const String subscription = "subscription";' in line:
        continue
    if 'static const String purchase_subscription = "purchase_subscrption";' in line:
        continue
    # Fix regex bug
    line = line.replace('AyurezeTheme.healingGreen50', 'status')
    new_lines.append(line)

with open(apis_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Updated apis.dart")
