import subprocess

file_path = r'c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib\features\appointment\appointment_history.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

cleaned = content.lstrip()

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(cleaned)

print(f"Stripped leading spaces. New length: {len(cleaned)}")
