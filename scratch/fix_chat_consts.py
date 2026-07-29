import os

files = [
    r"lib/features/chat/pages/chat_page.dart",
    r"lib/features/chat/pages/home_page.dart"
]

replacements = {
    "const TextStyle(": "TextStyle(",
    "const CircularProgressIndicator(": "CircularProgressIndicator(",
    "const Divider(": "Divider(",
    "const BorderSide(": "BorderSide(",
    "const Border(": "Border(",
    "const BoxDecoration(": "BoxDecoration(",
    "const Icon(": "Icon("
}

for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        orig_content = content
        for k, v in replacements.items():
            content = content.replace(k, v)
            
        if content != orig_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed const in {filepath}")
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")
