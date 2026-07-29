import os
import shutil
import glob
import re

# Directory mappings (From -> To)
DIR_MAPPINGS = {
    # Core extractions to lib root
    "lib/core/theme": "lib/theme",
    "lib/core/network": "lib/network",
    "lib/core/widgets": "lib/widgets",
    "lib/core/services": "lib/services",
    "lib/core/models": "lib/models",
    "lib/core/utils": "lib/utils",
    
    # Features renaming
    "lib/features/auth": "lib/features/authentication",
    "lib/features/home_page": "lib/features/dashboard",
    "lib/features/appointment": "lib/features/appointments",
    "lib/features/paymentScreen": "lib/features/cashfree",
    "lib/features/notification": "lib/features/notifications",
    "lib/features/setting": "lib/features/settings",
    
    # Consolidating consultation
    "lib/features/videoCall": "lib/features/consultation/videoCall",
    "lib/features/chat": "lib/features/consultation/chat",
    
    # Consolidating prescription
    "lib/features/astra": "lib/features/prescription/astra",
    "lib/features/pdf_creation": "lib/features/prescription/pdf_creation",
}

# Import string mappings
IMPORT_MAPPINGS = {
    "package:doctro/core/theme/": "package:doctro/theme/",
    "package:doctro/core/network/": "package:doctro/network/",
    "package:doctro/core/widgets/": "package:doctro/widgets/",
    "package:doctro/core/services/": "package:doctro/services/",
    "package:doctro/core/models/": "package:doctro/models/",
    "package:doctro/core/utils/": "package:doctro/utils/",
    
    "package:doctro/features/auth/": "package:doctro/features/authentication/",
    "package:doctro/features/home_page/": "package:doctro/features/dashboard/",
    "package:doctro/features/appointment/": "package:doctro/features/appointments/",
    "package:doctro/features/paymentScreen/": "package:doctro/features/cashfree/",
    "package:doctro/features/notification/": "package:doctro/features/notifications/",
    "package:doctro/features/setting/": "package:doctro/features/settings/",
    
    "package:doctro/features/videoCall/": "package:doctro/features/consultation/videoCall/",
    "package:doctro/features/chat/": "package:doctro/features/consultation/chat/",
    
    "package:doctro/features/astra/": "package:doctro/features/prescription/astra/",
    "package:doctro/features/pdf_creation/": "package:doctro/features/prescription/pdf_creation/",
}

def create_dirs_if_missing():
    required_dirs = ["lib/config", "lib/shared", "lib/repositories", "lib/features/patients"]
    for d in required_dirs:
        os.makedirs(d, exist_ok=True)

def move_directories():
    for src, dst in DIR_MAPPINGS.items():
        if os.path.exists(src):
            # Create parent dir of dst if it doesn't exist (e.g. lib/features/consultation)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            print(f"Moving {src} -> {dst}")
            shutil.move(src, dst)
        else:
            print(f"Warning: Source {src} not found.")

def fix_imports():
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    for filepath in dart_files:
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            for old_import, new_import in IMPORT_MAPPINGS.items():
                content = content.replace(old_import, new_import)
                
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated imports in {filepath}")
        except Exception as e:
            print(f"Error processing {filepath}: {e}")

if __name__ == "__main__":
    print("Creating missing directories...")
    create_dirs_if_missing()
    
    print("\nMoving directories...")
    move_directories()
    
    print("\nFixing imports globally...")
    fix_imports()
    
    print("\nRefactoring complete!")
