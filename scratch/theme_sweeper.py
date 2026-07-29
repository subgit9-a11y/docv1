import os
import re

def sweep_theme():
    dart_files = []
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    replacements = {
        r'Color\(0xFF0F2916\)': 'AyurezeTheme.healingGreen100',
        r'Color\(0xff0F2916\)': 'AyurezeTheme.healingGreen100',
        r'Color\(0xFF10B981\)': 'AyurezeTheme.healingGreen50',
        r'Color\(0xff10b981\)': 'AyurezeTheme.healingGreen50',
        r'Color\(0xFFE6F7F0\)': 'AyurezeTheme.healingGreen10',
        r'Color\(0xffe6f7f0\)': 'AyurezeTheme.healingGreen10',
        r'Color\(0xFF111A14\)': 'AyurezeTheme.oslerGray100',
        r'Color\(0xff111a14\)': 'AyurezeTheme.oslerGray100',
        r'Color\(0xFF849087\)': 'AyurezeTheme.oslerGray50',
        r'Color\(0xff849087\)': 'AyurezeTheme.oslerGray50',
        r'Color\(0xFFF43F5E\)': 'AyurezeTheme.remoteRed50',
        r'Color\(0xfff43f5e\)': 'AyurezeTheme.remoteRed50',
        r'Color\(0xFFF59E0B\)': 'AyurezeTheme.sunshineYellow50',
        r'Color\(0xfff59e0b\)': 'AyurezeTheme.sunshineYellow50',
        # Used Greens
        r'Color\(0xFF008000\)': 'AyurezeTheme.healingGreen50',
        r'Color\(0xff008000\)': 'AyurezeTheme.healingGreen50',
        r'Color\(0xFF4CAF50\)': 'AyurezeTheme.healingGreen50',
        r'Color\(0xff4caf50\)': 'AyurezeTheme.healingGreen50',
        # Greys
        r'Color\(0xFF9E9E9E\)': 'AyurezeTheme.oslerGray50',
        r'Color\(0xff9e9e9e\)': 'AyurezeTheme.oslerGray50',
        r'Color\(0xFF757575\)': 'AyurezeTheme.oslerGray50',
        r'Color\(0xff757575\)': 'AyurezeTheme.oslerGray50',
        r'Color\(0xFFEEEEEE\)': 'AyurezeTheme.lightSurface',
        r'Color\(0xffeeeeee\)': 'AyurezeTheme.lightSurface',
        r'Color\(0xFFF5F5F5\)': 'AyurezeTheme.lightSurfaceMuted',
        r'Color\(0xfff5f5f5\)': 'AyurezeTheme.lightSurfaceMuted',
    }

    files_modified = 0
    total_replacements = 0

    for filepath in dart_files:
        if 'ayureze_theme.dart' in filepath:
            continue
            
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            original_content = content
            
            for pattern, replacement in replacements.items():
                content, count = re.subn(pattern, replacement, content, flags=re.IGNORECASE)
                total_replacements += count

            if content != original_content:
                if 'AyurezeTheme' in content and 'ayureze_theme.dart' not in content:
                    imports_end = content.rfind("import '")
                    if imports_end != -1:
                        line_end = content.find('\n', imports_end)
                        content = content[:line_end] + "\nimport 'package:doctro/theme/ayureze_theme.dart';" + content[line_end:]
                    else:
                        content = "import 'package:doctro/theme/ayureze_theme.dart';\n" + content

                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                files_modified += 1
                
        except Exception as e:
            print(f"Error processing {filepath}: {e}")

    print(f"Modified {files_modified} files, making {total_replacements} color replacements.")

if __name__ == "__main__":
    sweep_theme()
