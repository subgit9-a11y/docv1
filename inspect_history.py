import os

with open(r'c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib\features\appointment\appointment_history.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Strip whitespace
text = text.strip()

# Let's see what text begins with after stripping
print(f"Starts with: {repr(text[:200])}")
print(f"Ends with: {repr(text[-200:])}")

# Let's format basic dart code if it's minified or single-line:
# Add newline after ;, {, }, and split imports
formatted = text
# Replace ';' with ';\n'
# Replace '{' with '{\n'
# Replace '}' with '}\n'

# Save formatted back
with open(r'c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\lib\features\appointment\appointment_history.dart', 'w', encoding='utf-8') as f:
    f.write(formatted)

with open(r'c:\Users\SUBHASH\Desktop\ayureze-doctor-app-v1\history_info.txt', 'w', encoding='utf-8') as f:
    f.write(f"First 1000 chars:\n{formatted[:1000]}\n")
