import re

def fix_profile():
    filepath = r"lib/features/profile/profile.dart"
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    new_lines = []
    in_hint_style = False
    
    for line in lines:
        if 'hintStyle' in line:
            in_hint_style = True
        
        if 'passwordVisibility' in line:
            # We want to replace passwordVisibility with the proper color
            if in_hint_style:
                line = line.replace('passwordVisibility', 'AyurezeTheme.textSecondary')
            else:
                line = line.replace('passwordVisibility', 'AyurezeTheme.textPrimary')
        
        if ')' in line and in_hint_style:
            in_hint_style = False
            
        new_lines.append(line)
        
    new_content = '\n'.join(new_lines)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Fixed profile.dart passwordVisibility colors!")

def fix_cancel_appointment():
    filepath = r"lib/features/appointment/cancel_appointment.dart"
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace('passwordVisibility', 'AyurezeTheme.textSecondary')
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed cancel_appointment.dart passwordVisibility colors!")

fix_profile()
fix_cancel_appointment()
