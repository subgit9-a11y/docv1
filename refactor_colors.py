import os
import glob
import re

replacements = {
    'colorWhite': 'Colors.white',
    'colorBlack': 'AyurezeTheme.textPrimary',
    'cardColor': 'AyurezeTheme.surface',
    'scaffoldBg': 'AyurezeTheme.canvas',
    'cardBorder': 'AyurezeTheme.border',
    'subheading': 'AyurezeTheme.textSecondary',
    'hintColor': 'AyurezeTheme.textSecondary',
    'loginButton': 'AyurezeTheme.actionButtonPrimary',
    'colorButton': 'AyurezeTheme.actionButtonPrimary',
    'divider': 'AyurezeTheme.border',
    'statusCancel': 'AyurezeTheme.danger',
    'red': 'AyurezeTheme.danger',
    'orange': 'AyurezeTheme.warning',
    'green': 'AyurezeTheme.healingGreen50',
    'status': 'AyurezeTheme.healingGreen50',
    'cardText': 'AyurezeTheme.textPrimary',
    'blackOpacity': 'Colors.black54',
    'transparent': 'Colors.transparent',
    'darkGrey': 'Colors.grey.shade800',
    'grey': 'Colors.grey',
    'tealAccent': 'AyurezeTheme.healingGreen50',
    'back': 'AyurezeTheme.canvas',
    "import 'package:doctro/core/constants/color_constant.dart';": "import 'package:doctro/core/theme/ayureze_theme.dart';",
    "import 'package:doctro/constant/color_constant.dart';": "import 'package:doctro/core/theme/ayureze_theme.dart';",
    "import '../../constant/color_constant.dart';": "import 'package:doctro/core/theme/ayureze_theme.dart';"
}

# Ensure we don't accidentally replace parts of variable names. We use regex for whole words for colors.
# For imports, we use simple string replacement.

def process_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Replace colors with whole word match
        for old, new in replacements.items():
            if 'import' in old:
                content = content.replace(old, new)
            else:
                content = re.sub(r'\b' + old + r'\b', new, content)
                
        # Fix duplicated theme imports if any
        content = re.sub(r"(import 'package:doctro/core/theme/ayureze_theme\.dart';\n)+", "import 'package:doctro/core/theme/ayureze_theme.dart';\n", content)
        
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
    except Exception as e:
        pass
    return False

count = 0
for filepath in glob.glob('lib/**/*.dart', recursive=True):
    if process_file(filepath):
        count += 1
        print(f"Updated {filepath}")

print(f"Total files updated: {count}")
